#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: file2md.sh
# Description: Converts specified files and directory structures into a
#              Markdown file, suitable for pasting into LLMs.
# Author: Jan Willem Altink
# Date: 2025-04-02
# ==============================================================================

# --- Determine Script Directory and Project Root ---
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$PWD"

# --- Source Libraries in Correct Order ---
# 1. Config: Defines constants, relative names, colors
if [[ -f "$SCRIPT_DIR/lib/config.sh" ]]; then source "$SCRIPT_DIR/lib/config.sh"; else echo "[ERROR] config.sh not found" >&2; exit 1; fi
# 2. Utils: Provides logging, help, checks, log init (needs config)
if [[ -f "$SCRIPT_DIR/lib/utils.sh" ]]; then source "$SCRIPT_DIR/lib/utils.sh"; else echo "[ERROR] utils.sh not found" >&2; exit 1; fi
# 3. Init: Sets up dirs, default files, loads global excludes (needs utils, config)
if [[ -f "$SCRIPT_DIR/lib/init.sh" ]]; then source "$SCRIPT_DIR/lib/init.sh"; else log_message "ERROR" "init.sh not found"; exit 1; fi
# 4. Input Processor: Parses flags (needs utils)
if [[ -f "$SCRIPT_DIR/lib/input_processor.sh" ]]; then source "$SCRIPT_DIR/lib/input_processor.sh"; else log_message "ERROR" "input_processor.sh not found"; exit 1; fi
# 5. File Handler: Processes files (needs utils, config)
if [[ -f "$SCRIPT_DIR/lib/file_handler.sh" ]]; then source "$SCRIPT_DIR/lib/file_handler.sh"; else log_message "ERROR" "file_handler.sh not found"; exit 1; fi
# 6. Directory Handler: Processes directories (needs utils, config, init(excludes), file_handler)
if [[ -f "$SCRIPT_DIR/lib/directory_handler.sh" ]]; then source "$SCRIPT_DIR/lib/directory_handler.sh"; else log_message "ERROR" "directory_handler.sh not found"; exit 1; fi

# --- Construct Absolute Default Paths (after sourcing config) ---
FILE2MD_DIR_PATH="$PROJECT_ROOT/$FILE2MD_DIR_NAME"
DEFAULT_INPUT_FILE="$FILE2MD_DIR_PATH/$DEFAULT_INPUT_FILE_REL"
DEFAULT_OUTPUT_FILE="$FILE2MD_DIR_PATH/$DEFAULT_OUTPUT_FILE_REL"
DEFAULT_IGNORE_FILE="$FILE2MD_DIR_PATH/$DEFAULT_IGNORE_FILE_REL"
LOG_FILE="$FILE2MD_DIR_PATH/$LOG_FILE_REL"

# --- Global Variables (Runtime) ---
input_file="$DEFAULT_INPUT_FILE"
output_file="$DEFAULT_OUTPUT_FILE"
show_help=0
log_file_is_writable=0 # Set by initialize_log_file in utils.sh

output_content=""
file_info_summary=""
total_chars=0
files_processed=0
dirs_processed=0

# Global array for global excludes (populated by load_global_excludes in init.sh)
global_excludes_array=()
# Global return vars for parse_inline_flags (set in input_processor.sh)
_parsed_is_recursive=0
_parsed_is_tree=0
_parsed_local_excludes=()


# --- Main Script Execution ---

# Call initialization functions (sourced)
check_dependencies
setup_file2md_directory_only
initialize_log_file # Call before extensive logging
create_default_files_if_needed
load_global_excludes # Call before processing input lines

# --- Option Parsing ---
log_message "INFO" "Starting file2md (Version: $SCRIPT_VERSION)"
log_message "INFO" "Project Root: $PROJECT_ROOT"
parsed_input_file=""
parsed_output_file=""
OPTIND=1
while getopts ":hf:o:-:" opt; do
  if [[ $opt == "-" ]]; then
    case "${OPTARG}" in
      help) opt="h" ;;
      file=*) opt="f"; OPTARG="${OPTARG#*=}" ;;
      output=*) opt="o"; OPTARG="${OPTARG#*=}" ;;
      *) log_message "ERROR" "Unknown long option --${OPTARG}"; display_help; exit 1 ;;
    esac
  fi
  case $opt in
    h) show_help=1 ;;
    f) parsed_input_file="$PROJECT_ROOT/$OPTARG" ;;
    o) parsed_output_file="$PROJECT_ROOT/$OPTARG" ;;
    \?) log_message "ERROR" "Invalid option: -$OPTARG"; display_help; exit 1 ;;
    :) log_message "ERROR" "Option -$OPTARG requires an argument."; display_help; exit 1 ;;
  esac
done
shift $((OPTIND -1))

# Apply parsed options, overriding defaults
[[ -n "$parsed_input_file" ]] && input_file="$parsed_input_file" && log_message "INFO" "Using custom input file: $input_file"
[[ -n "$parsed_output_file" ]] && output_file="$parsed_output_file" && log_message "INFO" "Using custom output file: $output_file"
if [[ $show_help -eq 1 ]]; then display_help; exit 0; fi
# Pass remaining args separately to log_message
if [[ $# -gt 0 ]]; then log_message "ERROR" "Unexpected arguments:" "$@"; display_help; exit 1; fi

# --- Input File Processing ---
if [ ! -f "$input_file" ]; then log_message "ERROR" "Input file not found: $input_file"; exit 1; fi
if [ ! -r "$input_file" ]; then log_message "ERROR" "Input file not readable: $input_file"; exit 1; fi
log_message "INFO" "Reading input from: $input_file"
log_message "INFO" "Starting input file processing..."

# Main loop reading files.txt
while IFS= read -r line || [ -n "$line" ]; do
    # Global variable, no 'local' needed here
    trimmed_line=$(echo "$line" | awk '{$1=$1};1')
    log_message "DEBUG" "Read line: '$trimmed_line'"

    if [[ -z "$trimmed_line" || "$trimmed_line" == '#'* ]]; then
        if [[ "$trimmed_line" == '## '* ]]; then
             log_message "INFO" "Adding H2 Section: ${trimmed_line#\#\# }"
             # *** FIX: Use $'\n' for newlines ***
             output_content+="$trimmed_line"$'\n\n'
             total_chars=$((total_chars + ${#trimmed_line} + 2))
        else
            log_message "DEBUG" "  -> Skipping standard comment or empty line."
        fi
        continue
    fi

    # --- Path Interpretation Logic ---
    # Global variables, no 'local' needed here
    potential_path=""; potential_flags_str=""; potential_path_unquoted=""
    if [[ "$trimmed_line" == \"*\"* || "$trimmed_line" == \'*\'* ]]; then
        quote_char="${trimmed_line:0:1}"
        # SC2154 likely false positive for Zsh =~ which populates match
        if [[ "$trimmed_line" =~ ^("$quote_char"[^"$quote_char"]*"$quote_char")(.*)$ ]]; then
            potential_path="${match[1]}"
            potential_flags_str="${match[2]}"
            potential_path_unquoted="${potential_path:1:-1}"
        else
             read -r potential_path potential_flags_str <<< "$trimmed_line"
             potential_path_unquoted="$potential_path"
        fi
    else
        read -r potential_path potential_flags_str <<< "$trimmed_line"
        potential_path_unquoted="$potential_path"
    fi
    potential_flags_str="${potential_flags_str## }"

    # Global variable, no 'local' needed here
    absolute_path="$PROJECT_ROOT/$potential_path_unquoted"

    # --- Path Processing ---
    if [[ -e "$absolute_path" ]]; then
        log_message "DEBUG" "Interpreting as path: '$potential_path_unquoted' (Flags: '$potential_flags_str')"
        # Call sourced function from input_processor.sh
        parse_inline_flags "$potential_flags_str" # Sets globals _parsed_*

        if [[ -d "$absolute_path" ]]; then
            # Call sourced function from directory_handler.sh
            # Pass parsed flags and excludes
            process_directory_entry "$absolute_path" "$_parsed_is_recursive" "$_parsed_is_tree" "${_parsed_local_excludes[@]}"
        elif [[ -f "$absolute_path" ]]; then
            # Flags are ignored for files, call file handler directly
            if [[ "$_parsed_is_recursive" -ne 0 || "$_parsed_is_tree" -ne 0 || ${#_parsed_local_excludes[@]} -gt 0 ]]; then
                log_message "WARNING" "Flags (-r, -t, -e) were specified but are ignored for files. Processing file '$potential_path_unquoted' normally."
            fi
            # Call sourced function from file_handler.sh
            process_file "$absolute_path"
        else
             log_message "WARNING" "Path exists but is not a regular file or directory: '$potential_path_unquoted'. Treating line as verbatim text."
             # *** FIX: Use $'\n' for newlines ***
             output_content+="$trimmed_line"$'\n'
             total_chars=$((total_chars + ${#trimmed_line} + 1))
        fi
    else
        log_message "INFO" "Path '$potential_path_unquoted' not found. Treating line as verbatim text: $trimmed_line"
        # *** FIX: Use $'\n' for newlines ***
        output_content+="$trimmed_line"$'\n'
        total_chars=$((total_chars + ${#trimmed_line} + 1))
    fi

done < "$input_file"
log_message "INFO" "Finished processing input file."


# --- Finalization & Output ---
total_tokens=$(( (total_chars + 3) / 4 ))
# Global variable, no 'local' needed here
output_dir=$(dirname "$output_file")

if [ ! -d "$output_dir" ]; then
    log_message "INFO" "Output directory does not exist. Creating: $output_dir."
    if ! mkdir -p "$output_dir"; then
         log_message "ERROR" "Failed to create output directory: $output_dir"; echo -e "${RED}FATAL: Cannot create output directory $output_dir${NC}" >&2; exit 1;
    fi
fi

log_message "INFO" "Writing final Markdown output to: $output_file"
output_saved_message=""
# Using print -r is correct here because $output_content now contains actual newlines
if ! print -r -- "$output_content" > "$output_file"; then
    log_message "ERROR" "Failed to write output to file: $output_file."
    output_saved_message="${RED}❌ Save failed: $output_file${NC}"
else
    output_saved_message="${WHITE}📁 Saved to:${NC} ${GREEN}$output_file${NC}"
    log_message "INFO" "Output successfully saved to file."
fi

clipboard_message=""
if command -v pbcopy >/dev/null 2>&1; then
    # Using print -r is correct here because $output_content now contains actual newlines
    if print -r -- "$output_content" | pbcopy; then
        clipboard_message="${WHITE}📋 Copied to clipboard.${NC}"
        log_message "INFO" "Output successfully copied to clipboard (pbcopy)."
    else
        clipboard_message="${YELLOW}📋 Clipboard copy failed (pbcopy error).${NC}"
        log_message "WARNING" "pbcopy command failed."
    fi
else
    clipboard_message="${YELLOW}📋 pbcopy not found, skipping clipboard.${NC}"
    log_message "INFO" "pbcopy not found, skipping clipboard."
fi

# --- Terminal Summary ---
echo -e "\n${BLUE}--- File2MD v${SCRIPT_VERSION} Summary ---${NC}"
if [[ $files_processed -gt 0 || $dirs_processed -gt 0 || $total_chars -gt 0 ]]; then
    if [[ -n "$file_info_summary" ]]; then
        echo -e "${WHITE}Processed Items Summary:${NC}\n${file_info_summary}"
        echo "----------------------------------------"
    fi
    printf "${GREEN}📊 Total Chars Estimate: ${WHITE}%d${NC}\n" "$total_chars"
    printf "${GREEN}🔢 Total Tokens Estimate: ~${WHITE}%d${NC}\n" "$total_tokens"
     echo "----------------------------------------"
    echo -e "$output_saved_message"
    echo -e "$clipboard_message"
else
    echo -e "${YELLOW}⚠️ No content was generated.${NC}"
    # Global variable, no 'local' needed here
    check_msg=""
    if [[ $log_file_is_writable -eq 1 ]]; then check_msg="Check input ($input_file) and log file ($LOG_FILE) for details."; else check_msg="Check input ($input_file) and terminal output for details."; fi
    echo -e "${WHITE}   $check_msg${NC}"
fi
echo -e "${BLUE}--- End Summary ---${NC}"

log_message "INFO" "Script finished."
exit 0