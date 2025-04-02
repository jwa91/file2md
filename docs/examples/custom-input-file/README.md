# Custom Input File Example

This example demonstrates how to use a custom input file instead of the default `files.txt`.

## What This Example Shows

- Using the `-f` command-line option to specify a custom input file
- Creating purpose-specific file lists for different documentation needs
- Organizing your documentation workflow for different aspects of your project

## How It Works

1. Instead of using the default `file2md/files.txt`, you create specialized file lists in any location
2. When running file2md, you use the `-f` flag to specify which input file to use
3. This allows you to maintain multiple different file lists for different documentation needs

## Usage

To apply this technique to your own project:

1. Create specialized file lists in any location of your choice (e.g., `doc-configs/api-files.txt`)
2. Format them using the same syntax as the regular `files.txt`
3. Run file2md with the `-f` flag pointing to your custom file:
   ```
   ./file2md.sh -f doc-configs/api-files.txt
   ```
4. Optionally specify a custom output file as well:
   ```
   ./file2md.sh -f doc-configs/api-files.txt -o docs/api-documentation.md
   ```

This approach is useful for maintaining different documentation configurations for different purposes. For example:

- API documentation for backend developers
- Component documentation for frontend developers
- Test documentation for QA engineers
- Architecture overview for new team members

Each can have its own input file with the appropriate selection of files and directories.