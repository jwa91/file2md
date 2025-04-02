# Example Project Structure

This is a project structure for demonstrating the tree view functionality:

```
my-project/
├── README.md
├── file2md/
│   ├── .file2mdignore
│   ├── files.txt
│   └── output.md
├── package.json
├── src/
│   ├── index.js
│   ├── components/
│   │   ├── Button.js
│   │   ├── Card.js
│   │   ├── Form/
│   │   │   ├── Form.js
│   │   │   ├── Input.js
│   │   │   └── Select.js
│   │   └── Layout/
│   │       ├── Header.js
│   │       ├── Footer.js
│   │       └── Sidebar.js
│   ├── utils/
│   │   ├── formatting.js
│   │   └── validation.js
│   └── styles/
│       ├── global.css
│       └── components.css
└── test/
    ├── unit/
    │   └── components/
    │       └── Button.test.js
    └── integration/
        └── api.test.js
```