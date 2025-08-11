#!/usr/bin/bash

#=============================================================================
# SSH Agent Manager
#
# A utility script to automatically start ssh-agent and load all SSH private keys
# from the ~/.ssh directory. Provides options for silent operation and handles
# duplicate key prevention.
#
# Usage:
#   ssh-agent-setup.sh [OPTIONS]
#
# DESCRIPTION:
#     Automatically starts ssh-agent (if not running) and loads all SSH private
#     keys from the ~/.ssh directory. Skips public keys (.pub files) and common
#     excluded files.
#
# OPTIONS:
#     -m, --mute      Suppress non-error output messages
#     -h, --help      Display this help message and exit.
#     -v, --version   Display the version information and exit.
#
# AUTHOR:
#     ricardo.mendes@streambit.dev
# VERSION:
#     1.0.0
#=============================================================================

#=============================================================================
# GLOBAL VARIABLES
#=============================================================================

MUTE=false

#=============================================================================
# UTILITY FUNCTIONS
#=============================================================================

##
# Display usage information
#
usage() {
    local script_name="$(basename "${BASH_SOURCE[0]}" 2>/dev/null || echo "ssh-agent-setup.sh")"

    cat << EOF
Usage: $script_name [OPTIONS]

DESCRIPTION:
    Automatically starts ssh-agent (if not running) and loads all SSH private
    keys from the ~/.ssh directory. Skips public keys (.pub files) and common
    SSH configuration files.

OPTIONS:
    -m, --mute      Suppress non-error output messages
    -h, --help      Display this help message
    -v, --version   Display version information

EXAMPLES:
    # Load SSH keys with output
    source $script_name

    # Load SSH keys silently
    source $script_name --mute

    # Display help
    $script_name --help

NOTES:
    - This script should typically be sourced, not executed directly
    - Only processes files that appear to be SSH private keys
    - Automatically excludes .pub files and SSH config files
    - Prevents duplicate key loading within the same session

EOF
}

##
# Display version information
#
version() {
    local script_name="$(basename "${BASH_SOURCE[0]}" 2>/dev/null || echo "ssh-agent-setup.sh")"
    echo "$script_name version 1.0.0"
}

##
# Log a message (respects mute flag)
# Arguments:
#   $1 - Message to log
#
log_info() {
    local message="$1"
    [[ "$MUTE" == "false" ]] && echo "$message"
}

##
# Log an error message (always displayed)
# Arguments:
#   $1 - Error message to log
#
log_error() {
    local message="$1"
    echo "ERROR: $message" >&2
}

##
# Check if a file should be excluded from SSH key processing
# Arguments:
#   $1 - Filename to check
# Returns:
#   0 if file should be excluded, 1 otherwise
#
is_excluded_file() {
    local filename="$1"
    local excluded_file

    # Define excluded files locally to avoid nameref issues
    local excluded_files=(
        "known_hosts"
        "known_hosts.old"
        "config"
        "authorized_keys"
        "environment"
    )

    for excluded_file in "${excluded_files[@]}"; do
        [[ "$filename" == "$excluded_file" ]] && return 0
    done

    return 1
}

#=============================================================================
# MAIN FUNCTIONS
#=============================================================================

##
# Parse command line arguments
# Arguments:
#   $@ - All command line arguments
#
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--mute)
                MUTE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                version
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage >&2
                exit 1
                ;;
        esac
    done
}

##
# Start ssh-agent if not already running
# Sets SSH_AUTH_SOCK environment variable
#
start_ssh_agent() {
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        log_info "Starting ssh-agent..."
        if eval "$(ssh-agent -s)" > /dev/null 2>&1; then
            log_info "ssh-agent started successfully"
        else
            log_error "Failed to start ssh-agent"
            return 1
        fi
    else
        log_info "ssh-agent already running"
    fi
}

##
# Load all SSH private keys from ~/.ssh directory
# Skips public keys, configuration files, and prevents duplicates
#
load_ssh_keys() {
    local ssh_dir="$HOME/.ssh"
    local key_file
    local basename_key
    local keys_added=0

    # Verify ~/.ssh directory exists
    if [[ ! -d "$ssh_dir" ]]; then
        log_error "SSH directory $ssh_dir does not exist"
        return 1
    fi

    # Check if keys are already loaded (don't fail if ssh-add fails)
    if ssh-add -l >/dev/null 2>&1; then
        log_info "SSH keys already loaded in agent"
        return 0
    fi

    log_info "Loading SSH keys from $ssh_dir..."

    # Keep track of processed keys to avoid duplicates
    declare -A processed_keys

    # Process all potential key files
    for key_file in "$ssh_dir"/*; do
        # Skip if not a regular file
        [[ ! -f "$key_file" ]] && continue

        # Skip public keys (.pub extension)
        [[ "$key_file" == *.pub ]] && continue

        # Get basename for easier handling
        basename_key="$(basename "$key_file")"

        # Skip excluded configuration files
        if is_excluded_file "$basename_key"; then
            continue
        fi

        # Skip if already processed (prevent duplicates)
        [[ -n "${processed_keys[$key_file]:-}" ]] && continue

        # Attempt to add the key
        if ssh-add "$key_file" 2>/dev/null; then
            log_info "✓ Added SSH key: $basename_key"
            processed_keys[$key_file]=1
            ((keys_added++))
        else
            # Silent failure for invalid key files is intentional
            continue
        fi
    done

    # Report results
    if [[ $keys_added -eq 0 ]]; then
        if ! ssh-add -l >/dev/null 2>&1; then
            log_info "No SSH keys found or added from $ssh_dir"
        fi
    else
        log_info "Successfully loaded $keys_added SSH key(s)"
    fi
}

##
# Main execution function
#
main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Start ssh-agent if needed
    start_ssh_agent

    # Load SSH keys
    load_ssh_keys

    log_info "SSH agent setup complete"
}

#=============================================================================
# SCRIPT EXECUTION
#=============================================================================

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
else
    # When sourced, still parse arguments and run
    main "$@"
fi
