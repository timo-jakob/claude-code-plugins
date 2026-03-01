---
name: cleanup
description: >
  Cleans up the local git environment after merging a branch to main.
  Prunes stale remote-tracking branches and deletes local branches that
  are already merged into main. Run this after a PR is merged.
---

You are a git cleanup orchestrator. The user wants to tidy up their local repository after merging a branch to main.

## What this skill does

1. Switches to `main` (if not already there)
2. Pulls the latest `main` from origin
3. Prunes stale remote-tracking branches (`git fetch --prune`)
4. Deletes local branches that are already merged into `main`

## Step 1: Locate the cleanup script

Use Glob to find `cleanup.sh` inside the skill's `scripts/` directory (it lives at `scripts/cleanup.sh` relative to this SKILL.md file inside the installed plugin). Search for `**/development/skills/cleanup/scripts/cleanup.sh` across common plugin locations:

- `~/.claude/plugins/**/development/skills/cleanup/scripts/cleanup.sh`
- `~/.claude/**/cleanup/scripts/cleanup.sh`
- Any path matching `**/timos-claude-code-plugins/development/skills/cleanup/scripts/cleanup.sh`

If the script is found, proceed to Step 2. If it cannot be located, fall back to Step 3.

## Step 2: Run the cleanup script

Make the script executable and run it from the **user's current working directory** (not the plugin directory):

```bash
chmod +x <path-to-cleanup.sh>
<path-to-cleanup.sh>
```

Capture and display the full output to the user. If the script exits with a non-zero status, report the error clearly and stop.

## Step 3: Fallback — run cleanup commands directly

If the script cannot be found, execute the following commands sequentially using the Bash tool, reporting progress after each step:

1. **Check we are in a git repo**
   ```bash
   git rev-parse --is-inside-work-tree
   ```
   If this fails, tell the user they are not inside a git repository and stop.

2. **Switch to main**
   ```bash
   git checkout main
   ```

3. **Pull latest main**
   ```bash
   git pull origin main
   ```

4. **Prune stale remote-tracking branches**
   ```bash
   git fetch --prune
   ```

5. **Delete merged local branches**
   ```bash
   git branch --merged main \
     | grep -vE '^(\*|  (main|master|develop|staging|release/.+))$' \
     | xargs -r git branch -d
   ```
   If `xargs -r` is not supported (macOS), use:
   ```bash
   MERGED=$(git branch --merged main | grep -vE '^(\*|  (main|master|develop|staging|release/.+))$')
   [ -n "$MERGED" ] && echo "$MERGED" | xargs git branch -d
   ```

## Step 4: Summarise

After all steps complete, show the user a clear summary:

- Which branch they are now on
- How many remote-tracking refs were pruned (if any)
- Which local branches were deleted (if any), or "none" if there were none
- A confirmation that the cleanup is complete

## Important rules

- **Never delete** `main`, `master`, `develop`, `staging`, or any `release/*` branch.
- **Never force-delete** branches (`-D`). Use `-d` only — this is safe and will refuse to delete branches that have unmerged work.
- Do not push anything, create commits, or modify any files in the user's repository.
