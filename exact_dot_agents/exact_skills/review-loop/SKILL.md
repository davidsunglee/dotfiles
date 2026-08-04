---
name: review-loop
description: Runs the two-axis Codex review headlessly, remediates the findings it returns, and re-reviews the residuals round after round until clean. Use when the user wants changes reviewed by Codex, review findings verified and remediated, or a review looped until no findings remain.
---

Codex reviews, a dedicated subagent remediates, and the loop repeats until **clean**. One **round** is review → remediate → judge. Rounds continue on their own; the loop stops only at a **gate**.

**Clean** is the terminal state: no `blocking` and no `should-fix` finding on either axis. Nits alone are clean.

Findings move as a **file**, never as prose you retype. Every path, line number, and quotation the reviewer emits reaches the remediating agent byte-identical — transcription is where paths break.

The **ledger** at `<artifact-dir>/review-loop/ledger.jsonl` is the loop's memory: one JSON object per finding answered, carrying `round`, `id`, `outcome`, and `summary`. Which findings have recurred, how long each has been open, and whether a fix undid an earlier one are facts to look up there, not things to carry across a ten-minute background wait. Keep it one-line-per-finding — work not answering a finding, like a codebase-wide sweep, belongs in `remediation.md`, because an entry with no finding id is one the recurrence lookup cannot read.

## Invoking host

Before launching the first reviewer process, read exactly one host branch:

- From Codex, read [`CODEX-HOST.md`](CODEX-HOST.md).
- From Claude Code, read [`CLAUDE-CODE-HOST.md`](CLAUDE-CODE-HOST.md).

The selected branch governs process launch, waiting, and remediator dispatch for the whole loop. Return here after each host-specific action.

## Gates

Three conditions hand the loop back to the user. Everything else advances into the next round without asking.

- **Design decision** — the remediator returned a finding `deferred`. Surface its analysis as written, in prose: the finding, each option with what it buys and what it costs, and the recommendation with the reasoning behind it. Then wait — the choice is the user's, and their answer is round N+1's input.
- **Round 5 not clean** — round 5's review returned findings. Stop before sending a sixth. Report what survived, and with it the trajectory: findings per round, and the remediator's read on whether the loop was converging. Five rounds of shrinking, genuinely-new findings is a large change still being worked through; five rounds of the same size is churn. The user is deciding whether to keep going, so give them the shape of it rather than the last round alone.
- **Oscillation** — the remediator reported the loop revisiting a state instead of approaching one: a fix that would undo an earlier fix, two findings whose fixes exclude each other, or a claim restated unchanged after the round that should have settled it. Surface its evidence and stop, because another round repeats the last one. A finding merely recurring is not this — the reviewer may simply be right that it is still open, and the remediator judges the difference against the ledger.

## 1. Pin the round

Establish five things, and resolve each rather than asking:

- **Worktree** — absolute path to the checkout under review. Per-ticket worktrees follow `~/.humanlayer/workspaces/<ticket>/<project>`, where `<project>` is the repository's directory name.
- **Fixed point** — the commit the diff is measured from. A review prompt's front matter carries `base`; otherwise it is the merge-base with `main`.
- **Review prompt** — the `NN-review-prompt-*.md` beside the task's other artifacts. It must name the spec and the standards files the change is measured against, including directory-scoped ones: headless, every source it leaves out is one the round runs without. Absent, write it first — [`REVIEW-PROMPT.md`](REVIEW-PROMPT.md) covers what it carries and who writes it.
- **Ledger** — `<artifact-dir>/review-loop/ledger.jsonl`, initialized as an empty file when this is round 1 and no ledger exists.
- **Round directory** — `<artifact-dir>/review-loop/round-<NN>/`, created now.

Done when `git rev-parse <fixed-point>` resolves inside the worktree, `git diff <fixed-point>...HEAD` is non-empty, and `git status --short` is empty. The reviewer measures committed changes through `HEAD`; a bad ref, empty diff, or dirty worktree fails here rather than disappearing from the review.

## 2. Send the round to Codex

Round 1 opens a **thread**; later rounds resume it, so the reviewer keeps what it already flagged.

Set `$ROUND` to the current round directory. From round 2 on, set `$PREVIOUS_ROUND` to the preceding directory and load `$THREAD_ID` from its `thread-id` file.

Round 1:

```bash
codex exec \
  -C "$WORKTREE" -s read-only \
  -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --output-schema "$HOME/.agents/skills/review-loop/findings-schema.json" \
  -o "$ROUND/findings.json" \
  "Run the code-review skill at $HOME/.agents/skills/code-review/SKILL.md.
Fixed point: $BASE
Review prompt: $PROMPT_PATH
Report every finding through the output schema." \
  </dev/null >"$ROUND/codex.log" 2>&1
```

Rounds 2+, against the id recorded last round:

```bash
codex exec resume "$THREAD_ID" \
  -C "$WORKTREE" -s read-only \
  -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --output-schema "$HOME/.agents/skills/review-loop/findings-schema.json" \
  -o "$ROUND/findings.json" \
  "The prior findings were remediated in: $PREVIOUS_ROUND/remediation.md
Re-verify each one against the current tree, and review the remediation commits themselves for new defects.
$RECURRENCE
Report residuals and anything new through the output schema, reusing ids for findings that still stand." \
  </dev/null >"$ROUND/codex.log" 2>&1
```

`$RECURRENCE` is built from the ledger: name every id raised more than once and how many rounds it has been open. A reviewer that knows it is restating a claim for the fourth time weighs it differently than one that believes it is finding it fresh.

Launch and wait using the selected host branch. Reviews take upwards of ten minutes, so keep the process attached to the host's long-running execution mechanism. `</dev/null` is load-bearing: without it Codex reads stdin and blocks forever.

When the round returns, record its thread id — round N+1 resumes against it, and a round that ends at a **gate** may sit for hours before that happens:

```bash
rg -m1 '^session id:' "$ROUND/codex.log" | awk '{print $3}' >"$ROUND/thread-id"
```

Done when `findings.json` parses, `codex.log` ends in a non-error exit, the thread id is recorded, and — from round 2 on — `$RECURRENCE` was non-empty whenever the ledger held a repeat. A truncated or empty file means the review died — read the log tail before retrying, and never fabricate the round's findings.

## 3. Remediate

Using the selected host branch, dispatch one `review-remediator` subagent with the worktree, the path to `$ROUND/findings.json`, the path to the ledger, and the round number. Point it at the files; its shared brief is [`REMEDIATOR.md`](REMEDIATOR.md).

Every finding goes to it, whatever its severity — including the ones the reviewer marked `requires_design_decision`, which it analyses rather than repairs. Fixed, rebutted, or deferred all turn on reading the cited code, so each is decided there rather than pre-judged here from the reviewer's prose.

It writes `$ROUND/remediation.md`, which is what round N+1 sends back to the reviewer.

Done when `remediation.md` carries an outcome for every id in `findings.json`, the repository's verification gates pass, every fix is committed, and `git status --short` is empty. A finding left without an outcome is one the loop will report clean over.

## 4. Judge the round

**Clean** ends the loop — report the rounds spent and what each fixed.

Otherwise check the gates. Two are read off what the remediator returned — a finding it `deferred`, or a report that the loop has stopped settling. The third is the round count.

Absent a gate, create round N+1's directory and start step 2 immediately.

Done when the loop has either ended or entered the next round's step 2. A turn that ends by narrating what the round did is the loop stalling.

## Reviewer mechanics

Flags, model and sandbox overrides, thread recovery, and the failure modes of headless `codex exec` are in [`CODEX-REVIEWER.md`](CODEX-REVIEWER.md). Reach for it when a round exits non-zero, hangs, returns unparseable output, or you need to resume a thread whose id was lost.
