# File2md

A Zsh script that converts files and directory structures into a well-formatted Markdown document, ideal for sharing code with Large Language Models (LLMs).

## In short

File2md takes a list of files and directories from your project, processes them according to your specifications, and generates a Markdown file containing their contents in syntax-highlighted code blocks. It also automatically copies the output to your clipboard, ready to paste into your favorite LLM for context.

## Table of content

- [File2md](#file2md)
  - [In short](#in-short)
  - [Table of content](#table-of-content)
  - [Project structure](#project-structure)
  - [Dependencies and limitations](#dependencies-and-limitations)
  - [Usage](#usage)
    - [Command line arguments](#command-line-arguments)
    - [First run](#first-run)
    - [Subsequent runs](#subsequent-runs)
    - [The files.txt conventions](#the-filestxt-conventions)
    - [The .file2mdignore](#the-file2mdignore)
  - [Examples](#examples)
  - [Next steps](#next-steps)

## Project structure

The project follows a modular structure to ensure maintainability:

```
.
├── README.md
├── docs/
│   ├── code_conventions.md
│   └── examples/
├── file2md.sh               # Main script entry point
└── lib/                     # Library modules
    ├── config.sh            # Configuration settings
    ├── directory_handler.sh # Directory processing
    ├── file_handler.sh      # File processing
    ├── init.sh              # Initialization routines
    ├── input_processor.sh   # Flag parsing
    └── utils.sh             # Utility functions
```

## Dependencies and limitations

- **Zsh shell**: Required. The script uses Zsh-specific features and syntax.
- **Core utilities**: Requires common Unix utilities like `mkdir`, `touch`, `date`, `cat`, `find`, etc.
- **Optional dependencies**:
  - `tree`: For enhanced directory structure visualization (falls back to `find` if not available)
  - `pbcopy`: For automatic clipboard copying (macOS only, skipped if not available)
- **Platform**: Primarily tested on macOS with Apple Silicon, but should work on any Unix-like system with Zsh installed.

## Usage

### Command line arguments

```
Usage: file2md [options]

Options:
  -h, --help          Show this help message and exit.
  -f <input_path>     Use specified file as input instead of ./file2md/files.txt.
  -o <output_path>    Write Markdown output to this file instead of ./file2md/output.md.
```

/\*\*

- `file2md` in this case is the shell alias that points to the script.
  \*/

### First run

When you first run the script in a project:

1. It creates a `file2md` directory in your current working directory.
2. It generates default configuration files:

   - `file2md/files.txt`: A template input file with example syntax
   - `file2md/.file2mdignore`: A default global ignore file with common patterns

3. It generates an empty output (since no files are specified yet).

### Subsequent runs

1. Edit `file2md/files.txt` to specify the files and directories you want to include.
2. Run `./file2md.sh` from your project root.
3. The script will:
   - Process your files according to the specifications
   - Generate a formatted Markdown file at `file2md/output.md`
   - Copy the content to your clipboard (if `pbcopy` is available)
   - Display a summary of what it processed

### The files.txt conventions

The `files.txt` input file follows these conventions:

- Lines starting with `#` are treated as comments and ignored.
- Lines starting with `## ` are treated as Markdown H2 headers and included in the output.
- Other lines are interpreted in the following ways:
  - If the line is a valid file path, the file's content is added to the output as a code block.
  - If the line is a valid directory path, the directory's contents are processed.
  - Otherwise, the line is included verbatim in the output.

File and directory paths support various flags:

```
path/to/dir                # Process directory non-recursively
"path with spaces/dir/" -r # Process directory recursively (quoted)
path/to/dir -t             # Show directory tree structure (non-recursive)
path/to/dir -t -r          # Show directory tree structure (recursive)
path/to/dir -e "*.log"     # Exclude files matching PATTERN (local)
path/to/dir -r -e build/ --exclude "*.tmp" # Combine flags
"app/[param]/page.js"      # Quote paths with special characters like [] or ()
```

**Important**: Paths containing special characters (like square brackets, parentheses, or spaces) must be quoted with single or double quotes to prevent shell interpretation.

### The .file2mdignore

The `.file2mdignore` file uses `.gitignore` syntax to specify global patterns to exclude:

- Patterns are relative to the project root.
- Comment lines (starting with `#`) are ignored.
- The default `.file2mdignore` excludes common patterns like `.git/`, `node_modules/`, `.DS_Store`, etc.

## Examples

Refer to the `docs/examples` directory for sample usage scenarios and configuration examples.

## Next steps

- [ ] Get rid of brackets in files.txt
