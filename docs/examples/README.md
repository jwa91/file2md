# File2md Examples

This directory contains practical examples demonstrating how to use the file2md tool for different scenarios.

## Available Examples

### [Basic File2md Usage](./basic-file2md-usage)
This example shows the fundamental usage of file2md to include individual files in your Markdown output.

### [Recursive Directory Scan](./recursive-directory-scan)
Learn how to recursively process entire directories to include all files in subdirectories.

### [Tree View Example](./tree-view-example)
Shows how to include directory tree visualizations alongside file contents to provide structural context.

### [Using Ignore Patterns](./using-ignore-patterns)
Demonstrates how to use both global and local ignore patterns to exclude specific files and directories from processing.

### [Custom Input File](./custom-input-file)
Shows how to use custom input files instead of the default `files.txt` for different documentation needs.

### [LLM Prompt Annotations](./llm-prompt-annotations)
Illustrates how to include instructions, context, and questions for an LLM directly in your output.

### [Combined Techniques](./combined-techniques)
Demonstrates how to combine multiple file2md features in a single configuration for comprehensive code context.

### [Special Path Characters](./special-path-characters)
Shows how to handle paths containing special characters like square brackets and parentheses (e.g., Next.js app router).

## How to Use These Examples

Each example directory contains:

1. `README.md` - Detailed explanation of the example and what it demonstrates
2. `example-projectstructure.md` - A sample project structure for context
3. `file2md/files.txt` (and sometimes `file2md/.file2mdignore`) - Example configuration files

These examples are meant as **inspiration only** - your actual project structure will be different, and you'll need to create your own configuration files based on your specific needs.

To apply what you learn from these examples:

1. Review the example READMEs to understand the different file2md features
2. Create your own `files.txt` in your project's `file2md` directory using similar patterns
3. Run file2md from your project root:
   ```
   ./file2md.sh
   ```
   
   Or with custom input file options:
   ```
   ./file2md.sh -f path/to/custom-files-list.txt
   ```

The examples demonstrate different techniques that you can mix and match to create the perfect configuration for your specific project.