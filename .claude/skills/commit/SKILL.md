---
name: commit
description: Commit only the changes this Claude Code session made, split into logical commits when large. Use whenever asked to commit (e.g. "/commit", "commit this", "commit your changes"), or before any git commit made from a session.
argument-hint: "[optional note on what to commit or how to word it]"
---

# Commit policy

A session commits **only the changes it made itself**. Changes already in the working tree from the user, another session, or a tool run outside this session stay uncommitted unless this session's changes genuinely depend on them. Large changes are split into logical commits.

If the user passed arguments (`$ARGUMENTS`), treat them as guidance on scope or wording. They don't override this policy unless they say so explicitly (e.g. "commit everything").

## Branches

- **Personal projects** (the user's own repo, e.g. the remote is under their own GitHub account, with no other contributors): commit straight to `main` and push to `main`. Don't create a feature branch or open a PR.
- **Exception:** experimental work, or a huge feature that may take a while or be abandoned, goes on its own branch. If unsure whether a change qualifies, ask.
- **Other repos** (work, open source, shared): follow the repo's own conventions, which usually means a branch and a PR.

## 1. Work out what this session changed

Build the list from the conversation, not from `git status`:

- Files created or edited with Write/Edit/NotebookEdit.
- Files changed by commands this session ran: formatters, codegen, `sed`/scripts, package installs (lockfiles), migrations, moves and deletes.
- For each of those files, the specific hunks this session wrote. A file this session touched may also hold edits it did not make.

Then compare against the actual state:

```bash
git status --short
git diff            # unstaged
git diff --cached   # already staged
```

Sort every changed hunk into one of three groups:

| Group | Meaning |
|---|---|
| **Mine** | Written by this session. |
| **Foreign** | Present in the tree but not written by this session. |
| **Unsure** | Can't tell (e.g. context was summarized and the detail was lost). |

Treat **Unsure** as **Foreign** unless the user confirms otherwise. Ask when it matters.

## 2. Decide on foreign changes

Include a foreign change only when there is a **genuine dependency**: this session's changes would not build, run, or make sense without it. Examples:

- This session calls a function or imports a module that only exists in the uncommitted foreign change.
- This session edits code that was itself introduced by the uncommitted foreign change.

These are **not** dependencies on their own: the change is in the same file, it's in the same area, it's related, or it would be "nice to ship together".

When a foreign change is included, mention it in the commit body (e.g. "Includes the uncommitted `parseConfig` helper this change depends on") and tell the user. When it's borderline, ask before committing.

## 3. Plan the commits

One commit is fine for a small, single-purpose change. Split when the work contains more than one independent concern, for example:

- Refactor or rename, then a behavior change built on it.
- Feature work plus an unrelated fix noticed along the way.
- Mechanical changes (formatting, generated files, dependency bumps) mixed with hand-written logic.
- Several features, or several subsystems changed for different reasons.

Rules for splitting:

- Each commit is one coherent change that reads well alone in `git log`.
- Order commits so each one builds on the earlier ones. Where practical, each commit should leave the tree building and passing tests.
- Don't split so finely that a commit is meaningless alone (e.g. a function in one commit and its only caller in the next).

If the plan has more than one commit, show the user the plan (commit subjects plus files or hunks in each) before making the commits, unless they already said to go ahead.

## 4. Stage precisely

- Never use `git add -A`, `git add .`, `git commit -a`, or anything else that stages by wildcard.
- Stage whole files by explicit path only when every hunk in the file belongs in this commit.
- For a file with mixed hunks, stage only the right hunks. Interactive `git add -p` isn't available, so build a patch and apply it to the index:

  ```bash
  git diff -- path/to/file > /tmp/partial.patch   # use the scratchpad dir if one exists
  # edit the patch: delete the hunks that don't belong (keep headers intact)
  git apply --cached --recount /tmp/partial.patch
  ```

- New files from this session: `git add path`. Deletions: `git rm path` (or `git add` the deleted path).
- If the index **already** has staged content that isn't part of this commit, don't silently commit it and don't unstage it on your own. Tell the user what's there and ask how to proceed.

Before each commit, check that the staged content is exactly what's intended:

```bash
git diff --cached --stat
git diff --cached
```

## 5. Write the message

- Match the repo's existing style. Check `git log --oneline -15` for format, prefixes (e.g. `feat:`), tense and capitalization.
- With no established style: a short imperative subject (about 50 chars, no trailing period), a blank line, then a body explaining *why* when the reason isn't obvious from the subject.
- Add any commit attribution lines that the environment or the user's instructions ask for.
- Pass multi-line messages with a heredoc so the formatting survives:

  ```bash
  git commit -F - <<'EOF'
  Subject line

  Body explaining why.
  EOF
  ```

Don't use `--no-verify` or skip hooks. If a hook fails, fix the cause and make a new commit. Don't `--amend` a commit this session didn't create.

## 6. Verify and report

After committing:

```bash
git log --oneline -n <number of commits made>
git status --short
```

Then report:

- The commits made: hash and subject.
- Any foreign changes that were included, and why.
- What was left uncommitted: foreign or unsure changes, still in the working tree.

Don't push unless the user asked. In a personal project, pushing means pushing `main` (see **Branches**).
