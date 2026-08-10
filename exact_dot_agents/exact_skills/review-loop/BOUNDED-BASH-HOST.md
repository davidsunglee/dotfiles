# Invoking the loop from bounded Bash

Host branch for [`SKILL.md`](SKILL.md). Use this branch from HumanLayer and other Claude Code surfaces whose Bash tool offers only bounded foreground calls. The main skill owns the loop's semantics and gates.

## Run the reviewer

Launch step 2's `codex exec` argv through the bundled launcher; it owns stdin and log redirection:

```bash
"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  launch "$ROUND" -- codex exec ...
```

The launcher returns after recording `$ROUND/reviewer.pid`. It publishes `$ROUND/reviewer.done` atomically when the detached process exits; the file contains its numeric exit status.

Poll with `detached-reviewer.sh status "$ROUND"` in Bash calls of at most 60 seconds. Classify its output:

| State | Meaning | Action |
|---|---|---|
| `complete 0` | reviewer returned | apply step 2's completion criterion |
| `complete N` | reviewer exited nonzero | read the log tail and handle the failed round |
| `running PID` | recorded worker is live | wait at most 60 seconds, inspect the log tail as needed, and poll again |
| `lost ...` or `failed ...` | reviewer outcome was lost | read the log tail, then retry |
| `unverifiable ...` | the host cannot prove which process owns the PID | keep the current state intact and poll again; surface the host limitation if it persists |

`reviewer.done` is the terminal signal; the PID and launch identity supply liveness only. After inspecting a failed state, retry the same round with the same argv:

```bash
"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  retry "$ROUND" -- codex exec ...
```

Retry archives the prior state under `$ROUND/reviewer-attempts/<NN>/` before relaunching. It accepts terminal or lost state and refuses running or unverifiable state.

## Dispatch the remediator

On Codex, spawn the installed custom agent named `review-remediator`. On Claude Code, dispatch one Agent tool call with `subagent_type: review-remediator`. Give it a bounded task containing only:

- the absolute worktree path
- the absolute `findings.json` path
- the absolute `ledger.jsonl` path
- the round number

Wait for it to finish before judging the round. It is the only subagent writing to the worktree during remediation.

Codex discovers the personal agent from `~/.codex/agents/review-remediator.toml`; Claude Code discovers it from `~/.claude/agents/review-remediator.md`. When the host cannot select that agent, dispatch a general-purpose write-capable subagent and instruct it to read [`REMEDIATOR.md`](REMEDIATOR.md) completely before acting. Pass the same four inputs and no rewritten finding prose.
