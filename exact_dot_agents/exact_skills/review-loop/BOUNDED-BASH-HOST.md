# Invoking the loop from bounded Bash

Host branch for [`SKILL.md`](SKILL.md). Use this branch from HumanLayer, CodeLayer, and other surfaces whose Bash tool has no resumable session handle. The main skill owns the loop's semantics and gates.

## Run the reviewer

Launch step 2's `codex exec` argv through the bundled launcher; it owns stdin and log redirection:

```bash
"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  launch "$ROUND" -- codex exec ...
```

The launcher returns after recording `$ROUND/reviewer.pid`. It publishes `$ROUND/reviewer.done` atomically when the detached process exits; the file contains its numeric exit status.

Immediately enter one blocking wait, setting the Bash tool's `timeout` to `3600000` milliseconds so the call, rather than the model, owns the polling loop:

```bash
"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  wait "$ROUND"
```

`wait` checks the detached process until it reaches a terminal state, then prints one of these results:

| State | Meaning | Action |
|---|---|---|
| `complete 0` | reviewer returned | apply step 2's completion criterion |
| `complete N` | reviewer exited nonzero | read the log tail and handle the failed round |
| `running PID` | recorded worker is live | returned only by the diagnostic `status` command, never by `wait` |
| `lost ...` or `failed ...` | reviewer outcome was lost | read the log tail, then retry |
| `unverifiable ...` | the host cannot prove which process owns the PID | returned only by `status`; `wait` keeps watching the terminal sentinel |

`reviewer.done` is the terminal signal; the PID and launch identity supply liveness only. If the Bash call itself is interrupted or times out, issue the same `wait` command again — the detached process remains the sole reviewer. Use `status` only to inspect it between turns. After inspecting a failed state, retry the same round with the same argv:

```bash
"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  retry "$ROUND" -- codex exec ...
```

Retry archives the prior state under `$ROUND/reviewer-attempts/<NN>/` before relaunching. It accepts terminal or lost state and refuses running or unverifiable state.

## Dispatch the remediator

Read the Agent tool's available types from its tool description. If it lists `review-remediator`, dispatch that named agent with a bounded task containing only:

- the absolute worktree path
- the absolute `findings.json` path
- the absolute `ledger.jsonl` path
- the round number

Wait for it to finish before judging the round. It is the only subagent writing to the worktree during remediation.

The CodeLayer Agent registry is separate from the Codex CLI registry: `~/.codex/agents/review-remediator.toml` does not make the type available to CodeLayer. When `review-remediator` is absent, run the remediator as a pinned high-effort Codex process instead of selecting a low-effort fallback:

```bash
REMEDIATOR_PROCESS="$ROUND/remediator-process"
ROUND_NUMBER=${ROUND##*/round-}
mkdir "$REMEDIATOR_PROCESS"

"$HOME/.agents/skills/review-loop/scripts/detached-reviewer.sh" \
  launch "$REMEDIATOR_PROCESS" -- \
  codex exec \
    -C "$WORKTREE" --approve-for-me \
    --add-dir "$(dirname "$LEDGER")" \
    -m gpt-5.6-sol -c model_reasoning_effort=high \
    -o "$ROUND/remediator-final.txt" \
    "Read $HOME/.agents/skills/review-loop/REMEDIATOR.md completely and follow it as the authoritative brief.
Worktree: $WORKTREE
Findings: $ROUND/findings.json
Ledger: $LEDGER
Round: $ROUND_NUMBER"
```

Enter `detached-reviewer.sh wait "$REMEDIATOR_PROCESS"` immediately with the same `3600000` millisecond Bash timeout. On `complete 0`, apply step 3's completion criterion from the main skill. Handle any other terminal state like a reviewer failure, retrying the same process only after inspecting its log. Pass paths to the Codex process and no rewritten finding prose.
