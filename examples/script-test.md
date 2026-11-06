# Script test: run-ticket.sh

This is the exact output of testing `run-ticket.sh` against a throwaway sample repo. It tests the script's own checks, so Claude Code and the GitHub CLI were replaced by small stand-ins: one that behaves like a worker (commits a fix, writes a proof file, writes `BLOCKED`, or skips a step on purpose) and one that returns a pull-request link. No AI ran in this test, and the PR link is a placeholder.

What it shows: every run ends in exactly one of two lines, `PR_READY <link>` or `BLOCKED <reason>`. The script refuses to open a pull request unless the worker wrote a proof file, put no `BLOCKED` line anywhere in it, committed something, and changed at least one test file.

```
$ run-ticket.sh sample-app TASK-7.md      # fix + test + proof
PR_READY https://github.com/example/sample-app/pull/1

$ run-ticket.sh sample-app TASK-7.md      # same ticket again
BLOCKED branch bot/task-7 already exists; finish or delete it first

$ run-ticket.sh sample-app TASK-8.md      # BLOCKED on line 3 of the proof
BLOCKED worker: needs a new env var (repo left on bot/task-8)

$ run-ticket.sh sample-app TASK-9.md      # fix committed, no test changed
BLOCKED worker changed no test file, so the fix is unproven (repo left on bot/task-9)

$ run-ticket.sh sample-app TASK-10.md     # proof written, nothing committed
BLOCKED worker made no commits (repo left on bot/task-10)

$ run-ticket.sh sample-app TASK-11.md     # worker wrote no proof
BLOCKED worker wrote no proof file (repo left on bot/task-11)

$ run-ticket.sh sample-app bad-ticket.md  # badly written ticket
BLOCKED ticket first line must look like '# TASK-12: Fix the thing'
```

What this test can't show: that the new test really failed before the fix. That is your second check before you merge (or a CI job; see the README).

To reproduce it, point the script at your own repo with Claude Code and `gh` signed in.
