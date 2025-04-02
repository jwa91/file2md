# Example Project Structure

This is a project structure for demonstrating the use of ignore patterns:

```
my-project/
├── README.md
├── file2md/
│   ├── .file2mdignore  # Custom ignore patterns added here
│   ├── files.txt
│   └── output.md
├── package.json
├── package-lock.json
├── node_modules/       # Would normally contain thousands of files
│   └── ...
├── src/
│   ├── index.js
│   ├── config.js
│   ├── utils.js
│   └── temp/          # Temporary development files
│       ├── debug.js
│       └── scratch.js
├── dist/              # Built files
│   ├── bundle.js
│   └── bundle.js.map
└── logs/
    ├── error.log
    ├── access.log
    └── debug.log
```