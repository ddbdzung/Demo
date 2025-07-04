# NestJS CRUD API

> **RESTful boilerplate for NestJS 11.x**

---

## 📑 Project Overview

This repository hosts a boilerplate **NestJS 11.x CRUD API** ready for production-grade development. It comes pre-configured with strict TypeScript settings, hot-reload, comprehensive testing, code-style enforcement, conventional commits, and automated release tooling.

---

## ⚙️ Prerequisites

| Tool | Version |
|------|---------|
| Node | `20.19.2` |
| pnpm | `10.12.4` |
| Git  | `≥ 2.40` |

```bash
# Install the required Node & pnpm versions if you use Corepack
corepack enable && corepack prepare pnpm@10.12.2 --activate
nvm use 20.19.2   # or your preferred Node version manager
```

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
pnpm install

# 2. Start the API in watch-mode
pnpm dev

# 3. Open http://localhost:3000
```

Husky hooks are installed automatically after `pnpm install`. If they are missing, run:

```bash
pnpm husky install
```

---

## 📜 Project Scripts

| Script | Purpose |
|--------|---------|
| `pnpm dev` | Hot-reload Nest server |
| `pnpm build` | Compile TypeScript → `dist/` |
| `pnpm test` | Run unit tests with Jest |
| `pnpm test:e2e` | End-to-end tests via SuperTest |
| `pnpm lint` | ESLint analysis |
| `pnpm format` | Prettier write |
| `pnpm commit` | Interactive Conventional Commit flow (Commitizen) |
| `pnpm release` | Bump version & generate CHANGELOG |

---

## 📦 Dev-Dependency Handbook

### 1. TypeScript & Build

| Package | Role |
|---------|------|
| `typescript`, `ts-node`, `ts-loader` | Core compilation & loader |
| `@swc/cli`, `@swc/core` | Ultra-fast transpiler leveraged by Nest build |

Config files: `tsconfig.json`, `.swcrc`.

### 2. Linting & Formatting

| Package | Reason |
|---------|--------|
| `eslint`, `@eslint/js`, `@eslint/eslintrc`, `typescript-eslint` | Base ESLint rules for TS |
| `eslint-config-prettier`, `eslint-plugin-prettier` | Remove conflicts & surface format issues |
| `prettier` | Opinionated formatter (`.prettierrc`) |

> Best practice: run `pnpm lint` or rely on commit hooks to keep code clean.

### 3. Commit Quality & Hooks

| Package | Function |
|---------|----------|
| `husky` | Git hooks (`pre-commit`, `commit-msg`) |
| `lint-staged` | Lint/format only staged files (`.lintstagedrc.js`) |
| `@commitlint/cli`, `@commitlint/config-conventional` | Enforce Conventional Commit style |
| `commitizen`, `cz-conventional-changelog` | Interactive commit flow (`pnpm commit`) |
| _Docs_ | Full commit message guideline: see [`documents/commitlint.md`](documents/commitlint.md) |

### 4. Testing Stack

| Package | Scope |
|---------|-------|
| `jest`, `ts-jest`, `@types/jest` | Unit test runner, TS transformer |
| `supertest`, `@types/supertest` | HTTP assertions for e2e tests |
| `@nestjs/testing` | Nest testing utilities |

Run `pnpm test` (unit) or `pnpm test:e2e` (e2e). Coverage in `coverage/`.

### 5. Release Automation

| Package | Task |
|---------|------|
| `standard-version` | Bump version & generate CHANGELOG |

Workflow:
```bash
pnpm release           # choose a version
# pushes git tag; then
git push --follow-tags
```

### 6. Misc Utilities

| Package | Why |
|---------|-----|
| `globals` | ESLint helper for global vars |
| `source-map-support` | Pretty stack traces in production |

---

## 🔄 Recommended Workflow

1. `git pull --rebase origin master`
2. Create a feature branch, code.
3. `pnpm dev` for live reload.
4. Pre-commit hook auto formats & lints.
5. `pnpm test` for fast feedback.
6. `pnpm commit` → push PR.
7. After merge, run `pnpm release` to publish a new version.

---

## 🛠️ Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Cannot find module '@/...'` | Ensure you executed `pnpm build` once; check `tsconfig.paths`. |
| Husky hooks not firing | `git config core.hooksPath .husky` then `pnpm husky install`. |
| ESLint & Prettier conflict | Rely on `eslint-config-prettier` or run `pnpm format`. |

---

## 🔃 Monthly House-Keeping Checklist

- [ ] `pnpm update -r --latest` – upgrade dev-dependencies.
- [ ] Verify CHANGELOG produced by `standard-version`.
- [ ] Review Husky hooks for new scripts.
- [ ] Run `npx prettier --check` to detect drift in code style.

---

## 📄 License

MIT © Dang Duc B. Dzung (David) 
