# LLM Prompt Annotations Example

This example demonstrates how to use file2md to include detailed instructions and prompts for an LLM directly within your Markdown output.

## What This Example Shows

- Using verbatim text in `files.txt` to create context and instructions for the LLM
- Interweaving file content with explanatory text
- Structuring a complete prompt with both code and instructions
- Adding specific questions for the LLM to focus on

## How It Works

1. Any line in `files.txt` that isn't recognized as a file or directory path is included verbatim in the output
2. Lines starting with `## ` are formatted as Markdown headers
3. Other text lines are included as plain text
4. This allows you to mix file contents with instructions, context, and questions

## Usage

To apply this technique to your own project:

1. Create a `files.txt` in your project's `file2md` directory
2. Add explanatory text and instructions directly in the file
3. Mix this text with file paths to include your code
4. Add specific questions or points to focus on
5. Run `./file2md.sh` from your project root

This approach is extremely powerful for crafting effective LLM prompts because:

1. You provide clear instructions about what you want the LLM to do
2. You include only the relevant files, reducing noise
3. You add context around each file or group of files
4. You guide the LLM with specific questions to focus on

The result is more targeted, more helpful responses from the LLM because it has both the code it needs to analyze AND clear instructions about what you're looking for.