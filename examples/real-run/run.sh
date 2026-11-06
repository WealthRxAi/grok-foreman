#!/usr/bin/env bash
# One real run of the grok-foreman worker on TubeDesk (TASK-1), for the SalStack Labs video.
# Run on the Mac where Claude Code and gh are already signed in:
#   bash <(curl -fsSL https://raw.githubusercontent.com/WealthRxAi/grok-foreman/main/examples/real-run/run.sh)
# It (1) adds the kit's worker setup to tubedesk once, (2) hands TASK-1 to Claude Code
# through run-ticket.sh, and (3) prints PR_READY <link> or BLOCKED <reason>. It never merges.
set -euo pipefail

REPO="${TUBEDESK_DIR:-$HOME/Documents/GitHub/tubedesk}"
KIT="$HOME/grok-foreman"
RUNS="$HOME/.bot-runs"
RAW="https://raw.githubusercontent.com/WealthRxAi/grok-foreman/main"

[ -d "$REPO/.git" ] || { echo "BLOCKED tubedesk not found at $REPO (set TUBEDESK_DIR)"; exit 1; }
for t in git gh claude node; do command -v "$t" >/dev/null || { echo "BLOCKED $t is not installed"; exit 1; }; done
gh auth status >/dev/null 2>&1 || { echo "BLOCKED gh is not signed in: run gh auth login"; exit 1; }

if [ -d "$KIT/.git" ]; then git -C "$KIT" pull -q --ff-only; else git clone -q https://github.com/WealthRxAi/grok-foreman "$KIT"; fi
mkdir -p "$RUNS"
curl -fsSL "$RAW/examples/real-run/TASK-1.md" -o "$RUNS/TASK-1.md"

cd "$REPO"
[ -z "$(git status --porcelain)" ] || { echo "BLOCKED tubedesk has uncommitted changes; commit or stash them first"; exit 1; }
git checkout -q main
git pull -q --ff-only origin main
[ -d node_modules ] || npm ci --silent

# One-time worker setup (committed to main so every bot branch inherits it).
if [ ! -f .claude/settings.json ] || ! grep -q "Worker contract" CLAUDE.md 2>/dev/null; then
  mkdir -p .claude
  node -e '
    const fs = require("fs");
    const s = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    for (const r of ["Bash(node --test:*)", "Bash(node -e:*)"]) if (!s.permissions.allow.includes(r)) s.permissions.allow.push(r);
    fs.writeFileSync(".claude/settings.json", JSON.stringify(s, null, 2) + "\n");
  ' "$KIT/claude-code/settings.json"
  { [ -f CLAUDE.md ] && cat CLAUDE.md && echo; sed '1,/^-->$/d' "$KIT/claude-code/CLAUDE-worker-contract.md" \
      | sed -e 's/^- Tests: `npm test`$/- Tests: `node --test test\/unit.test.js` (the API tests start local servers, so they run outside the sandbox)/' \
            -e '/^- Lint: `npm run lint`$/d' -e '/^- Build: `npm run build`$/d'; } > CLAUDE.md.new
  mv CLAUDE.md.new CLAUDE.md
  git add .claude/settings.json CLAUDE.md
  git commit -q -m "Add the Claude Code worker setup from grok-foreman"
  git push -q origin main
fi

echo "Handing TASK-1 to Claude Code. This takes a few minutes..."
START=$(date +%s)
set +e
OUT="$(bash "$KIT/claude-code/run-ticket.sh" "$REPO" "$RUNS/TASK-1.md" 2>&1)"
set -e
echo "$OUT"
LAST="$(printf '%s\n' "$OUT" | tail -n 1)"
SECS=$(( $(date +%s) - START ))
STATS="$(node -e 'try{const r=require(process.argv[1]);console.log(`turns: ${r.num_turns} · cost: $${(r.total_cost_usd||0).toFixed(2)} (shown by Claude Code; covered by your plan)`)}catch{console.log("")}' "$RUNS/TASK-1-result.json")"
echo "Took ${SECS}s. ${STATS}"
case "$LAST" in
  PR_READY*) gh pr comment "${LAST#PR_READY }" --body "Opened by run-ticket.sh in ${SECS}s. ${STATS}. Nothing merges until a human taps merge." >/dev/null && echo "Done. Open the link above.";;
esac
