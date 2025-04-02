# Example Project Structure

This is a project structure for demonstrating how to handle paths with special characters, such as those used in Next.js app router:

```
my-nextjs-project/
├── README.md
├── file2md/
│   ├── .file2mdignore
│   ├── files.txt
│   └── output.md
├── package.json
├── next.config.js
├── app/
│   ├── layout.js
│   ├── page.js
│   ├── about/
│   │   └── page.js
│   ├── blog/
│   │   ├── page.js
│   │   └── [slug]/
│   │       └── page.js
│   ├── products/
│   │   ├── page.js
│   │   └── [productId]/
│   │       ├── page.js
│   │       └── reviews/
│   │           ├── page.js
│   │           └── [reviewId]/
│   │               └── page.js
│   └── dashboard/
│       ├── page.js
│       └── (auth)/
│           ├── login/
│           │   └── page.js
│           └── signup/
│               └── page.js
└── components/
    ├── Header.js
    ├── Footer.js
    └── Navigation.js
```