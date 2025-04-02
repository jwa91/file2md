# Example Project Structure

This is a project structure for demonstrating the use of custom input files:

```
my-project/
├── README.md
├── file2md/
│   ├── .file2mdignore
│   ├── files.txt          # Default input file
│   └── output.md          # Default output file
├── doc-configs/
│   ├── api-files.txt      # Custom input file for API documentation
│   ├── component-files.txt # Custom input file for component documentation
│   └── test-files.txt     # Custom input file for test documentation
├── package.json
├── src/
│   ├── index.js
│   ├── api/
│   │   ├── users.js
│   │   └── products.js
│   ├── components/
│   │   ├── Button.js
│   │   └── Card.js
│   └── utils/
│       ├── formatting.js
│       └── validation.js
└── test/
    ├── api/
    │   ├── users.test.js
    │   └── products.test.js
    └── components/
        ├── Button.test.js
        └── Card.test.js
```