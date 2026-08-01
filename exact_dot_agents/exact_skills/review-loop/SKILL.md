---
name: review-loop
description: Runs the two-axis Codex review headlessly, remediates the findings it returns, and re-reviews the residuals round after round until clean. Use when the user wants changes reviewed by Codex, review findings verified and remediated, or a review looped until no findings remain.
---

Codex reviews, Claude remediates, and the loop repeats until **clean**. One **round** is review → triage → remediate. Rounds continue on their own; the loop stops only at a **gate**.

**Clean** is the terminal state: no `blocking` and no `should-fix` finding on either axis. Nits alone are clean.

Findings move as a **file**, never as prose you retype. Every path, line number, and quotation the reviewer emits reaches the remediating agent byte-identical — transcription is where paths break.

## Gates

Three conditions hand the loop back to the user. Everything else advances into the next round without asking.

- **Design decision** — a finding carrying `requires_design_decision: true`, caught at triage. Present the finding and each remediation option with its trade-offs, then wait. The choice is the user's, not the loop's.
- **Round 5 not clean** — five rounds spent with findings still standing. Report what survived and the reviewer's reasoning.
- **Oscillation** — a finding id reappears in a round after an earlier round recorded it remediated. Report both rounds side by side: the fix and the finding disagree about intent, and another round will not settle it.

## 1. Pin the round

Establish four things, and resolve each rather than asking:

- **Worktree** — absolute path to the checkout under review. Per-ticket worktrees follow `~/.humanlayer/workspaces/<ticket>/<project>`, where `<project>` is the repository's directory name.
- **Fixed point** — the commit the diff is measured from. A review prompt's front matter carries `base`; otherwise it is the merge-base with `main`.
- **Review prompt** — the `NN-review-prompt-*.md` beside the task's other artifacts. Absent, write it first, following the numbering, front matter (`task`, `type`, `repo`, `branch`, `base`, `head`, `follows`), and depth of the sibling artifacts.
- **Round directory** — `<artifact-dir>/review-loop/round-<NN>/`, created now.

Done when `git rev-parse <fixed-point>` resolves inside the worktree and `git diff <fixed-point>...HEAD` is non-empty. A bad ref fails here, not fifteen minutes into a review.

## 2. Send the round to Codex

Round 1 opens a **thread**; later rounds resume it, so the reviewer keeps what it already flagged.

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
  "The findings below were remediated: $ROUND/remediation.md
Re-verify each one against the current tree, and review the remediation commits themselves for new defects.
Report residuals and anything new through the output schema, reusing ids for findings that still stand." \
  </dev/null >"$ROUND/codex.log" 2>&1
```

Run it with `run_in_background: true`. Reviews take upwards of ten minutes, far past the foreground timeout, and the harness re-invokes you when the process exits. `</dev/null` is load-bearing: without it Codex reads stdin and blocks forever.

When the round returns, record its thread id — round N+1 resumes against it, and a round that ends at a **gate** may sit for hours before that happens:

```bash
grep -m1 '^session id:' "$ROUND/codex.log" | awk '{print $3}'
```

Done when `findings.json` parses, `codex.log` ends in a non-error exit, and the thread id is recorded. A truncated or empty file means the review died — read the log tail before retrying, and never fabricate the round's findings.

## 3. Triage

Read `findings.json` and separate the **gated** findings — those carrying `requires_design_decision: true` — from the rest. A single gated finding fires the design-decision gate before anything is dispatched.

Everything else goes to the remediator whatever its severity. Whether a finding gets fixed or rebutted turns on reading the cited code, so it is decided there rather than pre-judged here from the reviewer's prose.

Done when every finding in both arrays is either gated or dispatched. Silently dropping a nit is how the loop reports clean while defects stand.

## 4. Remediate

Dispatch one `review-remediator` subagent with the worktree and the path to `$ROUND/findings.json`. Point it at the file; it carries its own brief. It writes `$ROUND/remediation.md`, which is what round N+1 sends back to the reviewer.

Gated findings stay out of the dispatch — the design-decision gate has already fired on them, and the user's answer becomes a later round's input.

Done when `remediation.md` carries an outcome for every id in `findings.json` and the repository's gates pass.

## 5. Judge the round

**Clean** ends the loop — report the rounds spent and what each fixed.

Otherwise check the gates. Oscillation is the one that has to be looked up rather than read off the verdict: compare this round's finding ids against the outcomes in every earlier `round-*/remediation.md`, and an id recorded `fixed` that has come back fires the gate.

Absent a gate, start round N+1 at step 2 immediately.

Done when the loop has either ended or entered the next round's step 2. A turn that ends by narrating what the round did is the loop stalling.

## Codex mechanics

Flags, model and sandbox overrides, thread recovery, and the failure modes of headless `codex exec` are in [`CODEX.md`](CODEX.md). Reach for it when a round exits non-zero, hangs, returns unparseable output, or you need to resume a thread whose id was lost.
