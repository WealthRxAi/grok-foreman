# Grok Bot manages. Claude Code builds. You merge.

The exact files from the SalStack Labs video on running Grok Bot as the manager and Claude Code as the worker. Free, MIT licensed.

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
4. **Give the bots their own GitHub account, then protect main.**
   - Create a second, free GitHub account (for example `yourname-foreman`) and add it to the repo as a collaborator with **Write** access. Sign `gh` in as that account on the machine that runs `run-ticket.sh`, and connect that account (not yours) to Grok Bot. Its pull requests are then authored by the bot, not by you.
   - On GitHub: Settings → Branches (or Rules → Rulesets) → a rule for `main` with "Require a pull request before merging", **"Require approvals: 1"**, and **"Do not allow bypassing the above settings"**.
   - Why this works: GitHub never lets a pull request's author approve their own pull request. The bot can push a branch and open a PR, but it can't get the one approval main needs. You approve and merge. Without "Require approvals", any account with Write access could merge its own PR.
   - Branch protection on a private repo needs a paid GitHub plan (Pro, Team or Enterprise). On a free private repo the rule won't be enforced.
5. **Where the manager runs the script.** Pick one:
   - **Your own machine (recommended):** the computer that already holds your repos, with the Grok Bot desktop app allowed to run local commands. Check that your plan and settings allow local execution.
   - **Grok Bot's cloud computer:** install Claude Code there, clone the repo, and sign `gh` in with a fine-grained token limited to that one repo. All your Bots share that computer and its sign-ins, so keep nothing else sensitive on it.
6. **The manager.** In Grok Bot, create a Bot called Foreman. Paste `foreman-instructions.md`, fill in the PROJECTS block, connect GitHub, and sign it into your log viewer (read-only access is enough). Add the routines from `routines.md`.
7. **Dry run.** Write one ticket by hand from `TICKET.md`, run `run-ticket.sh <repo> <ticket>` yourself, and read the pull request it opens. Then let the Standup routine run on its own.

## What actually keeps it safe (and what doesn't)

Each layer below says what it really enforces. Prompts are a backup, never the lock.

1. **The lock: GitHub, not the bots.** Protect `main` with "Require a pull request", "Require approvals: 1" and "Do not allow bypassing the above settings" (as the repo owner you are an admin, and admins skip the rule otherwise). The bots work through their own GitHub account, which authors every PR and so can never supply the approval itself. "Never merge" in Foreman's instructions is only a backup.
2. **The worker's walls: the OS sandbox.** `settings.json` turns on Claude Code's sandbox with no network, no unsandboxed retries (`allowUnsandboxedCommands: false`, `failIfUnavailable: true`), and no reading your `.env` files, SSH keys, AWS credentials or GitHub CLI login (`filesystem.denyRead`). Claude's own web tools (`WebFetch`, `WebSearch`) are denied too. That matters because the worker writes the tests it runs, so a command allow-list on its own can't stop code from reaching the network. The `deny` list is a seatbelt on top, not the wall. The sandbox covers shell commands; Claude's own file tools follow the permission rules. Supported on macOS, Linux and WSL2. For the strongest isolation, run `run-ticket.sh` in a container or VM with no production secrets.
3. **No production secrets where either bot runs, or where its code runs before you merge.** The bot account only has access to this repo. Unmerged code does run before you tap merge: preview deployments and `pull_request` CI jobs build the bot's branch. So keep live payment and database admin keys out of preview environment variables, and put deploy secrets in a GitHub Environment that requires your approval. "Nothing reaches your live app until you merge" is true for production, not for previews and CI.
4. **Limits.** Max 3 tickets a day, one retry each. A stuck task becomes a BLOCKED line in your brief, not a loop.
5. **Untrusted text (prompt injection).** Error logs can contain text an attacker wrote, and the ticket copies that text to the worker. So the ticket fences it as quoted data, only you add the `bot-ready` label, and the instructions treat logs, issues and web pages as data, never orders. That is a prompt-level defense: it lowers the risk, it doesn't remove it. Rules 1 to 3 are what cap the damage: no network, no secrets, and no way into main without your approval.
6. **What the script checks, and what it can't.** `run-ticket.sh` opens a PR only if the worker wrote a proof file with no `BLOCKED` line, committed something, and changed at least one test file. It can't prove the new test failed before the fix; the proof file says so, but the worker wrote it. That's your second merge check, or add a CI job that runs the new test against `main` (must fail) and the branch (must pass).

MIT licensed. Built by SalStack Labs.
