# Basic File2md Usage

This example demonstrates the most basic usage of file2md to select individual files.

## What This Example Shows

- Using `files.txt` to select specific files (not entire directories)
- Adding section headers with `## Section Title` syntax
- Including comments in the `files.txt` file

## How It Works

1. Each line in `files.txt` references a specific file by its path relative to the project root
2. Lines starting with `#` are treated as comments and ignored
3. Lines starting with `## ` are included as Markdown H2 headers in the output
4. When processed, each specified file is included as a syntax-highlighted code block

## Usage

To apply this technique to your own project:

1. Create a `files.txt` in your project's `file2md` directory using similar patterns
2. Adapt the paths to match your project's actual structure
3. Run `./file2md.sh` from your project root

This is ideal for simple cases where you just want to include a few specific files in your LLM prompt.