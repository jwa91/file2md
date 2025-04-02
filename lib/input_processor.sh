#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: input_processor.sh
# Description: Input Processing Functions for file2md script.
# Date: 2025-04-02
# Contains: parse_inline_flags
# Relies on: Functions sourced from utils.sh (log_message).
# Modifies global variables: _parsed_is_recursive, _parsed_is_tree,
#                           _parsed_local_excludes.
# ==============================================================================

# --- Functions ---

# Parse inline flags from input file line
# Parameters: $1: The string containing potential flags after the path.
# Returns: Sets global variables: _parsed_is_recursive, _parsed_is_tree, _parsed_local_excludes
parse_inline_flags() {
    local flags_str="$1"
    # Reset global return variables explicitly
    # shellcheck disable=SC2034 # Intentionally global
    _parsed_is_recursive=0
    # shellcheck disable=SC2034 # Intentionally global
    _parsed_is_tree=0
    # shellcheck disable=SC2034 # Intentionally global
    _parsed_local_excludes=()

    # SC2155 Fix
    local trimmed_flags_str
    trimmed_flags_str=$(echo "$flags_str" | awk '{$1=$1};1')
    if [[ -z "$trimmed_flags_str" ]]; then
        # Ensure log_message is available
        command -v log_message >/dev/null && log_message "DEBUG" "  -> No inline flags found after trimming."
        return
    fi

    log_message "DEBUG" "  -> Parsing trimmed inline flags: '$trimmed_flags_str'"
    local -a flag_args
    # Zsh specific syntax (SC2296/SC2206 ignorable)
    flag_args=( ${(s: :)trimmed_flags_str} )
    flag_args=( "${(@)flag_args:#}" )

    if [[ ${#flag_args[@]} -eq 0 ]]; then
         log_message "DEBUG" "  -> No non-empty flag arguments found after splitting."
         return
    fi

    # Format args for logging (SC2145 fix applied earlier)
    local args_log_str
    args_log_str=$(print -rl -- "${flag_args[@]}")
    log_message "DEBUG" "  -> Processing arguments (${#flag_args[@]}):"
    log_message "DEBUG" "    -> Args (one per line in log file):\n$args_log_str"

    while [[ ${#flag_args[@]} -gt 0 ]]; do
        local flag="${flag_args[1]}"
        log_message "DEBUG" "    -> Evaluating arg: '$flag'"
        case "$flag" in
            -r|--recursive)
                 _parsed_is_recursive=1
                 log_message "DEBUG" "      -> Flag: Recursive detected"
                 shift flag_args ;;
            -t|--tree)
                 _parsed_is_tree=1
                 log_message "DEBUG" "      -> Flag: Tree detected"
                 shift flag_args ;;
            -e|--exclude)
                if [[ ${#flag_args[@]} -gt 1 ]]; then
                    local pattern="${flag_args[2]}"; pattern="${pattern#\'}"; pattern="${pattern%\'}"; pattern="${pattern#\"}"; pattern="${pattern%\"}"
                    log_message "DEBUG" "      -> Flag: Exclude detected with pattern (unquoted): '$pattern'"
                    _parsed_local_excludes+=("$pattern"); shift 2 flag_args
                else
                    log_message "WARNING" "      -> Flag: Exclude flag found ('$flag') but no pattern followed. Ignoring flag."; shift flag_args
                fi ;;
            *)
                log_message "WARNING" "    -> Unknown flag or unexpected argument: '$flag'. Ignoring."; shift flag_args ;;
        esac
    done
    # Format array for logging (SC2145 fix applied earlier)
    local excludes_str="(${_parsed_local_excludes[*]})"
    log_message "DEBUG" "  -> Finished parsing flags: Rec=$_parsed_is_recursive, Tree=$_parsed_is_tree, Excl=$excludes_str"
}

# Log that input processor functions were loaded
log_message "DEBUG" "Input processor functions loaded (flags)."