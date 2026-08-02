# Writing the review prompt

Reference for composing the prompt a round runs against, supporting [`SKILL.md`](SKILL.md) step 1.

## Why the prompt carries the review

The two-axis skill discovers its own sources. For the spec it looks at issue references in commit messages, then a path it was handed, then a PRD under `docs/`, `specs/`, or `.scratch/` — and if none of those land, it **asks the user where the spec is**. For standards it looks for files like `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

Headless, there is nobody to ask. Every source the prompt does not name is a source the round runs without, and a Spec axis with no spec reports "no spec available" — half the review gone, quietly, in a run that still exits zero.

A repository whose specs live outside those directories, whose standards live in differently-named files, or whose issue tracker the reviewer cannot reach is invisible to that search. The prompt is what makes it visible.

## What every prompt names

- **Spec** — the outline, PRD, or specification this change implements, by path. Name the sections that bear on the diff rather than the document alone.
- **Standards** — the instruction files the change is measured against, by path, **including directory-scoped ones**. A scoped file that governs only the paths in this diff is the one the reviewer is least likely to find and most likely to need.
- **Scope** — the fixed point and the commits in range, so the reviewer measures the diff the loop measures.

## What makes a prompt worth writing

Naming sources buys a competent generic review. The findings that justify the round come from aiming it.

- **What changed, by commit** — a line each, in the author's words. The reviewer can read the diff; it cannot read the intent behind it.
- **What you most want judged** — the invariant, contract, or claim you are least sure survives. Ask the reviewer to *defeat* it. A claim put up to be knocked down gets attacked; the same claim stated as fact gets confirmed.
- **What earlier rounds found** — when a previous review refuted a claim of the same shape, say so, and say that careful reasoning by the author is not sufficient evidence. Prior refutations are the cheapest calibration a prompt can carry.

## Who writes it

The implementer, as its last act. The agent that just made the change knows which invariant is load-bearing, which deviation from the outline was deliberate, and which part it is least sure of. An orchestrator reconstructing that from the diff writes a blander prompt and aims it worse.

## Conventions

Write it beside the task's other artifacts, taking the next number in the sequence. Carry front matter — `task`, `type`, `repo`, `branch`, `base`, `head`, and `follows` naming the prompt this one picks up from — and match the depth of the sibling artifacts. A prompt that supersedes an earlier review says so; one that only extends its range says that instead, and gives the range.
