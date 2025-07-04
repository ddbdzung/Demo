# 🤖 Renovate Guide (Setup + pnpm Optimizations)

This document combines the original _Renovate Setup Guide_ and _Renovate pnpm Optimizations_ into a single, consolidated reference for automated dependency management in this NestJS pnpm workspace.

---

## 📋 Table of Contents

- [What is Renovate?](#what-is-renovate)
- [Setup Instructions](#setup-instructions)
- [Configuration Overview](#configuration-overview)
- [pnpm-Specific Optimizations](#pnpm-specific-optimizations)
- [Understanding Renovate PRs](#understanding-renovate-prs)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Best Practices](#best-practices)
- [Support](#support)

---

## What is Renovate?

Renovate is a dependency-management bot that automatically scans your repository, detects outdated dependencies, and opens pull requests to update them. It supports **grouped updates, smart scheduling, conventional commits, and security-focused workflows**, dramatically reducing manual maintenance overhead.

### Key Benefits

- **Automated Updates** – forget manual version bumps
- **Security** – fast vulnerability patches
- **Grouped PRs** – related packages updated together
- **Smart Scheduling** – updates run during off-hours
- **Conventional Commits** – respects your commit style

---

## Setup Instructions

### 1. Install Renovate

**Recommended (GitHub App)**
1. Visit the [Renovate App](https://github.com/apps/renovate)
2. Click **Install**
3. Select your organisation/repository
4. Grant required permissions

**Self-hosted (GitHub Action)**
1. Create a **PAT** with `repo` scope
2. Add it as secret `RENOVATE_TOKEN`
3. Add a workflow that invokes `renovate/renovate` on a schedule

### 2. Validate Configuration

```bash
pnpm renovate:validate
```

### 3. First Run

After installation Renovate will:
1. Open a **Dependency Dashboard** issue
2. Scan dependencies & lock-file
3. Raise initial PRs for everything outdated

---

## Configuration Overview

Our `renovate.json` is optimised for **pnpm workspaces** and includes:

| Feature | Behaviour |
|---------|-----------|
| **Scheduling** | Weekday 22:00-05:00, weekends anytime (Asia/Ho_Chi_Minh) |
| **Package Groups** | NestJS, TypeScript, ESLint, Jest, SWC, Prettier, Git hooks, pnpm |
| **Auto-merge** | Dev-deps: patch/minor, Prod-deps: patch, Security: all |
| **Commit Style** | Conventional Commits e.g. `chore(deps): update typescript to 5.8.4` |

---

## pnpm-Specific Optimizations

> Extracted from the original *Renovate pnpm Optimizations* document.

1. **Package Manager Declaration**
   ```json
   "packageManager": "pnpm",
   "enabledManagers": ["npm"],
   "constraints": { "pnpm": ">=10.0.0" },
   "postUpdateOptions": ["pnpmDedupe"]
   ```
2. **Enhanced Package Grouping** – adds SWC, Prettier, Git-hooks, pnpm groups for cleaner PRs
3. **Lock-file Maintenance** – weekly `pnpm-lock.yaml` upkeep with dedicated branch naming
4. **Node Engine Constraints** – enforces `>=20.0.0`, follows *current* Node support policy
5. **Ignore Paths** – skips `dist/`, `coverage/`, `*.tsbuildinfo`, etc.

---

## Understanding Renovate PRs

| PR Type | Example |
|---------|---------|
| **Grouped** | `chore(deps): update NestJS packages` |
| **Individual** | `chore(deps): update typescript to 5.8.4` |
| **Security** | `chore(deps): update lodash to 4.17.21 [SECURITY]` |
| **Lock-file** | `chore(deps): lock file maintenance` |

**CI Workflow**: PRs trigger tests; eligible ones are auto-approved & auto-merged, majors always need manual review.

---

## Troubleshooting

| Symptom | Resolution |
|---------|------------|
| Renovate not creating PRs | Verify app permissions & check Dependency Dashboard |
| CI failures on Renovate PRs | Fix pipeline & push; Renovate will rebase |
| Too many PRs | Adjust `prConcurrentLimit` or add `schedule` rules |
| Config errors | `pnpm renovate:validate` or `npx jsonlint renovate.json` |

---

## Advanced Configuration

Examples:

### Add Package Group
```json
{
  "packageRules": [{
    "description": "Database",
    "groupName": "Database",
    "matchPackagePatterns": ["prisma", "typeorm", "mongoose"],
    "commitMessageTopic": "database packages"
  }]
}
```

### Ignore Dependency
```json
{
  "ignoreDeps": ["package-name", "@scope/package-name"]
}
```

### Custom Schedule
```json
{
  "schedule": ["after 10pm on friday"],
  "timezone": "America/New_York"
}
```

---

## Best Practices

1. Monitor the **Dependency Dashboard** weekly
2. Maintain strong test coverage to catch breaking changes
3. Treat major upgrades as mini-projects – allocate time for review
4. Keep `renovate.json` up-to-date with team conventions

---

## Support

1. `pnpm renovate:validate`
2. Check Dependency Dashboard issue
3. Review Renovate logs in GitHub App
4. Official docs: <https://docs.renovatebot.com/> 
