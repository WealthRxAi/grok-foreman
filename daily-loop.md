# The daily loop (one page)

| When | Who | What | Done when |
| --- | --- | --- | --- |
| 6:00 AM | Grok Bot | Reads error logs, `bot-ready` issues, CURRENT_STATE.md. Picks ≤3 tasks. | Tickets saved |
| Right after | Grok Bot → Claude Code | Runs `run-ticket.sh` once per ticket | `PR_READY` or `BLOCKED` |
| While it runs | Claude Code | Branch → failing test → smallest fix → checks → commit → proof | Proof file written |
| After each PR | Grok Bot | Checks proof against criteria, clicks through the preview, comments PASS or CHANGES | Review comment on PR |
| By 8:00 AM | Grok Bot → you | One brief: ready to merge, blocked, next | Brief on your phone |
| Your 5 minutes | You | Read the PR's Result, Proof, and Risk lines. Open the preview once. Merge or comment. | Merged or sent back |
| 2 hours after merge | Grok Bot | Checks production logs for the same error | "Confirmed in production" |
| Friday 4:00 PM | Grok Bot | Lists stale branches, old PRs, BLOCKED items | List on your phone |

## What you look at before merging (in this order)

1. **Result:** is this the thing I wanted?
2. **Proof:** did a test fail before and pass after? Did the build pass?
3. **Risk:** does it touch money, auth, or data? If yes, read the diff.
4. **Preview:** do the one click path in the ticket yourself.

If any answer is no, comment on the pull request instead of merging. The manager picks it up tomorrow.
