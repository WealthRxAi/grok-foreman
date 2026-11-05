# TASK-<n>: <one-line outcome, e.g. "Transaction notes load again">

Repo: <repo name> · Priority: <P1 users hit it / P2 blocks revenue / P3 cleanup> · Found by: <routine name> on <date>

## What's wrong (evidence, copied not paraphrased)

- Where seen: <log page, issue link, or URL>
- Exact error:

```
<paste the log line or error text>
```

- How often / since when: <e.g. 14 times since Oct 30>

## Outcome wanted

<One sentence a non-coder could check. "Opening a transaction shows its AI note instead of an error.">

## Acceptance criteria

- [ ] <observable check 1>
- [ ] A test reproduces the bug and now passes
- [ ] Tests, lint, and build pass
- [ ] On the preview deployment: <the exact click path to see it working>

## In scope (files the worker may change)

- `<path>`
- `<path>`

## Do not touch

- Environment variables, migrations, billing and auth code
- <anything else specific to this task>

## Proof required in the PR

- Failing test before, passing after
- Test and build output
- The preview check above, done
