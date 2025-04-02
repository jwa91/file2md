#!/bin/zsh
# shellcheck shell=bash # Script primarily targets Zsh (unsupported by shellcheck); see README.

# ==============================================================================
# Filename: config.sh
# Description: Configuration for file2md script.
# Date: 2025-04-02
# Contains: Configuration constants (version, relative paths, log level, colors).
# Relies on: None (defines base configuration).
# Modifies global variables: None (defines constants/config vars).
# ==============================================================================

# --- Script Information ---
SCRIPT_VERSION="3.6-optional-logging" # Updated version example

# --- Directory & File Names (Relative Defaults) ---
# The main script will combine these with PROJECT_ROOT
FILE2MD_DIR_NAME="file2md"
DEFAULT_INPUT_FILE_REL="files.txt"
DEFAULT_OUTPUT_FILE_REL="output.md"
DEFAULT_IGNORE_FILE_REL=".file2mdignore"
LOG_FILE_REL="file2md_run.log" # Generic log file name

# --- Logging Configuration ---
# Set the desired logging level. Case-insensitive.
# Valid levels: DEBUG, INFO, WARN, ERROR, NONE
#   DEBUG: Show detailed execution steps.
#   INFO: Show major actions and progress. (Default)
#   WARN: Show warnings about potential issues.
#   ERROR: Show only errors.
#   NONE: Disable all logging (both to stderr and file).
# This value can be overridden by setting the FILE2MD_LOG_LEVEL environment variable.
FILE2MD_LOG_LEVEL_CONFIG="NONE"

# --- Color Codes for Output ---
# Usage: echo -e "${GREEN}Success!${NC}"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
