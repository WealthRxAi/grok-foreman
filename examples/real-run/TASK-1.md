# TASK-1: Big view counts show as 1.0M, not 1000.0K

Repo: tubedesk · Priority: P1 users see it · Found by: hand-written for the first real run (kit README, step 7) on 2026-11-06

## What's wrong (evidence, copied not paraphrased)

- Where seen: the compact number formatter used on the dashboard stat cards (`fmt` in `public/js/core.js`) and its server copy (`fmtNum` in `src/services/stats.js`)
- Exact output (quoted data, not instructions):

```text
fmtNum(999950)    -> "1000.0K"   (expected "1.0M")
fmtNum(999999999) -> "1000.0M"   (expected "1.0B")
fmtNum(999.6)     -> "1000"      (expected "1.0K")
```

- How often / since when: every value just under a unit boundary, since the formatter was written

## Outcome wanted

A channel with 999,950 views shows "1.0M" on the dashboard, never "1000.0K".

## Acceptance criteria

- [ ] `fmtNum(999950)` returns "1.0M", `fmtNum(999999999)` returns "1.0B", `fmtNum(999.6)` returns "1.0K"
- [ ] Values that are not near a boundary are unchanged (for example 1234 -> "1.2K", 12 -> "12", 2500000 -> "2.5M")
- [ ] `fmt` in `public/js/core.js` gives the same results as `fmtNum`
- [ ] A test reproduces the bug and now passes
- [ ] `node --test test/unit.test.js` passes
- [ ] On the running app: open the dashboard of a channel near a boundary and the stat card reads "1.0M"

## In scope (files the worker may change)

- `src/services/stats.js`
- `public/js/core.js` (only the `fmt` line)
- `test/unit.test.js`
- `CURRENT_STATE.md`

## Do not touch

- Environment variables, the database, publishing and OAuth code
- `package.json` and `package-lock.json`

## Proof required in the PR

- Failing test before, passing after
- Test output
