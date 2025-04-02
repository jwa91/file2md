# Recursive Directory Scan Example

This example demonstrates how to use file2md to recursively scan entire directories and include all files.

## What This Example Shows

- Using the `-r` flag to recursively process directories
- Mixing individual file selections with directory scans
- Organizing the output with section headers

## How It Works

1. The `-r` flag after a directory path tells file2md to process all files in that directory and its subdirectories
2. Without the `-r` flag, only files directly in the specified directory would be included
3. You can combine recursive directory scans with individual file selections

## Usage

To apply this technique to your own project:

1. Create a `files.txt` in your project's `file2md` directory
2. Add paths to your key files (like README.md)
3. Add paths to directories you want to scan recursively with the `-r` flag
4. Run `./file2md.sh` from your project root

This approach is useful when you want to include entire subsections of your project, such as all components or all utility functions, but not the entire codebase.