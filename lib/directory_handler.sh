#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: directory_handler.sh
# Description: Directory Handling Functions for file2md script.
# Date: 2025-04-02
# Contains: list_directory_structure, process_directory_content,
#           process_directory_entry
# Relies on: Functions sourced from utils.sh (log_message).
#            Functions sourced from file_handler.sh (process_file).
#            Variables sourced from config.sh (Colors).
#            Global variables from main script (PROJECT_ROOT, global_excludes_array).
# Modifies global variables: output_content, total_chars, dirs_processed,
#                           file_info_summary.
# ==============================================================================

# --- Functions ---

# List directory structure (tree or find fallback)
# Parameters: $1: Absolute path, $2: Recursive flag, $3+: Local excludes
list_directory_structure() {
    local dir_path="$1"; local is_recursive="$2"; shift 2; local -a local_excludes=( "$@" )
    # SC2295/SC2155 Fixes
    # shellcheck disable=SC2154 # PROJECT_ROOT is global
    local relative_path_to_process="${dir_path#"$PROJECT_ROOT"/}"
    local bn; bn=$(basename -- "$dir_path")
    [[ "$relative_path_to_process" == "$dir_path" ]] && relative_path_to_process="$bn"
    [[ "$relative_path_to_process" != *"/"* && "$dir_path" == "$PROJECT_ROOT/$relative_path_to_process" ]] && relative_path_to_process="./$relative_path_to_process"
    relative_path_to_process="./${relative_path_to_process#./}"; relative_path_to_process="${relative_path_to_process//\/\//\/}"

    log_message "INFO" "Generating directory structure for: $relative_path_to_process (Recursive: $is_recursive)"
    # SC2145 Fix applied earlier
    local local_excludes_str="(${local_excludes[*]})"
    log_message "DEBUG" "  -> Local excludes: $local_excludes_str"
    # shellcheck disable=SC2154 # global_excludes_array is global
    local global_excludes_str="(${global_excludes_array[*]})"
    log_message "DEBUG" "  -> Global excludes: $global_excludes_str"

    local header="### Directory Structure: $relative_path_to_process"; local structure_content=""; local cmd_status=0

    if command -v tree >/dev/null 2>&1; then
        # --- TREE Command Logic ---
        log_message "DEBUG" "Using 'tree' command."
        local -a tree_cmd=("tree" "$relative_path_to_process" "-a")
        [[ "$is_recursive" -eq 0 ]] && tree_cmd+=("-L" "1")

        # Directly use global_excludes_array for -I pattern
        # shellcheck disable=SC2154 # global_excludes_array is global
        if [[ ${#global_excludes_array[@]} -gt 0 ]]; then
            local exclude_pattern
            exclude_pattern="${(j:|:)global_excludes_array}"
            log_message "DEBUG" "  -> Tree GLOBAL exclude pattern: '$exclude_pattern'";
            tree_cmd+=("-I" "$exclude_pattern");
        fi
        # Log warning if local excludes were provided, as they are ignored by tree
        if [[ ${#local_excludes[@]} -gt 0 ]]; then
             log_message "WARNING" "Local excludes (-e) were specified but are ignored by the 'tree' command structure view."
        fi

        log_message "DEBUG" "  -> Executing tree command array from $PROJECT_ROOT: ${(qq)tree_cmd}" # SC2296
        local tree_output; tree_output=$( (cd "$PROJECT_ROOT" && "${tree_cmd[@]}") 2>&1 ); cmd_status=$? # SC2155
        if [[ $cmd_status -ne 0 ]]; then log_message "WARNING" "'tree' command failed (status $cmd_status). Output: $tree_output"; structure_content="(Failed: tree status $cmd_status)";
        else log_message "INFO" "'tree' command successful."; structure_content="$tree_output"; if [[ ! ( "$structure_content" == "$relative_path_to_process"* || "$structure_content" == "./$relative_path_to_process"* ) ]]; then structure_content="$relative_path_to_process"$'\n'"$structure_content"; fi; fi
    else
        # --- FIND FALLBACK for TREE VIEW ---
        log_message "INFO" "'tree' command not found. Using 'find' as fallback."
        local -a find_cmd=("find" ".")
        local -a prune_conditions_args=()
        local pattern=""

        # Combine local and global excludes, then make unique
        # shellcheck disable=SC2154 # global_excludes_array is global
        local -a all_excludes=( "${local_excludes[@]}" "${global_excludes_array[@]}" )
        typeset -aU all_excludes

        # Build prune conditions from the unique list
        if [[ ${#all_excludes[@]} -gt 0 ]]; then
             prune_conditions_args+=("(")
             local first_exclude_in_group=1 # Flag for adding -o within the group
             for pattern in "${all_excludes[@]}"; do
                # Check if pattern came from the original local_excludes list
                local is_local=0
                if [[ ${local_excludes[(i)$pattern]} -le ${#local_excludes} ]]; then
                    is_local=1
                fi

                # Add '-o' if this is NOT the first exclude in the group
                [[ $first_exclude_in_group -eq 0 ]] && prune_conditions_args+=("-o")

                # Determine full path (prefix local, not global)
                local full_pattern=""
                if [[ $is_local -eq 1 ]]; then
                    full_pattern="${relative_path_to_process}/${pattern}"
                else
                    full_pattern="./${pattern}"
                fi
                full_pattern="./${full_pattern#./}"; full_pattern="${full_pattern//\/\//\/}"; full_pattern="${full_pattern//\/.\//\/}";

                # Add the actual -path condition
                if [[ "$pattern" == */ || ("$pattern" != *"*"* && "$pattern" != *"?"* && "$pattern" != *"["* && "$pattern" != *"("* && "$pattern" != *"{"*) ]]; then
                    local dir_pattern="${full_pattern%/}"
                    # *** FIX: Use $(...) for command substitution in log message ***
                    log_message "DEBUG" "    -> Adding FIND TREE DIR prune ($( [[ ${is_local} -eq 1 ]] && echo 'LOCAL' || echo 'GLOBAL' )): -path '$dir_pattern' -o -path '$dir_pattern/*'"
                    prune_conditions_args+=("(" "-path" "$dir_pattern" "-o" "-path" "$dir_pattern/*" ")")
                else
                    # *** FIX: Use $(...) for command substitution in log message ***
                    log_message "DEBUG" "    -> Adding FIND TREE FILE prune ($( [[ ${is_local} -eq 1 ]] && echo 'LOCAL' || echo 'GLOBAL' )): -path '$full_pattern'"
                    prune_conditions_args+=("-path" "$full_pattern")
                fi
                first_exclude_in_group=0 # Mark that we've added at least one condition
             done
             prune_conditions_args+=(")") # Close the group
        fi
        # Add the prune action
        [[ ${#prune_conditions_args[@]} -gt 0 ]] && find_cmd+=( "${prune_conditions_args[@]}" "-prune" "-o" )

        # Add target path conditions (escaped)
        local escaped_target_path; escaped_target_path=$(echo "$relative_path_to_process" | sed 's/\([][()\*?{}\\]\)/\\\1/g')
        local target_path_itself="$escaped_target_path"; local target_path_contents="${escaped_target_path}/*"
        find_cmd+=("(" "-path" "$target_path_itself" "-o" "-path" "$target_path_contents" ")")

        # Add maxdepth for non-recursive
        if [[ "$is_recursive" -eq 0 ]]; then
             local target_depth; target_depth=$(($(echo "$relative_path_to_process" | tr -cd '/' | wc -c) + 1))
             local max_find_depth=$((target_depth + 1))
             [[ "$relative_path_to_process" == "." ]] && max_find_depth=2
             log_message "DEBUG" "  -> Applying max depth for find: $max_find_depth"
             find_cmd+=("-maxdepth" "$max_find_depth")
        fi
        find_cmd+=("-print")
        log_message "DEBUG" "  -> Executing find command array from $PROJECT_ROOT: ${(qq)find_cmd}"
        local find_output; find_output=$( (cd "$PROJECT_ROOT" && "${find_cmd[@]}") 2>&1 ); cmd_status=$?
        if [[ $cmd_status -ne 0 ]]; then log_message "WARNING" "'find' command failed (status $cmd_status). Output: $find_output"; structure_content="(Failed: find status $cmd_status)";
        else log_message "INFO" "'find' command successful."; local formatted_output; formatted_output=$(echo "$find_output" | sort | sed "s|^./||; s|^$relative_path_to_process/\{0,1\}|  |"); structure_content="$formatted_output"; if [[ "$structure_content" != "$relative_path_to_process"* && "$structure_content" != *"  "* ]]; then structure_content="$relative_path_to_process"$'\n'"$structure_content"; fi; fi
    fi

    # --- Common finalization for tree/find output ---
    [[ -n "$structure_content" && "$structure_content" != *$'\n' ]] && structure_content+=$'\n'
    local code_block="\`\`\`text"$'\n'"${structure_content}\`\`\`";

    # shellcheck disable=SC2154
    output_content+="$header"$'\n'"$code_block"$'\n\n'
    # shellcheck disable=SC2154
    total_chars=$((total_chars + ${#header} + ${#code_block} + 3))
    ((dirs_processed++));
    # shellcheck disable=SC2154
    file_info_summary+="  ${BLUE}🌳 Added Tree: $relative_path_to_process (Recursive: $is_recursive)${NC}\n";
    return 0
}

# Process directory content (find files)
# Parameters: $1: Absolute path, $2: Recursive flag, $3+: Local excludes
process_directory_content() {
    local dir_path="$1"; local is_recursive="$2"; shift 2; local -a local_excludes=( "$@" )
    # SC2295/SC2155 Fixes
    # shellcheck disable=SC2154 # PROJECT_ROOT is global
    local relative_path_to_process="${dir_path#"$PROJECT_ROOT"/}"; local bn; bn=$(basename -- "$dir_path"); [[ "$relative_path_to_process" == "$dir_path" ]] && relative_path_to_process="$bn"
    if [[ "$relative_path_to_process" != "." ]]; then relative_path_to_process="./${relative_path_to_process#./}"; relative_path_to_process="${relative_path_to_process//\/\//\/}"; [[ "$relative_path_to_process" != "./" ]] && relative_path_to_process="${relative_path_to_process%/}"; fi

    log_message "INFO" "Processing directory content for: $relative_path_to_process (Recursive: $is_recursive)"
    # SC2145 Fix applied earlier
    local local_excludes_str="(${local_excludes[*]})"; log_message "DEBUG" "  -> Local excludes: $local_excludes_str"
    # shellcheck disable=SC2154 # global_excludes_array is global
    local global_excludes_str="(${global_excludes_array[*]})"; log_message "DEBUG" "  -> Global excludes: $global_excludes_str"

    local processed_in_dir=0
    local -a find_cmd=("find" "."); local -a prune_conditions_args=()
    local pattern=""

    # Combine local and global excludes, then make unique
    # shellcheck disable=SC2154 # global_excludes_array is global
    local -a all_excludes=( "${local_excludes[@]}" "${global_excludes_array[@]}" )
    typeset -aU all_excludes # Keep unique list

    # Build prune conditions from the unique list
    if [[ ${#all_excludes[@]} -gt 0 ]]; then
         prune_conditions_args+=("(")
         local first_exclude_in_group=1 # Flag for adding -o within the group
         for pattern in "${all_excludes[@]}"; do
            # Check if pattern came from the original local_excludes list
            local is_local=0
            if [[ ${local_excludes[(i)$pattern]} -le ${#local_excludes} ]]; then
                is_local=1
            fi

            # Add '-o' if this is NOT the first exclude in the group
            [[ $first_exclude_in_group -eq 0 ]] && prune_conditions_args+=("-o")

            # Determine full path (prefix local, not global)
            local full_pattern=""
            if [[ $is_local -eq 1 ]]; then
                full_pattern="${relative_path_to_process}/${pattern}"
            else
                full_pattern="./${pattern}"
            fi
            full_pattern="./${full_pattern#./}"; full_pattern="${full_pattern//\/\//\/}"; full_pattern="${full_pattern//\/.\//\/}";

            # Add the actual -path condition
            if [[ "$pattern" == */ || ("$pattern" != *"*"* && "$pattern" != *"?"* && "$pattern" != *"["* && "$pattern" != *"("* && "$pattern" != *"{"*) ]]; then
                 local dir_pattern="${full_pattern%/}"
                 # *** FIX: Use $(...) for command substitution in log message ***
                 log_message "DEBUG" "    -> Adding FIND CONTENT DIR prune ($( [[ ${is_local} -eq 1 ]] && echo 'LOCAL' || echo 'GLOBAL' )): -path '$dir_pattern' -o -path '$dir_pattern/*'"
                 prune_conditions_args+=("(" "-path" "$dir_pattern" "-o" "-path" "$dir_pattern/*" ")")
            else
                 # *** FIX: Use $(...) for command substitution in log message ***
                 log_message "DEBUG" "    -> Adding FIND CONTENT FILE prune ($( [[ ${is_local} -eq 1 ]] && echo 'LOCAL' || echo 'GLOBAL' )): -path '$full_pattern'"
                 prune_conditions_args+=("-path" "$full_pattern")
            fi
            first_exclude_in_group=0 # Mark that we've added at least one condition
         done
         prune_conditions_args+=(")") # Close the group
    fi
    # Add the prune action
    [[ ${#prune_conditions_args[@]} -gt 0 ]] && find_cmd+=( "${prune_conditions_args[@]}" "-prune" "-o" )

    # Add target path condition (escaped)
    local escaped_target_path; escaped_target_path=$(echo "$relative_path_to_process" | sed 's/\([][()\*?{}\\]\)/\\\1/g')
    local target_path_pattern="${escaped_target_path}/*"
    find_cmd+=("-path" "$target_path_pattern")
    log_message "DEBUG" "  -> Target path pattern filter: '$target_path_pattern'"

    # Add maxdepth for non-recursive
    if [[ "$is_recursive" -eq 0 ]]; then
         local target_slashes; target_slashes=$(echo "$relative_path_to_process" | tr -cd '/' | wc -c)
         local maxdepth=$((target_slashes + 1));
         [[ "$relative_path_to_process" == "." ]] && maxdepth=1
         log_message "DEBUG" "  -> Applying find maxdepth: $maxdepth"
         find_cmd+=("-maxdepth" "$maxdepth")
    fi
    find_cmd+=("-type" "f" "-print")
    log_message "DEBUG" "  -> Executing find command array from $PROJECT_ROOT: ${(qq)find_cmd}" # SC2296

    # --- Execute Find and Process Results ---
    local cmd_status=0; local found_rel_path_from_root
    while IFS= read -r found_rel_path_from_root; do
        found_rel_path_from_root=${found_rel_path_from_root#./}
        if [[ -n "$found_rel_path_from_root" ]]; then
            # shellcheck disable=SC2154 # PROJECT_ROOT is global
            local full_file_path="$PROJECT_ROOT/$found_rel_path_from_root"
            if [[ -f "$full_file_path" ]]; then
                 log_message "DEBUG" "  -> Found file via find: $found_rel_path_from_root (Full: $full_file_path)"
                 if process_file "$full_file_path"; then
                     ((processed_in_dir++))
                 fi
            else log_message "WARNING" "  -> Find returned non-file path flagged as file: $found_rel_path_from_root"; fi
        fi
    done < <( (cd "$PROJECT_ROOT" && "${find_cmd[@]}") 2> >(log_message "DEBUG" "Find stderr: $(cat)" >&2) )
    cmd_status=$?

    # --- Final Status Logging ---
    if [[ $cmd_status -ne 0 ]]; then
        if [[ $processed_in_dir -gt 0 ]]; then
            log_message "DEBUG" "'find' command process ended with status $cmd_status while searching in '$relative_path_to_process', but files were processed. Ignoring status."
        else
            log_message "WARNING" "'find' command process ended with status $cmd_status while searching in '$relative_path_to_process' and no files were processed."
        fi
    fi

    if [[ $processed_in_dir -eq 0 ]]; then
        log_message "INFO" "No files processed matching criteria in dir: $relative_path_to_process (Recursive: $is_recursive)"
        if [[ $cmd_status -eq 0 ]]; then
             # shellcheck disable=SC2154 # file_info_summary, Colors are global
            file_info_summary+="  ${YELLOW}⚪ No files processed in dir: $relative_path_to_process (Recursive: $is_recursive)${NC}\n";
        else
             : # No additional summary line needed if find status non-zero and no files found
        fi
    else
        log_message "INFO" "Processed $processed_in_dir file(s) in dir: $relative_path_to_process (Recursive: $is_recursive)"
        # shellcheck disable=SC2034 # Intentionally global for summary
        ((dirs_processed++)); # Increment only if files were processed
    fi
    return 0
}

# Process directory entry (router function)
# Parameters: $1: Absolute path, $2: Recursive flag, $3: Tree flag, $4+: Local excludes
process_directory_entry() {
    local dir_path="$1"; local is_recursive="$2"; local is_tree="$3"; shift 3; local -a local_excludes=( "$@" )
    # SC2295/SC2155 Fixes
    # shellcheck disable=SC2154 # PROJECT_ROOT is global
    local display_relative_path="${dir_path#"$PROJECT_ROOT"/}"
    local bn; bn=$(basename -- "$dir_path")
    [[ "$display_relative_path" == "$dir_path" ]] && display_relative_path="$bn"

    log_message "INFO" "Processing directory entry: $display_relative_path"
    local local_excludes_str="(${local_excludes[*]})"; log_message "DEBUG" "  -> Flags: Recursive=$is_recursive, Tree=$is_tree, LocalExcludes=$local_excludes_str" # SC2145 Fix

    if [ ! -d "$dir_path" ]; then log_message "ERROR" "Directory not found: $display_relative_path"; file_info_summary+="  ${RED}❌ Dir not found: $display_relative_path${NC}\n"; return 1; fi # SC2154 Colors global
    if [ ! -r "$dir_path" ] || [ ! -x "$dir_path" ]; then log_message "ERROR" "Cannot access directory (check r,x permissions): $display_relative_path"; file_info_summary+="  ${RED}❌ Cannot access dir: $display_relative_path${NC}\n"; return 1; fi # SC2154 Colors global

    if [[ "$is_tree" -eq 1 ]]; then
        list_directory_structure "$dir_path" "$is_recursive" "${local_excludes[@]}"
    else
        process_directory_content "$dir_path" "$is_recursive" "${local_excludes[@]}"
    fi
    return $? # Return status from list_directory_structure or process_directory_content
}


# Log that directory handler functions were loaded
log_message "DEBUG" "Directory handler functions loaded (entry, content, list)."