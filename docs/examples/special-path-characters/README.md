# Special Path Characters Example

This example demonstrates how to handle paths that contain special characters, such as the square brackets `[]` and parentheses `()` commonly used in Next.js app router.

## What This Example Shows

- How to handle paths with square brackets `[]` (e.g., Next.js dynamic routes)
- How to handle paths with parentheses `()` (e.g., Next.js route groups)
- Proper quoting of paths with special characters
- Handling tree views of directories containing paths with special characters

## Special Character Handling in file2md

1. **Shell Interpretation**: Characters like `[]`, `()`, `{}`, `*`, and `?` have special meaning in shell environments and can cause issues when used in paths.

2. **Solution - Quoting Paths**:
   - Paths containing special characters MUST be quoted using either single (`'path/with/[special]/chars'`) or double quotes (`"path/with/[special]/chars"`)
   - Quoting prevents the shell from interpreting these special characters before file2md can process them
   - Inside file2md, the script properly escapes these characters when needed for commands like `find` and `tree`

3. **When Quotes Are Needed**:
   - Any path containing: `[]`, `()`, `{}`, `*`, `?`, or spaces
   - Example: `"app/blog/[slug]/page.js"` instead of `app/blog/[slug]/page.js`
   - Example: `"app/dashboard/(auth)/login/page.js"` instead of `app/dashboard/(auth)/login/page.js`

4. **Directory Trees**:
   - When using `-t` for tree views, quote the parent directory if any part of its path or subdirectories contains special characters
   - Example: `"app/blog" -t -r` (because it contains `[slug]` subdirectory)

## Usage

To apply this technique to your own project:

1. Create a `files.txt` in your project's `file2md` directory
2. Add paths to files with special characters, making sure to quote them
3. For any directory containing special characters (or having subdirectories with special characters), use quotes when including it
4. Run `./file2md.sh` from your project root

This approach is essential for working with modern framework structures like Next.js app router, where dynamic routes with `[parameters]` and route groups with `(groupName)` are common patterns.