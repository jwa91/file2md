# Example Project Structure

This is a comprehensive project structure for demonstrating multiple file2md techniques combined:

```
my-project/
├── README.md
├── CONTRIBUTING.md
├── package.json
├── file2md/
│   ├── .file2mdignore
│   ├── files.txt
│   └── output.md
├── src/
│   ├── index.js
│   ├── config/
│   │   ├── default.js
│   │   └── production.js
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.js
│   │   │   ├── Input.js
│   │   │   └── Modal.js
│   │   └── pages/
│   │       ├── Home.js
│   │       ├── About.js
│   │       └── Contact.js
│   ├── utils/
│   │   ├── formatting.js
│   │   ├── validation.js
│   │   ├── api.js
│   │   └── testing/
│   │       ├── mocks.js
│   │       └── helpers.js
│   └── styles/
│       ├── global.css
│       ├── variables.css
│       └── components/
│           ├── button.css
│           └── modal.css
├── docs/
│   ├── api.md
│   └── architecture.md
├── test/
│   ├── unit/
│   │   ├── utils/
│   │   │   └── validation.test.js
│   │   └── components/
│   │       └── Button.test.js
│   └── integration/
│       └── api.test.js
└── build/
    └── bundle.js
```