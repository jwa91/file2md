# Using Ignore Patterns Example

This example demonstrates how to use both global and local ignore patterns to exclude certain files and directories from being processed.

## What This Example Shows

- Using a custom `.file2mdignore` file to set global exclude patterns
- Using the `-e` or `--exclude` flags for local, per-directory excludes
- Understanding the difference between global and local ignore patterns
- The limitations of ignore patterns with tree views

## How It Works

1. **Global Ignore Patterns**:
   - The `.file2mdignore` file uses `.gitignore` syntax to define patterns of files to exclude
   - These patterns are applied globally to all file and directory processing
   - Patterns apply to both file content processing and tree views

2. **Local Ignore Patterns**:
   - The `-e` or `--exclude` flags let you specify additional patterns for a specific directory
   - Local patterns only apply to the directory they're specified for
   - You can specify multiple local patterns with multiple `-e` flags
   - **Important Limitation**: Local ignore patterns don't work with tree views (`-t` flag)

## Usage

To apply this technique to your own project:

1. Create a `.file2mdignore` file in your project's `file2md` directory with patterns for files you always want to exclude
2. Create a `files.txt` in your `file2md` directory
3. Use the `-e` flag with directory paths to add local exclusions
4. Remember that local excludes don't work with tree views
5. Run `./file2md.sh` from your project root

This approach gives you two levels of control:
- Global patterns for files you always want to exclude (like node_modules, logs, etc.)
- Local patterns for case-by-case exclusions in specific directory scans