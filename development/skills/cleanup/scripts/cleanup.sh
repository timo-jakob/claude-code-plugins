#!/usr/bin/env bash
# cleanup.sh — Prune merged remote-tracking branches and delete merged local branches.
# Safe to run after merging a feature branch into main.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()    { echo -e "${BLUE}==> $*${NC}"; }
success(){ echo -e "${GREEN}✓ $*${NC}"; }
warn()   { echo -e "${YELLOW}! $*${NC}"; }
error()  { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }

# ── Verify we are inside a git repository ────────────────────────────────────
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || error "Not inside a git repository."

MAIN_BRANCH="main"

# ── Switch to main ────────────────────────────────────────────────────────────
CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "$MAIN_BRANCH" ]; then
    log "Switching from '$CURRENT' to '$MAIN_BRANCH'..."
    git checkout "$MAIN_BRANCH"
else
    log "Already on '$MAIN_BRANCH'."
fi

# ── Pull latest main ──────────────────────────────────────────────────────────
log "Pulling latest '$MAIN_BRANCH'..."
git pull origin "$MAIN_BRANCH"

# ── Prune remote-tracking branches ───────────────────────────────────────────
log "Pruning stale remote-tracking branches..."
PRUNED=$(git fetch --prune 2>&1)
if echo "$PRUNED" | grep -q "pruned"; then
    echo "$PRUNED" | grep "pruned" | sed 's/^/  /'
    success "Remote-tracking branches pruned."
else
    success "No stale remote-tracking branches found."
fi

# ── Delete local branches already merged into main ───────────────────────────
log "Finding local branches merged into '$MAIN_BRANCH'..."

PROTECTED="^(\*|  (main|master|develop|staging|release/.+))$"
MERGED=$(git branch --merged "$MAIN_BRANCH" | grep -vE "$PROTECTED" || true)

if [ -z "$MERGED" ]; then
    success "No merged local branches to delete."
else
    echo "  Branches to delete:"
    echo "$MERGED" | sed 's/^/    /'
    echo "$MERGED" | xargs git branch -d
    success "Deleted merged local branches."
fi

echo ""
success "Cleanup complete."
