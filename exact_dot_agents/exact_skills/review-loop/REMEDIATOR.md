# Review remediator

Shared brief for the `review-remediator` agents used by [`SKILL.md`](SKILL.md).

Given a worktree, a `findings.json`, a `ledger.jsonl`, and a round number, leave every finding with an **outcome**: `fixed`, `rebutted`, or `deferred`. Write `remediation.md` beside `findings.json`.

The findings file holds two arrays, `standards` and `spec`. Each finding carries a stable `id`, a `severity`, a `file`, a `line`, and the reviewer's prose. Work from that file itself so its paths, line numbers, and quotations stay exact.

## Read the ledger first

Read `ledger.jsonl` before touching the worktree. Use it to recognize repeated findings and earlier fixes. Append one JSON object for each finding as it is settled:

```json
{"round": 2, "id": "S1", "outcome": "fixed", "summary": "Guarded the null request before dispatch."}
```

Keep each object on one line and use exactly the keys shown.

## Verify every claim

A finding is a claim about the tree, not a fact about it. Open the cited file at the cited line and read enough surrounding code to judge the claim. Read complete files when a contract may depend on code outside the quoted region.

Pay the same evidentiary cost whichever outcome you choose:

- **Fixed** — name the concrete failure the finding causes: the input, state, or call that produces wrong behavior. Repair that defect.
- **Rebutted** — name the file and line that refutes the finding and quote it, or show why the scenario cannot arise and what prevents it.
- **Deferred** — use when the claim holds but remediation forces a design choice with real trade-offs. Lay out each option with what it buys and costs, recommend one, and explain the deciding reason.

Choose `fixed` only after stating the concrete failure. Otherwise, produce the evidence-backed rebuttal.

Treat `requires_design_decision` as the reviewer's signal, not its verdict. Defer any choice you discover and resolve any flagged finding whose fix proves determinate. Severity does not decide the outcome.

## Detect oscillation

Report **oscillation** when the ledger proves the loop is revisiting a state instead of approaching one:

- **Reversal** — the proposed fix would undo an earlier round's fix.
- **Cycle** — two findings require mutually exclusive fixes, so settling one reopens the other.
- **Restatement** — the same claim appears unchanged in the same place after the round meant to settle it.

Re-read a supposedly fixed finding before calling oscillation; the earlier fix may be incomplete. A narrower finding or one that moved to a different line is slow convergence. Record oscillation in `remediation.md` with the rounds and evidence.

## Fix the defect

Repair the defect, not merely the cited line. When the same defect appears elsewhere in the reviewed change, fix every instance and report the sweep.

Keep the diff bounded to findings. Put unrelated improvements in a note for the user.

Resolve what the repository's aggregate verification command already runs before invoking it. Run the authoritative gates and trust their reported status.

After verification passes, commit the round's fixes according to the repository's commit instructions. Include only remediation changes in the commit. A round with only rebutted or deferred findings needs no commit.

## Record the outcomes

Write one section per finding id, preserving the order in `findings.json`:

```markdown
## S1 — fixed
`languages/python/.../strategy.py:81` — <what changed and why it answers the finding>

## S2 — rebutted
`core/spec/m-descriptor.md:104` states <quoted text>, which is what the code does.

## P1 — deferred
`core/spec/m-sql.md:126` — <what forces a choice and why>

**A — <name>.** Buys <…>. Costs <…>.
**B — <name>.** Buys <…>. Costs <…>.

**Recommend B.** <Why A loses on the axis that matters here.>
```

Make every deferred section self-contained enough for the user to decide without opening the cited file.

Done when every id in `findings.json` appears in `remediation.md` with an outcome, every outcome has been appended to the ledger, the repository's verification gates pass, every fix is committed, and `git status --short` is empty.
