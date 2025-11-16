# Running & Maintaining the Built React App

This `README.md` was generated from our interactive session. It collects: how to run the production build found in this folder, diagnosis of the `http-server` 404 you saw, SPA routing notes, quick Docker example, and guidance + commands to lint/format/remove-unused-imports in the *project source* (not included in this folder).

## What is in this folder

This folder contains a production build output created by `react-scripts build` (or an equivalent bundler). Typical files you should see here:

- `index.html`
- `asset-manifest.json`
- `manifest.json`
- `robots.txt`
- `_redirects` (optional; useful for SPA on some hosts)
- `static/` (contains hashed `js` and `css` files)

This README assumes these static files are present in this `build` folder.

## Quick local preview (PowerShell)

Pick one of these approaches depending on your goal.

1) Simple — serve the current folder with `http-server` (if you're already inside this `build` folder):

```powershell
# from inside this folder (where README.md and index.html live)
npx http-server . -p 8080 -o
```

2) If you are in the parent folder and want to serve `build` explicitly:

```powershell
cd 'D:\Reactler Developer\reusable-artifacts\reactjs-docker-template-aws\devops-build'
npx http-server ./build -p 8080 -o
```

3) SPA-friendly (recommended for apps using client-side routing like react-router):

```powershell
# serves with fallback to index.html
npx serve -s build -l 8080
```

4) Quick Python HTTP server (no SPA fallback):

```powershell
python -m http.server 3000 --directory build
```

5) Quick Docker (nginx) — bind-mount this folder into nginx:

```powershell
# from this build folder (PowerShell) — ensure Docker Desktop has access to this path
docker run --rm -p 8080:80 -v "${PWD}:/usr/share/nginx/html:ro" nginx:alpine
```

Open `http://localhost:8080` (or `http://127.0.0.1:8080`) in your browser.

Notes:
- The repeated `GET /` 404 you saw earlier was caused by running `npx http-server ./build` while already inside the `build` folder — that attempts to serve `build/build` (which doesn't exist). Use `npx http-server .` when you're inside the folder or point `http-server` at the correct folder from the parent.
- The Node deprecation warning about `OutgoingMessage.prototype._headers` is benign for serving and comes from the `http-server` package internals.

## SPA routing and refresh/404s

- If your React app uses client-side routes (react-router), you must ensure unknown paths are served with `index.html` so client-side routing can handle the URL.
- Use `serve -s build` (above) or configure your web server (nginx, Apache, S3 + CloudFront, or your hosting provider) to rewrite unknown routes to `/index.html`.
- Some hosts (Netlify, Vercel) let you add a `_redirects` file or platform-specific configuration to enable this behavior.

## Linting / formatting / removing unused imports (source-level tasks)

This folder contains only the built output; it does not include `src/`, `package.json`, or other source files. The lint/format steps below must be run in your project root (the folder that contains `package.json` and `src/`).

Recommended dev dependencies (run in project root):

```powershell
npm install -D eslint prettier eslint-config-prettier eslint-plugin-prettier eslint-plugin-unused-imports
# If TypeScript is used, also:
npm install -D @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

Minimal `.eslintrc.json` (example) — save in your project root:

```json
{
  "root": true,
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
    "ecmaFeatures": { "jsx": true }
  },
  "env": { "browser": true, "node": true, "es6": true },
  "extends": ["eslint:recommended", "plugin:react/recommended", "prettier"],
  "plugins": ["prettier", "unused-imports"],
  "rules": {
    "prettier/prettier": "error",
    "no-unused-vars": "off",
    "unused-imports/no-unused-imports": "error",
    "unused-imports/no-unused-vars": ["warn", { "vars": "all", "varsIgnorePattern": "^_", "args": "after-used", "argsIgnorePattern": "^_" }]
  },
  "settings": { "react": { "version": "detect" } }
}
```

If you use TypeScript, set `parser` to `@typescript-eslint/parser` and extend `plugin:@typescript-eslint/recommended`.

Minimal `.prettierrc`:

```json
{
  "printWidth": 100,
  "singleQuote": true,
  "trailingComma": "es5",
  "semi": true
}
```

Package.json script snippets (add to `scripts` in `package.json`):

```json
{
  "scripts": {
    "lint": "eslint \"src/**/*.{js,jsx,ts,tsx}\"",
    "lint:fix": "eslint \"src/**/*.{js,jsx,ts,tsx}\" --fix",
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "clean:imports": "eslint \"src/**/*.{js,jsx,ts,tsx}\" --fix"
  }
}
```

Commands to run from your project root:

```powershell
npm run lint:fix
npm run format
```

Notes on removing unused imports:
- `eslint-plugin-unused-imports` will remove unused import lines when you run `--fix`.
- For TypeScript, `tsc --noEmit` with `noUnusedLocals` turned on will help detect unused locals, but removal is usually done with eslint/IDE quick fixes.
- VS Code: use "Source Action → Organize Imports" or enable "Format on Save" and appropriate ESLint fixes.

## Todo summary (session-derived)

- Diagnose http-server 404 — completed
- Provide corrected run commands — completed
- Explain deprecation and SPA routing — completed
- Locate source files — completed (only `build` output found in this workspace)
- Run or instruct lint/format/cleanup — instructions included below; cannot run here because source not present
- Provide quick README with commands — completed (this file)

## Verification / How to confirm it's working

1. Run one of the server commands above. Example (from the build folder):

```powershell
npx http-server . -p 8080 -o
```

2. In a browser go to `http://localhost:8080`.
3. If you see a 404, check that `index.html` is present in the folder you're serving. If you're using client-side routes and deep-linking, instead use the `serve -s build` option.

## Next steps I can help with

- If you open the project root (the folder containing `package.json` and `src/`) in this workspace I can:
  - add the ESLint / Prettier config files automatically,
  - run `npm install` and execute `npm run lint:fix` and `npm run format`,
  - create a small `Dockerfile` and `docker-compose.yml` to run this build via nginx.

- Or I can produce those files here and show you how to move them into the project root.

---

If you want the ESLint/Prettier files created in a specific location or a Dockerfile to serve `build` via nginx, tell me where and I will create them next.