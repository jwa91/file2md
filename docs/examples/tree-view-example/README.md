# Tree View Example

This example demonstrates how to use file2md to include directory tree views in your output, providing structural context before showing file contents.

## What This Example Shows

- Using the `-t` flag to generate a tree view of a directory
- Combining `-t` with `-r` for recursive tree views
- Mixing tree views with actual file contents

## How It Works

1. The `-t` flag after a directory path tells file2md to generate a tree view of that directory
2. When combined with `-r`, the tree view includes all subdirectories recursively
3. Without `-r`, only the immediate children of the directory are shown
4. You can include both tree views and actual file contents in the same output

## Usage

To apply this technique to your own project:

1. Create a `files.txt` in your project's `file2md` directory
2. Add paths to directories with the `-t` flag for tree views
3. Add the `-r` flag for recursive tree views when needed
4. Mix tree views with actual file contents as appropriate
5. Run `./file2md.sh` from your project root

This approach is particularly useful when you want to give an LLM both the actual code files and context about how they're organized in the project structure.