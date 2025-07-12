# Versioning & Release Guide

A concise reference for committing, releasing, and maintaining code in this repository.

## Table of Contents
- [Conventional Commits](#conventional-commits)
- [Automated Releases with `pnpm release`](#automated-releases-with-pnpm-release)
- [Git Flow](#git-flow)
- [Best Practices Checklist](#best-practices-checklist)

---

## Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification enforced by **Commitlint**.

**Format**

```
<type>(<scope>): <subject>

<body>          # optional, blank line before
<footer>        # optional, blank line before
```

**Allowed Types**

| type     | when to use                                                     |
|----------|-----------------------------------------------------------------|
| feat     | A new feature                                                   |
| fix      | A bug fix                                                       |
| perf     | A performance improvement                                       |
| refactor | Code change that neither fixes a bug nor adds a feature         |
| docs     | Documentation only changes                                      |
| style    | Formatting, white-space, missing semi-colons…                   |
| test     | Adding or correcting tests                                      |
| chore    | Maintenance tasks (build, tooling, deps)                        |
| ci       | CI/CD related changes                                           |
| revert   | Reverts a previous commit                                       |
| build    | Changes that affect the build system                            |

**Allowed Scopes**

`core`, `modules`, `config`, `deps`, `docs`, `ci`, `dx`

> Tip: keep the subject imperative and under 72 characters.

Example:

```
feat(core): add pagination to user service
```

---

## Automated Releases with `pnpm release`

We delegate releases to [`standard-version`](https://github.com/conventional-changelog/standard-version) via the convenience script:

```jsonc
"scripts": {
  "release": "standard-version"
}
```

Running `pnpm release` will:

1. Read the commit history since the last tag.
2. Decide the next **semver** bump (`major` / `minor` / `patch`).
3. Update `version` in `package.json`.
4. Append a new section to `CHANGELOG.md`.
5. Commit with message `chore(release): vX.Y.Z` and tag `vX.Y.Z`.

### Typical Flow

```bash
# make sure your branch is up-to-date
git pull --rebase origin master

# verify tests & linters
pnpm test

# preview the release (no files touched)
pnpm release -- --dry-run

# perform the real release
pnpm release

# push commit and tag
git push --follow-tags origin master
```

---

## Git Flow

We keep the workflow intentionally minimal:

1. **Branches**
   • `master` (or `main`) – always releasable  
   • short-lived feature / fix branches (prefix with your initials if desired)

2. **Feature work**
   - Branch from `master`.
   - Commit using Conventional Commits.
   - Open a PR; squash & merge once approved.

3. **Releases**
   - Only from an up-to-date `master`.
   - Never commit directly to tagged releases; use normal commits and rerun `pnpm release` if needed.

4. **Hotfixes**
   - Branch from the tagged commit, fix, release, merge back.

---

## Best Practices Checklist

- Commits:
  - Use the correct **type**/**scope** and imperative mood.
  - Keep subjects ≤ 72 chars; wrap body at 100 chars.
- Pull Requests:
  - Keep them focused; squash merge to maintain linear history.
  - Ensure CI is green before merging.
- Releases:
  - Always run `pnpm release -- --dry-run` first.
  - Push with `--follow-tags` so CI picks up the tag.
- Tags:
  - Never edit or delete tags after publishing; create a new patch version instead.

---

Happy coding! 
