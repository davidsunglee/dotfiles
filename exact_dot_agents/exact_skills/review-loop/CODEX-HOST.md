# Invoking the loop from Codex

Host branch for [`SKILL.md`](SKILL.md). Use these mechanics for the reviewer process and remediator dispatch; the main skill owns the loop's semantics and gates.

## Run the reviewer

Run step 2's `codex exec` command with `</dev/null >"$ROUND/codex.log" 2>&1` appended, using `exec_command` with a short initial yield. When it returns a live `session_id`, continue that same session with `write_stdin` until it exits. Poll in intervals no longer than 60 seconds and keep the user updated between polls. The live session owns the process and its final exit status; starting a replacement process would duplicate the round.

The unified shell session handles the long runtime, so the command itself stays in the foreground rather than being suffixed with `&`.

The round has returned only when the shell tool reports a terminal exit. Then apply step 2's completion criterion in the main skill.

## Dispatch the remediator

Spawn the installed custom agent named `review-remediator`. Give it a bounded task containing only:

- the absolute worktree path
- the absolute `findings.json` path
- the absolute `ledger.jsonl` path
- the round number

Wait for it to finish before judging the round. It is the only subagent writing to the worktree during remediation.

Codex discovers the personal agent from `~/.codex/agents/review-remediator.toml`. When the current spawn surface cannot select named custom agents or the agent is not loaded, spawn one general-purpose write-capable subagent and instruct it to read [`REMEDIATOR.md`](REMEDIATOR.md) completely before acting. Pass the same four inputs and no rewritten finding prose.

Subagents inherit the parent turn's live permissions. Run the loop from a parent turn whose writable roots include the worktree.
