# File2MD Shell Script Coding Conventions

This document outlines the coding conventions for the `file2md` shell script project. Adhering to these conventions ensures consistency, readability, and maintainability across the codebase.

**Note on Shellcheck:** While the scripts use Zsh (`#!/bin/zsh`), Shellcheck's Zsh support is limited. The pragmatic approach used is `# shellcheck shell=bash`. If Shellcheck incorrectly flags valid Zsh syntax, use specific `# shellcheck disable=SCXXXX` directives on those lines with a comment explaining why (e.g., `# Zsh feature`).

## 1. Script Header

- **Shebang:** All executable scripts **MUST** start with `#!/bin/zsh` to explicitly declare Zsh as the interpreter.
- **Shellcheck Directive:** Include `# shellcheck shell=bash` on the second line to enable static analysis (see Note above).
- **Metadata Block:** Include a comment block (`# ===...`) containing:
  - `Filename:` (Optional, self-evident)
  - `Description:` A brief explanation of the script's or library's purpose.
  - `Author:` (Optional) Name of the author.
  - `Date:` (Optional) Last modification date or creation date.
  - `Contains:` (For libraries) List key functions defined within.
  - `Relies on:` (For libraries) List dependencies (sourced files, key global variables, required commands).
  - `Modifies global variables:` (For libraries) Explicitly list any global variables the library functions modify.

## 2. Naming Conventions

### 2.1 Variables

- Use `snake_case` for local and non-constant global variables (e.g., `input_file`, `trimmed_line`).
- Use `UPPER_SNAKE_CASE` for global constants and configuration values defined in `config.sh` or derived at the start (e.g., `SCRIPT_VERSION`, `PROJECT_ROOT`, `DEFAULT_INPUT_FILE`).
- Use a leading underscore (`_snake_case`) for global variables primarily used to "return" values from functions (e.g., `_parsed_is_recursive`, `_parsed_local_excludes`). This signifies they are set as side effects.

### 2.2 Functions

- Use `snake_case` (e.g., `log_message`, `process_directory_entry`).
- Function names should be descriptive and indicate their action. Prefix helper/internal functions with an underscore (`_`) if desired (e.g., `_get_numeric_log_level`).

### 2.3 Files

- Use `snake_case.sh` for library files (e.g., `file_handler.sh`).
- The main executable script name should reflect its primary purpose (e.g., `file2md.sh`).

## 3. Organization and Structure

- **Modularity:** The project is structured into a main executable script and several library files within a `lib/` subdirectory.
- **Separation of Concerns:** Each library file should focus on a specific area:
  - `config.sh`: Constants, default paths (relative), colors, configuration toggles (like log level).
  - `utils.sh`: Generic utility functions (logging, help, dependency checks, etc.).
  - `init.sh`: Initialization tasks run once at the start (directory setup, default file creation, loading global settings like ignores).
  - `input_processor.sh`: Parsing command-line arguments and inline flags from the input file.
  - `file_handler.sh`: Logic for processing individual files.
  - `directory_handler.sh`: Logic for processing directories (listing structure or content).
- **Main Script (`file2md.sh`) Structure:**
  1.  Shebang & Shellcheck Directive
  2.  Header Comment Block
  3.  Determine `SCRIPT_DIR` and `PROJECT_ROOT`.
  4.  Source library files in dependency order, with existence checks and error handling.
  5.  Define/Construct absolute paths for defaults using sourced constants.
  6.  Declare global runtime variables.
  7.  Call initialization functions from sourced libraries.
  8.  Parse command-line options (`getopts`).
  9.  Validate inputs (e.g., input file existence).
  10. Main processing logic (e.g., reading input file, delegating to handlers).
  11. Finalization (e.g., calculating stats, writing output file, clipboard).
  12. Display summary to the user.
  13. Exit (`exit 0` on success, `exit 1` on error).
- **Library File Structure:**
  1.  Shebang & Shellcheck Directive
  2.  Header Comment Block (including dependencies and modified globals).
  3.  Function definitions.
  4.  (Optional) A `log_message "DEBUG" "..."` at the end confirming the library was loaded.

## 4. Variable Scope

- **Default to Local:** **ALWAYS** declare variables inside functions using `local` unless they are intentionally meant to modify a global variable.
- **Global Variables:** Declare global variables intended for runtime use in the main script. Access and modification by library functions **MUST** be explicitly documented in the library's header comment.
- **Constants:** Define constants in `config.sh` using `UPPER_SNAKE_CASE`.

## 5. Functions

- **Single Responsibility:** Functions should ideally perform one specific task.
- **Parameters:** Access function parameters using `$1`, `$2`, etc. Use `shift` appropriately when processing parameters in loops. Store parameters in descriptive local variables immediately.
- **Return Values:**
  - Use `return 0` for success and `return 1` (or other non-zero) for failure to indicate status. Check the return status of called functions (`if function_call; then ...`).
  - For returning data, either:
    - Modify documented global variables (current approach for `output_content`, `total_chars`, etc., and `_parsed_*` flags). This **MUST** be documented.
    - (Alternative) Echo the result and capture using `local result=$(function_call)`. This is generally cleaner for single values but harder for multiple values or complex data in shell.

## 6. Error Handling and Logging

- **Check Command Success:** Check the exit status (`$?`) or use `if ! command; then ...` after critical operations (file I/O, external commands).
- **Validate Inputs:** Check for file/directory existence (`-e`, `-f`, `-d`), readability (`-r`), writability (`-w`), executability (`-x`) as needed.
- **Use `log_message`:** Utilize the central `log_message` function for all informative output.
  - **Levels:** Use appropriate levels: `DEBUG` (detailed steps), `INFO` (major actions, progress), `WARN` (potential issues, non-fatal errors), `ERROR` (fatal errors, script will likely exit).
  - **Output:** Log messages go to `stderr` (colored) and optionally to a log file (plain).
- **Exit Codes:** Use `exit 1` for script termination due to an error. Use `exit 0` for successful completion.
- **User Feedback:** Provide clear messages to the user via `stderr` (using `log_message` or direct `echo -e` for the final summary).

## 7. Comments

- **File Headers:** Mandatory as described in Section 1.
- **Function Doc Comments:** Optional but recommended for complex functions, explaining purpose, parameters, and side effects (modified globals).
- **Inline Comments:** Use `#` to explain non-obvious logic, workarounds, complex commands (like `find`), or `shellcheck` directives. Keep comments concise and relevant.

## 8. Shell Scripting Practices (Zsh)

- **Zsh Dependency:** This project explicitly targets and relies on Zsh features. It is **not** expected to be compatible with Bash or POSIX `sh`.
- **Quoting:** **ALWAYS** double-quote variable expansions (`"$variable"`) and command substitutions (`"$(command)"`) to prevent word splitting and globbing issues, unless explicitly desired. Use single quotes (`'...'`) for literal strings.
- **Tests:** Prefer `[[ ... ]]` over `[ ... ]` for tests (more robust, less error-prone).
- **Arithmetic:** Use `(( ... ))` for arithmetic operations (e.g., `((total_chars++))`).
- **Command Substitution:** Prefer `$(...)` over backticks (`` `...` ``).
- **Arrays:** Use Zsh array syntax correctly (e.g., `local -a my_array=(...)`, `${my_array[@]}`, `my_array+=("new_element")`). Remember to quote expansions: `"${my_array[@]}"`.
- **Process Substitution:** Use `<(...)` or `>(...)` where appropriate and clear.
- **Parameter Expansion:** Utilize Zsh's powerful parameter expansion features where they improve clarity (e.g., `${var#prefix}`, `${var%suffix}`, `${(U)var}`).
- **`print` vs `echo`:** In Zsh, `print -r --` is often safer for printing arbitrary data literally without interpretation. `echo -e` can be used for interpreting escapes like color codes, especially in the final summary. Be consistent in usage.
- **`read`:** Use `IFS= read -r line` for reliably reading lines from files or commands.

## 9. Readability and Formatting

- **Indentation:** Use consistent indentation (e.g., 4 spaces).
- **Spacing:** Use blank lines to separate logical blocks of code. Use spaces around operators (like `=` in assignments, operators in `[[...]]` and `((...))`).
- **Line Length:** Keep lines reasonably short (e.g., under 100-120 characters) for better readability. Zsh often allows breaking lines after operators or within parentheses without needing explicit backslashes.
- **Consistency:** Apply all conventions consistently throughout the project.
