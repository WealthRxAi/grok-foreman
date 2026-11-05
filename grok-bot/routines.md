# Foreman routines

Add these three routines to the Foreman bot. Times are examples; pick yours.

Grok Bot approvals asked for inside a routine can expire if nobody answers them, so this setup never asks you to approve anything inside Grok Bot. Your one approval is the merge button on GitHub.

| Routine | Trigger | What to paste as the routine's prompt |
| --- | --- | --- |
| Standup | Schedule: weekdays 6:00 AM | Run STANDUP, REVIEW, and BRIEF from your instructions. |
| Confirm | GitHub notification: a pull request on a bot/ branch is merged | Run CONFIRM from your instructions for that pull request. |
| Friday sweep | Schedule: Fridays 4:00 PM | List open bot/ branches and pull requests older than 3 days, and every BLOCKED item this week. Send me the list in under 60 words. Change nothing. |

Every routine run uses Grok Bot usage. Three routines a weekday, with coding handed to Claude Code, keeps the manager's share small.
