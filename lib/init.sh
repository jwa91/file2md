#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: init.sh
# Description: Initialization Functions for file2md script.
# Date: 2025-04-02
# Contains: setup_file2md_directory_only, create_default_files_if_needed,
#           load_global_excludes
# Relies on: Functions sourced from utils.sh (log_message).
#            Variables sourced from config.sh (FILE2MD_DIR_NAME).
#            Global variables from main script (PROJECT_ROOT, FILE2MD_DIR_PATH,
#            DEFAULT_INPUT_FILE, DEFAULT_IGNORE_FILE).
# Modifies global variables: global_excludes_array.
# ==============================================================================

# --- Functions ---

# Set up *only* the file2md directory
# Assumes FILE2MD_DIR_NAME, FILE2MD_DIR_PATH are available globally
setup_file2md_directory_only() {
    # shellcheck disable=SC2154 # Variables are set globally/sourced in main script
    log_message "INFO" "Checking for $FILE2MD_DIR_NAME directory at: $FILE2MD_DIR_PATH"
    # shellcheck disable=SC2154
    if [ ! -d "$FILE2MD_DIR_PATH" ]; then
        # shellcheck disable=SC2154
        log_message "INFO" "Directory '$FILE2MD_DIR_NAME' not found. Creating..."
        # SC2181 Style: Check command directly
        # shellcheck disable=SC2154
        if ! mkdir -p "$FILE2MD_DIR_PATH"; then
             # shellcheck disable=SC2154
             log_message "ERROR" "Failed to create directory $FILE2MD_DIR_PATH."; exit 1;
        fi
        # shellcheck disable=SC2154
        log_message "INFO" "Directory $FILE2MD_DIR_PATH created."
    else
         # shellcheck disable=SC2154
         log_message "INFO" "Directory '$FILE2MD_DIR_PATH' already exists."
    fi
     # Extra check
     # shellcheck disable=SC2154
     if [ ! -d "$FILE2MD_DIR_PATH" ]; then log_message "ERROR" "Directory $FILE2MD_DIR_PATH verification failed after setup attempt. Exiting."; exit 1; fi
     log_message "DEBUG" "Directory setup finished."
}

# Create default input/ignore files (if needed)
# Assumes DEFAULT_INPUT_FILE, DEFAULT_IGNORE_FILE, PROJECT_ROOT are available globally
create_default_files_if_needed() {
    local created_any=0
    log_message "DEBUG" "Checking for default files..."
     # Use the constructed default absolute paths
     # shellcheck disable=SC2154 # Variables are set globally/sourced in main script
     if [ ! -f "$DEFAULT_INPUT_FILE" ]; then
         # shellcheck disable=SC2154
         log_message "INFO" "Creating default input file: $DEFAULT_INPUT_FILE"
         # Group prints redirection (SC2129)
         # shellcheck disable=SC2154
         {
             print -r -- "# Add files/dirs relative to $PROJECT_ROOT"
             print -r -- "README.md"
             print -r -- "# src/   # Example directory (non-recursive content)"
             print -r -- "# src/ -r # Example directory (recursive content)"
             print -r -- "# tests/ -t -r # Example tree view (recursive)"
             print -r -- "# data/ -r -e '*.tmp' --exclude bak/ # Recursive content with excludes"
             print -r -- "# \"path with spaces/\" -r # Example with quotes"
         } > "$DEFAULT_INPUT_FILE" || log_message "WARNING" "Could not create/write to $DEFAULT_INPUT_FILE"
         created_any=1
     fi
     # shellcheck disable=SC2154
     if [ ! -f "$DEFAULT_IGNORE_FILE" ]; then
          # shellcheck disable=SC2154
          log_message "INFO" "Creating default ignore file: $DEFAULT_IGNORE_FILE"
          # Group prints redirection (SC2129)
          # shellcheck disable=SC2154
          {
              print -r -- "# Global ignore patterns (gitignore syntax)"
              print -r -- ".git/"
              print -r -- ".DS_Store"
              # shellcheck disable=SC2154
              print -r -- "$FILE2MD_DIR_NAME/" # Ignore self
              print -r -- "*.log"
              print -r -- "node_modules/"
              print -r -- "build/"
              print -r -- "dist/"
              print -r -- "# Temp files"
              print -r -- "*.tmp"
          } > "$DEFAULT_IGNORE_FILE" || log_message "WARNING" "Could not create/write to $DEFAULT_IGNORE_FILE"
          created_any=1
     fi
     [[ $created_any -eq 1 ]] && log_message "INFO" "Default config file(s) created/ensured."
}

# Load global ignore file
# Assumes DEFAULT_IGNORE_FILE is available globally
# Sets global_excludes_array globally
load_global_excludes() {
    # shellcheck disable=SC2154 # Variable is set globally in main script
    global_excludes_array=() # Reset array
    # shellcheck disable=SC2154
    if [[ -f "$DEFAULT_IGNORE_FILE" && -r "$DEFAULT_IGNORE_FILE" ]]; then
        # shellcheck disable=SC2154
        log_message "INFO" "Loading global excludes from: $DEFAULT_IGNORE_FILE"
        local line line_no_comment
        # shellcheck disable=SC2154
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | awk '{$1=$1};1')
            line_no_comment=${line%%#*}
            line_no_comment=$(echo "$line_no_comment" | awk '{$1=$1};1')

            if [[ -n "$line_no_comment" ]]; then
                log_message "DEBUG" "  -> Adding global exclude pattern: '$line_no_comment'"
                global_excludes_array+=("$line_no_comment") # Append to global array
            fi
        done < "$DEFAULT_IGNORE_FILE"
        log_message "INFO" "Loaded ${#global_excludes_array[@]} global exclude patterns."
    else
        # shellcheck disable=SC2154
        log_message "INFO" "Global ignore file not found or not readable: $DEFAULT_IGNORE_FILE. No global excludes loaded."
    fi
}

# Optional: Log that init functions were loaded
log_message "DEBUG" "Initialization functions loaded."