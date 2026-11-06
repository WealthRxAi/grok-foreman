# Script test: run-ticket.sh

This is the exact output of testing `run-ticket.sh` against a throwaway sample repo. It tests the script's own checks, so Claude Code and the GitHub CLI were replaced by small stand-ins: one that makes a commit and writes a proof file (or writes `BLOCKED`), and one that returns a pull-request link. No AI ran in this test, and the PR link is a placeholder.

What it shows: the script ends every run in exactly one of two lines, `PR_READY <link>` or `BLOCKED <reason>`, and it refuses to open a pull request unless there is a proof file, no `BLOCKED` line and at least one commit.

```
$ run-ticket.sh sample-app TASK-7.md
PR_READY https://github.com/example/sample-app/pull/1

$ run-ticket.sh sample-app TASK-7.md   # same ticket again
BLOCKED branch bot/task-7 already exists; finish or delete it first

$ run-ticket.sh sample-app TASK-8.md   # worker hits a hard stop
BLOCKED worker: needs a new env var (repo left on bot/task-8)

$ run-ticket.sh sample-app bad-ticket.md   # badly written ticket
BLOCKED ticket first line must look like '# TASK-12: Fix the thing'
```

To reproduce it, point the script at your own repo with Claude Code and `gh` signed in.
