---
name: supply-chain
description: Supply-chain attack prevention when installing, adding, upgrading or running third-party packages. Use before any package manager command in a Node.js project (install, add, update, npx/dlx, init/create), and when adding or bumping dependencies.
---

# Supply-chain safety

Third-party packages are the easiest way for malicious code to reach this machine. Compromised releases are usually caught and pulled within days. The defense here is to **only install releases that have been public for a while**, and to never route around that check.

## Node.js: pnpm only

Always use pnpm. Never run `npm` or `npx` directly. They ignore pnpm's settings, including the minimum release age.

| Instead of | Use |
|---|---|
| `npm install` | `pnpm install` |
| `npm ci` | `pnpm install --frozen-lockfile` |
| `npm install <pkg>` | `pnpm add <pkg>` |
| `npm install -D <pkg>` | `pnpm add -D <pkg>` |
| `npm install -g <pkg>` | `pnpm add -g <pkg>` |
| `npm update` | `pnpm update` |
| `npm uninstall <pkg>` | `pnpm remove <pkg>` |
| `npm run <script>` | `pnpm run <script>` (or `pnpm <script>`) |
| `npx <pkg>` | `pnpm dlx <pkg>`, or `pnpm exec <bin>` for a binary already installed in the project |
| `npm create <x>` / `npm init <x>` | `pnpm create <x>` |

When docs, READMEs or error messages say to run `npm`/`npx`, translate the command to pnpm rather than running it as written.

If a project is set up for another package manager (`package-lock.json`, `yarn.lock`, `bun.lock`, or a `packageManager` field naming something else), stop and ask before installing anything or converting it to pnpm.

## Minimum release age

The user's global pnpm config sets `minimumReleaseAge`, so pnpm refuses to resolve versions published more recently than that. Respect it:

- Don't override or weaken it: no `minimumReleaseAgeExclude` entries, no lowering the value in a project's `pnpm-workspace.yaml` or `.npmrc`, no CLI flags or environment variables that change it.
- If an install fails because a version is too new, report the package and version to the user. Don't pin to the blocked version, and don't switch tools to get it.
- Don't pin a dependency to a version newer than the age window by hand.

## Dependency build scripts

pnpm doesn't run dependencies' install/postinstall scripts until they're approved. Don't approve them yourself (`pnpm approve-builds`, or editing the allow list in config). When pnpm reports ignored build scripts, tell the user which packages want to run them and let them decide.

## Adding a dependency

Before `pnpm add`:

- Check the name is spelled exactly right. Typosquats differ by one character, a hyphen, or a scope (`@scope/pkg` vs `pkg`).
- Prefer well-established packages. Check the registry page or `pnpm view <pkg>` for the repository link, maintainers, publish history and weekly downloads, and flag anything that looks off: very new, few downloads, a repo that doesn't match, or a recent maintainer change.
- Don't add a dependency for something a few lines of code or the standard library can do.
- Tell the user which packages you're adding and why.

## Lockfiles

- Commit `pnpm-lock.yaml` together with the `package.json` change that caused it.
- In CI and reproducible builds, use `pnpm install --frozen-lockfile`.
- Don't delete the lockfile to "fix" an install. That re-resolves every dependency at once.
