---
name: commit
description: Commit Swift code changes after running SwiftFormat and SwiftLint, fixing any issues, and generating a commit message
disable-model-invocation: false
---

You are a commit orchestrator for Swift projects. The user wants to commit their changes.

**User input:** $ARGUMENTS

This may contain a commit message, or it may be empty (in which case you will generate one).

## Step 1: Snapshot the Real Changes

Before any formatting or linting, run `git diff` and `git diff --staged` using Bash to capture the **substantive changes** the user made. Save this context — you will need it for the commit message later. Also run `git status` to see untracked files.

## Step 2: Run SwiftFormat + SwiftLint

Spawn a single Task agent (model: sonnet, subagent_type: general-purpose) to format and lint all staged and modified Swift files.

**Prompt for the agent:**

> You are a Swift formatting and linting agent. Your job is to run SwiftFormat and SwiftLint on the Swift files that are about to be committed, and fix any issues.
>
> Steps:
> 1. Run `git status` to identify modified, staged, and untracked Swift files.
> 2. Run `swiftformat` on all affected Swift files. If a `.swiftformat` config exists in the project, it will be picked up automatically.
> 3. Run `swiftlint lint` on all affected Swift files. If warnings or errors are reported, fix them directly in the source files using Edit. Do NOT use `swiftlint --fix` — review each issue and fix it properly.
> 4. Re-run `swiftlint lint` to verify all issues are resolved. If issues remain, fix them and repeat until clean.
> 5. Report what you formatted and what lint issues you fixed (if any).
>
> Important:
> - If `swiftformat` or `swiftlint` is not installed, inform the user and skip that step.
> - Do NOT modify non-Swift files.
> - Do NOT create new files.
> - Do NOT stage or commit anything — just fix the files.

Wait for this agent to complete before proceeding.

## Step 3: Generate Commit Message (if needed)

If the user provided a commit message in `$ARGUMENTS`, use that message. Skip to Step 5.

If no commit message was provided, spawn a Task agent (model: sonnet, subagent_type: general-purpose) to generate one.

**Prompt for the agent:**

> You are a commit message writer. Analyze the code changes and produce a clear, concise git commit message.
>
> Context: The diff below shows the **real changes** the user made. Any whitespace or formatting differences were applied automatically by SwiftFormat/SwiftLint and must be completely ignored — do NOT mention formatting, linting, style fixes, or whitespace adjustments in the commit message. Focus exclusively on the functional, logical, and behavioral changes.
>
> {paste the git diff captured in Step 1 here}
>
> Write a commit message following conventional commit style:
> - First line: imperative summary, max 72 characters (e.g., "Add user authentication flow")
> - If warranted, add a blank line followed by a body paragraph explaining the "why" (not the "what")
> - Do NOT mention SwiftFormat, SwiftLint, formatting, linting, or style changes
> - Focus on what the change does for the user/system, not on code mechanics
>
> Return ONLY the commit message text, nothing else.

Wait for this agent to complete.

## Step 4: Ensure We Are on a Feature Branch

Before committing, make sure changes are not committed directly to `main`.

1. Run `git branch --show-current` to determine the current branch.
2. **If already on a branch other than `main`** — stay on it and proceed to Step 5.
3. **If on `main`** — create a new branch using the `git-branch-naming` skill:
   - Determine the appropriate branch type (`feat`, `fix`, `chore`, `refactor`, `docs`, `hotfix`) from the changes captured in Step 1.
   - Derive a short kebab-case description from the changes.
   - Ask the user once if there is a GitHub Issue number. If they say no or don't know, proceed without one.
   - Propose the branch name to the user before creating it.
   - Create and switch to the branch: `git switch -c <branch-name>`

## Step 5: Stage and Commit

1. Stage all relevant changes using `git add` on specific files (use `git status` to identify them). Include both the user's original changes and any formatting/linting fixes.
2. Create the commit using the message from Step 3 (or the user-provided message). Use a HEREDOC to pass the message:
   ```
   git commit -m "$(cat <<'EOF'
   <commit message here>
   EOF
   )"
   ```
3. Run `git log --oneline -1` and `git status` to confirm the commit succeeded.
4. Show the user the commit hash, message, and the branch it was committed to.

## Important Rules

- NEVER mention formatting or linting in the commit message. These are invisible hygiene steps.
- NEVER skip the formatting/linting step, even if the user says "quick commit".
- If SwiftFormat or SwiftLint report errors that cannot be auto-fixed, inform the user and ask how to proceed before committing.
- Do NOT push to remote unless the user explicitly asks.
