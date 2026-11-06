#!/usr/bin/env bash
# run-ticket.sh — the one command the manager (Grok Bot) runs to hand a ticket
# to the worker (Claude Code). It never merges anything. You do that.
#
# Usage:   run-ticket.sh <repo-path> <ticket-file>
# Ticket:  first line must be  "# TASK-<number>: <title>"
# Needs:   git, gh (logged in), claude (logged in with your Claude plan)
# Prints, as its LAST line, one of:
#   PR_READY <pull request url>
#   BLOCKED <reason>
#
# Works on macOS's built-in bash 3.2 and on Linux.

set -euo pipefail

REPO="${1:-}"
TICKET="${2:-}"
MAX_TURNS="${MAX_TURNS:-40}"
BASE="${BASE_BRANCH:-main}"

blocked() { echo "BLOCKED $*"; exit 1; }

[ -n "$REPO" ] && [ -n "$TICKET" ] || blocked "usage: run-ticket.sh <repo-path> <ticket-file>"
[ -d "$REPO/.git" ] || blocked "$REPO is not a git repository"
[ -f "$TICKET" ] || blocked "ticket file not found: $TICKET"
for tool in git gh claude; do
  command -v "$tool" >/dev/null 2>&1 || blocked "$tool is not installed or not on PATH"
done

# Absolute ticket path, id and title from the first line.
TICKET="$(cd "$(dirname "$TICKET")" && pwd)/$(basename "$TICKET")"
FIRST_LINE="$(head -n 1 "$TICKET")"
ID="$(printf '%s' "$FIRST_LINE" | sed -nE 's/^# (TASK-[0-9]+[a-z]?):.*/\1/p')"
TITLE="$(printf '%s' "$FIRST_LINE" | sed -E 's/^# //')"
[ -n "$ID" ] || blocked "ticket first line must look like '# TASK-12: Fix the thing'"
BRANCH="bot/$(printf '%s' "$ID" | tr '[:upper:]' '[:lower:]')"

# Run log lives outside the repo so it is never committed.
LOG_DIR="${BOT_LOG_DIR:-$HOME/.bot-runs}"
mkdir -p "$LOG_DIR"
PROOF="$LOG_DIR/$ID-proof.md"
RESULT="$LOG_DIR/$ID-result.json"
rm -f "$PROOF" "$RESULT"

cd "$REPO"
[ -z "$(git status --porcelain)" ] || blocked "$REPO has uncommitted changes; clean it before the next ticket"
git fetch origin --quiet
git checkout "$BASE" --quiet
git pull --ff-only --quiet origin "$BASE"
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  blocked "branch $BRANCH already exists; finish or delete it first"
fi
git checkout -b "$BRANCH" --quiet

PROMPT="You are the WORKER. Follow the \"Worker contract\" section of CLAUDE.md exactly.
You are on branch $BRANCH. Do not push, merge, or switch branches.
When you are done, write the pull request body to this file, using the \"PR proof format\" in CLAUDE.md:
$PROOF
If you cannot meet every acceptance criterion, make the first line of that file
BLOCKED: <reason>
and stop.

----- TICKET $ID -----
$(cat "$TICKET")"

# Permissions come from .claude/settings.json in the repo (allow + deny lists).
# Anything not allowed is refused in -p mode, so the run never stalls on a prompt.
if ! claude -p "$PROMPT" \
      --permission-mode acceptEdits \
      --add-dir "$LOG_DIR" \
      --max-turns "$MAX_TURNS" \
      --output-format json > "$RESULT"; then
  blocked "Claude Code exited with an error; see $RESULT (repo left on $BRANCH)"
fi

[ -s "$PROOF" ] || blocked "worker wrote no proof file (repo left on $BRANCH)"
if grep -q '^BLOCKED' "$PROOF"; then
  blocked "worker: $(grep -m 1 '^BLOCKED' "$PROOF" | sed -E 's/^BLOCKED:? *//') (repo left on $BRANCH)"
fi
[ -z "$(git status --porcelain)" ] || blocked "worker left uncommitted changes (repo left on $BRANCH)"
[ "$(git rev-list --count "$BASE..HEAD")" -gt 0 ] || blocked "worker made no commits (repo left on $BRANCH)"
# A fix with no test change is not proven. (You still check fail-before/pass-after in the PR.)
git diff --name-only "$BASE..HEAD" | grep -Eiq '(test|spec)' \
  || blocked "worker changed no test file, so the fix is unproven (repo left on $BRANCH)"

# The worker is denied git push; the script pushes and opens the PR.
git push --quiet -u origin "$BRANCH"
PR_URL="$(gh pr create --base "$BASE" --head "$BRANCH" --title "$TITLE" --body-file "$PROOF")"
git checkout "$BASE" --quiet
echo "PR_READY $PR_URL"
