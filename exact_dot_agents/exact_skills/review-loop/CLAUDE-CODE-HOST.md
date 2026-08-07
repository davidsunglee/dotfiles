# Invoking the loop from Claude Code

Host branch for [`SKILL.md`](SKILL.md). Use these mechanics for the reviewer process and remediator dispatch; the main skill owns the loop's semantics and gates.

## Run the reviewer

Start the `codex exec` command through the Bash tool with `run_in_background: true`. Keep `</dev/null` on the command. Record the returned background task id and wait for that task's terminal exit notification; it is the round's sole liveness signal. Then apply step 2's completion criterion in the main skill.

## Dispatch the remediator

Dispatch one Agent tool call with `subagent_type: review-remediator`. Give it a bounded prompt containing only:

- the absolute worktree path
- the absolute `findings.json` path
- the absolute `ledger.jsonl` path
- the round number

Wait for it to finish before judging the round. It is the only subagent writing to the worktree during remediation.

Claude Code discovers the personal agent from `~/.claude/agents/review-remediator.md`. When that agent is unavailable, dispatch a general-purpose write-capable subagent and instruct it to read [`REMEDIATOR.md`](REMEDIATOR.md) completely before acting. Pass the same four inputs and no rewritten finding prose.
