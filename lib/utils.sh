#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: utils.sh
# Description: Utility Functions for file2md script.
# Date: 2025-04-02
# Contains: log_message, display_help, check_dependencies, initialize_log_file,
#           _get_numeric_log_level.
# Relies on: Variables sourced from config.sh (Colors, SCRIPT_VERSION,
#            FILE2MD_DIR_NAME, DEFAULT_INPUT_FILE_REL, DEFAULT_OUTPUT_FILE_REL,
#            DEFAULT_IGNORE_FILE_REL, LOG_FILE_REL, FILE2MD_LOG_LEVEL_CONFIG).
#            Global variables from main script (PROJECT_ROOT, LOG_FILE).
#            Environment variable FILE2MD_LOG_LEVEL.
# Modifies global variables: log_file_is_writable.
# ==============================================================================

# --- Internal Helper: Get Numeric Log Level ---
# Parameters: $1: Log level string (e.g., "DEBUG", "INFO")
# Returns: Echoes numeric level (0-4) or a high number for unknown/NONE
_get_numeric_log_level() {
    # Zsh specific: Force uppercase
    local level_upper="${(U)1}"
    case "$level_upper" in
        DEBUG) echo 0 ;;
        INFO) echo 1 ;;
        WARN) echo 2 ;;
        ERROR) echo 3 ;;
        NONE) echo 4 ;;
        *) echo 99 ;; # Unknown level, treat as very high (effectively disabled)
    esac
}

# --- Log function ---
# Usage: log_message "LEVEL" "Message" ["Optional" "extra" "args"...]
log_message() {
    # --- Determine Effective Log Level ---
    # Priority: Environment Variable > Config File > Default ("INFO")
    # Use :? parameter expansion to check if set and not null, otherwise use config
    # Use :- parameter expansion for final default if config is somehow unset/null
    local configured_level_str="${FILE2MD_LOG_LEVEL:-${FILE2MD_LOG_LEVEL_CONFIG:-INFO}}"
    local configured_level_num
    configured_level_num=$(_get_numeric_log_level "$configured_level_str")

    # --- Check if Message Level Meets Configured Threshold ---
    local message_level_str="$1"
    local message_level_num
    message_level_num=$(_get_numeric_log_level "$message_level_str")

    # Exit if configured level is NONE or message level is below threshold
    # Also handles unknown configured levels (numeric 99)
    if [[ "$configured_level_num" -eq 4 ]] || [[ "$message_level_num" -lt "$configured_level_num" ]]; then
        return 0 # Do not log anything
    fi

    # --- Proceed with Logging ---
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Use colors sourced from config.sh (assumed available)
    local color_level="$WHITE" # Default color
    case "${(U)message_level_str}" in # Use uppercase for matching
        INFO) color_level="$GREEN" ;;
        DEBUG) color_level="$BLUE" ;;
        WARN|WARNING) color_level="$YELLOW" ;; # Allow WARN or WARNING
        ERROR) color_level="$RED" ;;
    esac

    # Handle potential extra arguments passed for logging
    local extra_args_str=""
    if [[ $# -gt 2 ]]; then
        extra_args_str=" ${*:3}" # Capture remaining arguments
    fi

    local log_line="[$timestamp] [$message_level_str] $message$extra_args_str"
    local color_log_line="[$timestamp] [${color_level}${message_level_str}${NC}] $message$extra_args_str"

    # Log formatted message to stderr
    echo -e "$color_log_line" >&2

    # Write plain line (no colors) to log file if writable
    # Assumes log_file_is_writable and LOG_FILE are available globally
    # shellcheck disable=SC2154 # Variables are set globally in main script or initialized here
    if [[ $log_file_is_writable -eq 1 && -n "$LOG_FILE" ]]; then
         # Append to log file; uses flock for basic concurrent safety if script were run multiple times
         # flock requires flock command to be installed. If not available, remove 'flock "$LOG_FILE"'
         # flock "$LOG_FILE" echo "$log_line" >> "$LOG_FILE"
         # Simpler version without flock:
         echo "$log_line" >> "$LOG_FILE"
    fi
}

# Display help message
display_help() {
    # Assumes config variables (FILE2MD_DIR_NAME, *_REL, SCRIPT_VERSION)
    # and PROJECT_ROOT are available globally from the main script.
    # shellcheck disable=SC2154 # Variables are set globally/sourced in main script
    local relative_default_input="./$FILE2MD_DIR_NAME/$DEFAULT_INPUT_FILE_REL"
    # shellcheck disable=SC2154
    local relative_default_output="./$FILE2MD_DIR_NAME/$DEFAULT_OUTPUT_FILE_REL"
    # shellcheck disable=SC2154
    local relative_default_ignore="./$FILE2MD_DIR_NAME/$DEFAULT_IGNORE_FILE_REL"
    # shellcheck disable=SC2154
    local relative_default_log="./$FILE2MD_DIR_NAME/$LOG_FILE_REL"

    cat << EOF
Usage: file2md [options]

Description:
  Converts specified files and directory content/structure into Markdown.
  Reads instructions from an input file (default: $relative_default_input).
  Supports flags per line in input file and global excludes from
  $relative_default_ignore. Handles paths with spaces/special chars if quoted.
  Version: $SCRIPT_VERSION

Input File Syntax ($relative_default_input):
  - Lines starting with '#' are comments.
  - Lines starting with '## ' are Markdown H2 headers.
  - Other lines are treated as verbatim text unless they are a valid path.
  - Paths containing spaces or special shell characters should be quoted.
  - Valid paths can be followed by flags:
    - path/to/dir                # Process directory non-recursively
    - "path with spaces/dir/" -r # Process directory recursively (quoted)
    - path/to/dir -t             # Show directory tree structure (non-recursive)
    - path/to/dir -t -r          # Show directory tree structure (recursive)
    - path/to/dir -e "*.log"     # Exclude files matching PATTERN (local, quotes optional)
    - path/to/dir -r -e build/ --exclude "*.tmp" # Combine flags

Ignore File Syntax ($relative_default_ignore):
  - Uses .gitignore syntax for global excludes.
  - Patterns are relative to the project root ($PROJECT_ROOT).
  - Comments (#) are ignored.

Logging:
  - Logging level controlled by FILE2MD_LOG_LEVEL environment variable
    or FILE2MD_LOG_LEVEL_CONFIG in lib/config.sh.
  - Levels: DEBUG, INFO (default), WARN, ERROR, NONE.
  - Log file (if level is not NONE): $relative_default_log

Options:
  -h, --help          Show this help message and exit.
  -f <input_path>     Use specified file as input instead of $relative_default_input.
  -o <output_path>    Write Markdown output to this file instead of $relative_default_output.
EOF
}

# Check basic dependencies
check_dependencies() {
    local missing=0
    # Uses log_message defined above (logging depends on level check now)
    log_message "INFO" "Checking dependencies..."
    # Added find, tree (optional), sed
    for cmd in mkdir touch date wc tr cat awk dirname basename cp read echo print shift find sed; do
        command -v "$cmd" >/dev/null 2>&1 || { log_message "ERROR" "Required command '$cmd' not found."; missing=1; }
    done
    # Use direct command check (SC2181 style)
    if ! command -v tree >/dev/null 2>&1; then
        log_message "INFO" "'tree' command not found. Will use 'find' for directory structure view (-t)."
    fi
    if ! command -v pbcopy >/dev/null 2>&1; then
        log_message "WARNING" "'pbcopy' not found. Clipboard functionality disabled."
    fi
    # Optional: check for flock if using it in log_message
    # if ! command -v flock >/dev/null 2>&1; then
    #     log_message "DEBUG" "'flock' command not found. Log file writing will not use file locking."
    # fi
    if [[ $missing -eq 1 ]]; then log_message "ERROR" "Please install missing dependencies."; exit 1; fi
    log_message "INFO" "Basic dependencies seem present."
}

# Initialize/Clear the log file safely
# Sets the global variable log_file_is_writable
initialize_log_file() {
    # --- Check if file logging is enabled ---
    local configured_level_str="${FILE2MD_LOG_LEVEL:-${FILE2MD_LOG_LEVEL_CONFIG:-INFO}}"
    local configured_level_num
    configured_level_num=$(_get_numeric_log_level "$configured_level_str")

    # shellcheck disable=SC2154 # log_file_is_writable is global
    log_file_is_writable=0 # Default to not writable

    if [[ "$configured_level_num" -eq 4 ]]; then
        # Log level is NONE, disable file logging entirely
        # Use a DEBUG message here, as INFO/WARN/ERROR might be disabled by the level itself
        log_message "DEBUG" "Configured log level is NONE. Skipping log file initialization."
        return 0 # Success, but file logging is disabled
    fi

    # --- Proceed with file initialization ---
    # Assumes LOG_FILE is available globally from main script
    # shellcheck disable=SC2154
    if [[ -z "$LOG_FILE" ]]; then
        # Should not happen if main script logic is correct, but as safeguard:
        log_message "ERROR" "LOG_FILE variable not set. Cannot initialize log file."
        return 1 # Indicate failure
    fi

    log_message "DEBUG" "=== Starting Log File Initialization ==="
    log_message "DEBUG" "Target log file path: $LOG_FILE"
    # SC2181 Style: Check commands directly
    if ! touch "$LOG_FILE"; then
        log_message "ERROR" "Step 1 Failed: Could not touch log file: $LOG_FILE. Logging to file disabled."
        # log_file_is_writable remains 0
        return 1 # Return error status
    fi
    # Truncate using cp /dev/null for safety
    if ! cp /dev/null "$LOG_FILE"; then
        log_message "ERROR" "Step 2 Failed: Could not truncate log file via cp: $LOG_FILE. Logging to file disabled."
        # log_file_is_writable remains 0
        return 1 # Return error status
    fi

    # Set flag globally *before* logging success message that depends on it
    log_file_is_writable=1
    log_message "INFO" "Log file initialized successfully via touch/cp: $LOG_FILE"
    log_message "INFO" "Logging to file '$LOG_FILE' enabled for levels >= $configured_level_str."
    log_message "DEBUG" "=== Finished Log File Initialization Attempt (Success) ==="
    return 0 # Return success status
}

# Optional: Log that utils were loaded (useful for debugging)
# This message itself will only appear if the log level is DEBUG
log_message "DEBUG" "Utility functions loaded (including optional logging logic)."