# Combined File2md Techniques Example

This example demonstrates how to combine multiple file2md techniques in a single configuration to create a comprehensive code overview for an LLM.

## What This Example Shows

- How to combine multiple file2md features in one configuration
- Balancing complete directory scans with selective file inclusion
- Using tree views for structural context and file content for details
- Using both global and local ignore patterns
- Organizing the output in a logical sequence for LLM context building
- Adding explanatory text directly in the output

## How It Works

This example combines:

1. **Plain text** - Adding explanatory comments directly in the output
2. **Individual files** - Including specific, key files
3. **Directory trees** - Showing structural context with `-t` flags
4. **Recursive scanning** - Processing entire directories with `-r`
5. **Global ignores** - Using `.file2mdignore` for broad exclusions 
6. **Local ignores** - Using `-e` flags for targeted exclusions
7. **Sectioning** - Using `## Headers` to organize the content

## Usage

To apply these combined techniques to your own project:

1. Create a `.file2mdignore` file in your project's `file2md` directory for global exclusions
2. Create a comprehensive `files.txt` that combines:
   - Explanatory text
   - Section headers
   - Individual file paths
   - Directory tree views with `-t`
   - Recursive directory scans with `-r`
   - Local exclusion patterns with `-e`
3. Organize them in a logical sequence that builds context
4. Run `./file2md.sh` from your project root

The resulting Markdown will be organized into sections:

1. Project overview with key files
2. Tree views of the directory structure
3. Core code files
4. Component examples
5. Styles
6. Documentation
7. Tests (both tree view and specific files)

This comprehensive approach provides the perfect balance of:
- Context (directory structure and organization)
- Core code (key files that need detailed attention)
- Documentation (to understand the project's purpose)

By strategically combining these techniques, you can create an optimal code context for LLM analysis that neither overwhelms the model with irrelevant details nor leaves out critical context.