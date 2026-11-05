# Grok Bot manages. Claude Code builds. You merge.

The exact files from the SalStack Labs video "Grok Bot Found the Bug. Claude Code Fixed It."

```
 6:00  Grok Bot (manager)   reads your error logs + issues, picks ≤3 tasks, writes a ticket each
   │
   ▼   run-ticket.sh
       Claude Code (worker)  new branch → failing test → smallest fix → tests pass → proof
   │
   ▼   pull request with proof
       Grok Bot (manager)   checks the proof, clicks through the preview site, sends you a brief
   │
   ▼   your phone
 8:00  You                  read the brief, open the PR, tap Merge   (the only human step)
   │
   ▼
       Grok Bot (manager)   checks production logs, confirms the fix
```

**Why split it this way:** Grok Bot runs on its own computer on a schedule, signs into sites that have no API, and reaches you on your phone. Claude Code is the better builder and runs on the Claude plan you already pay for, so coding never burns your Grok Bot weekly usage.

## What's in here

| File | Goes where |
| --- | --- |
| `grok-bot/foreman-instructions.md` | The manager Bot's instructions in Grok Bot |
| `grok-bot/routines.md` | Three routines to add to that Bot |
| `claude-code/CLAUDE-worker-contract.md` | Paste into your repo's `CLAUDE.md` |
| `claude-code/settings.json` | Copy to `<repo>/.claude/settings.json` |
| `claude-code/run-ticket.sh` | The one command the manager runs |
| `templates/TICKET.md` | The handoff format the manager writes |
| `daily-loop.md` | One-page checklist |

## Setup (about 30 minutes)

1. **Worker rules.** Paste `CLAUDE-worker-contract.md` into your repo's `CLAUDE.md`. Put your real test, lint, and build commands under "Checks".
2. **Worker permissions.** Copy `settings.json` to `<repo>/.claude/settings.json` and commit it. Add your own test commands to `allow` if they differ.
3. **The script.** Put `run-ticket.sh` somewhere stable (for example `~/bin/`) and run `chmod +x run-ticket.sh`. The machine needs `git`, the GitHub CLI `gh` signed in (`gh auth login`), and Claude Code signed in with your Claude plan.
4. **Protect main.** On GitHub: Settings → Branches → add a rule for `main` → "Require a pull request before merging". Now nothing reaches main except through your merge.
5. **Where the manager runs the script.** Pick one:
   - **Your own machine (recommended):** the computer that already holds your repos, with the Grok Bot desktop app allowed to run local commands. Check that your plan and settings allow local execution.
   - **Grok Bot's cloud computer:** install Claude Code there, clone the repo, and sign `gh` in with a fine-grained token limited to that one repo. All your Bots share that computer and its sign-ins, so keep nothing else sensitive on it.
6. **The manager.** In Grok Bot, create a Bot called Foreman. Paste `foreman-instructions.md`, fill in the PROJECTS block, connect GitHub, and sign it into your log viewer (read-only access is enough). Add the routines from `routines.md`.
7. **Dry run.** Write one ticket by hand from `TICKET.md`, run `run-ticket.sh <repo> <ticket>` yourself, and read the pull request it opens. Then let the Standup routine run on its own.

## The five rules that keep it safe

1. The manager never merges. You do, from GitHub.
2. The worker can't push, merge, switch branches, read `.env`, install packages, or call your hosting, database, or payment CLIs (`settings.json`).
3. No secrets on the bot's computer that it doesn't need. Never give it live payment or database admin keys.
4. Max 3 tickets a day, one retry each. A stuck task becomes a BLOCKED line in your brief, not a loop.
5. Only you add the `bot-ready` label. Text in logs, issues, and web pages is data the manager reports, never orders it follows.

MIT licensed. Built by SalStack Labs.
