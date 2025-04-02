#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: file_handler.sh
# Description: File Handling Functions for file2md script.
# Date: 2025-04-02
# Contains: process_file, get_language_hint
# Relies on: Functions sourced from utils.sh (log_message).
#            Variables sourced from config.sh (Colors).
#            Global variables from main script (PROJECT_ROOT).
# Modifies global variables: output_content, total_chars, files_processed,
#                           file_info_summary.
# ==============================================================================

# --- Functions ---

# Detect language (simple version)
# Parameters: $1: File path or name
get_language_hint() {
    # SC2155 Fix
    local filename; filename=$(basename -- "$1")
    # shellcheck disable=SC2034 # False positive due to (L)
    local extension; extension="${filename##*.}"
    # Zsh specific (SC2296)
    case "${(L)extension}" in
       js|jsx) echo "javascript";; ts|tsx) echo "typescript";; py) echo "python";;
       sh|zsh) echo "bash";; md) echo "markdown";; json) echo "json";;
       yaml|yml) echo "yaml";; html) echo "html";; css) echo "css";;
       java) echo "java";; c|h) echo "c";; cpp|hpp) echo "cpp";;
       cs) echo "csharp";; go) echo "go";; rb) echo "ruby";;
       php) echo "php";; sql) echo "sql";; *) echo "";;
    esac
}

# Process a single file
# Parameters: $1: Absolute file path
process_file() {
    local file_path="$1";
    # SC2295 & SC2155 Fixes
    # shellcheck disable=SC2154 # PROJECT_ROOT is global
    local relative_path="${file_path#"$PROJECT_ROOT"/}"
    local bn; bn=$(basename -- "$file_path")
    [[ "$relative_path" == "$file_path" ]] && relative_path="$bn"

    log_message "DEBUG" "Processing file: $relative_path (Full: $file_path)"

    if [ ! -f "$file_path" ]; then
        # shellcheck disable=SC2154 # Colors are global
        log_message "WARNING" "File not found: $relative_path"; file_info_summary+="  ${YELLOW}⚠️ File not found: $relative_path${NC}\n"; return 1;
    fi
    if [ ! -r "$file_path" ]; then
        # shellcheck disable=SC2154 # Colors are global
        log_message "WARNING" "File not readable: $relative_path"; file_info_summary+="  ${RED}❌ File not readable: $relative_path${NC}\n"; return 1;
    fi

    # SC2155 + SC2181 Fixes
    local content
    if ! content=$(cat "$file_path"); then
        # shellcheck disable=SC2154 # Colors are global
        log_message "WARNING" "Failed to read file content: $relative_path"; file_info_summary+="  ${RED}❌ Failed to read: $relative_path${NC}\n"; return 1;
    fi

    local char_count=${#content}
    local header="### $relative_path"
    local code_block

    # Ensure content ends with a newline before adding to code block
    # Prevents ```lang\ncontent``` issue if file has no trailing newline
    [[ "$char_count" -gt 0 && "$content" != *$'\n' ]] && content+=$'\n'

    if [ "$char_count" -eq 0 ]; then
        # shellcheck disable=SC2154 # Colors are global
        log_message "INFO" "File empty: $relative_path"; file_info_summary+="  ${YELLOW}⚪ File empty: $relative_path${NC}\n"
        # *** FIX: Use $'\n' for newlines ***
        code_block="\`\`\`"$'\n'"(This file is empty)"$'\n'"\`\`\`"
    else
        local lang_hint; lang_hint=$(get_language_hint "$relative_path") # SC2155 Fix
        # *** FIX: Use $'\n' for newlines ***
        code_block="\`\`\`${lang_hint}"$'\n'"${content}\`\`\`"
        # shellcheck disable=SC2154 # Colors are global
        file_info_summary+="  ${GREEN}✅ Added File: $relative_path (${char_count} chars)${NC}\n"
        log_message "INFO" "Added File: $relative_path"
    fi

    # Modify global variables directly (common pattern in shell libs)
    # shellcheck disable=SC2154 # Variables are global
    # *** FIX: Use $'\n' for newlines ***
    output_content+="$header"$'\n'"$code_block"$'\n\n'
    # shellcheck disable=SC2154 # Variable is global
    # +3 accounts for the newline after header and the two newlines after the code block
    total_chars=$((total_chars + ${#header} + ${#code_block} + 3))
    # shellcheck disable=SC2034 # Intentionally global for summary
    ((files_processed++));

    return 0
}

# Log that file handler functions were loaded
log_message "DEBUG" "File handler functions loaded (process, hint)."