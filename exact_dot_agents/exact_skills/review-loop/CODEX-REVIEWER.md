# Headless Codex reviewer — mechanics and failure modes

Reference for driving the fixed `codex exec` reviewer from any invoking host, supporting [`SKILL.md`](SKILL.md).

## Flags that carry weight

| Flag | Why the loop uses it |
|---|---|
| `-C <dir>` | The reviewer's working root. Point it at the worktree, not the primary checkout. |
| `-s read-only` | The reviewer reads and reports; it cannot edit. Keeps the two axes adversarial — a reviewer that can fix what it finds stops reporting it. |
| `--output-schema <file>` | Constrains the **final message** only. Subagents, tool calls, and reasoning run normally; just the report takes the schema's shape. |
| `-o <file>` | Writes that final message to a file. The reason findings never pass through a terminal. |
| `--json` | JSONL events on stdout. Useful for watching a round mid-flight; the loop reads `-o` instead. |

`codex exec review` is a separate subcommand running OpenAI's own review prompt. The loop does not use it — the two-axis skill is the review.

## The pinned model

Every round carries `-m gpt-5.6-sol -c model_reasoning_effort=high` on the command line. The pin is the point: `codex exec` otherwise inherits `~/.codex/config.toml`, which is shared with interactive Codex sessions and gets retuned for whatever they are doing. A review's depth is a property of the review, not of whatever the last session left in the config.

Both flags are load-bearing. `high` is where the two axes find defects a cheaper effort walks past, and reviews compare across rounds — a round run at a different model or effort is not comparable to the one before it, so residuals and non-convergence stop meaning anything.

Keep the pin on both the round-1 command and the resume command. Each shell call is fresh, so the flags cannot be hoisted into a shared variable; they are repeated because they must be.

`-c model_reasoning_effort=low` is for smoke-testing the plumbing, never for a round that reports findings. Confirm what actually ran by reading the header Codex prints to `codex.log`:

```
model: gpt-5.6-sol
reasoning effort: high
```

## Threads

A round prints its id to the log on start:

```
session id: 019fbb0c-3844-7001-b44f-12ec3007d6d4
```

Resume it explicitly by id. `codex exec resume --last` also works and filters to sessions matching the current directory — but any other Codex run in that worktree becomes the newest, and the loop silently resumes the wrong thread. By-id is deterministic.

`resume` is a subcommand, and its own option set is narrower than `codex exec`'s — `-C`, `-s`, and `--add-dir` are absent from it. Keep the whole flag block on `codex exec`, ahead of the subcommand:

```
codex exec <flags> resume "$THREAD_ID" "<prompt>"
```

Flags in that position govern the resumed session — the header it prints reports the working root, sandbox, model, and effort they set. That placement also makes the resume command round 1's command with one line inserted, so the two cannot drift.

A resumed round prints the same session id it was given, so recording the id again each round costs nothing and catches a version that forks instead.

Recovering a lost id: `~/.codex/session_index.jsonl` holds one `{"id", "thread_name", "updated_at"}` per session, newest last. Transcripts live under `~/.codex/sessions/<yyyy>/<mm>/<dd>/`. Resume defaults to cwd-filtered; `--all` widens it.

## Failure modes

**Hangs, log ends at `Reading additional input from stdin...`** — no `</dev/null`. Without a TTY, Codex treats stdin as piped and waits for EOF that never arrives. This blocks indefinitely, past any foreground timeout.

**`-o` file empty, exit non-zero** — the round died. The tail of `codex.log` carries the reason: auth expiry, sandbox denial, or a model error. Auth lives in `~/.codex/auth.json` and is shared with the interactive CLI, so an interactive `codex` run repairs it.

**Output does not match the schema** — Codex enforces the strict JSON Schema subset. Every property must appear in its object's `required`, every object needs `additionalProperties: false`, and optionality is expressed as a type union (`"type": ["integer", "null"]`) rather than by omission. A schema violating those is rejected before the review starts.

**Findings arrive thin or generic** — the review prompt did the work, not the schema. Depth comes from what the prompt asks the reviewer to judge; the schema only shapes the report.
