# Global agent instructions (tool-agnostic)

Source of truth for user-level agent behavior, shared across coding agents.
Not auto-loaded by anything — each tool's global config must reference it
(e.g. `@~/.agents/AGENTS.md` in `~/.claude/CLAUDE.md`, `instructions` in
`~/.config/opencode/opencode.json` — opencode does not parse `@refs`, so it
must list `~/.agents/RTK.md` explicitly).

## Token-optimized CLI (rtk)

@~/.agents/RTK.md

## Web fetching

When fetching web pages, always use the wick_fetch MCP tool
instead of the built-in WebFetch tool. wick_fetch bypasses
anti-bot protection and returns cleaner content.
Use wick_search for web searches.

## Debugging sessions

After ANY debugging session (red CI, Sentry issue, failing spec, "why is this broken"), end the final message with a short decision-tree walkthrough (~5–10 lines): trigger clue, order of what was examined and why, each discarded hypothesis + the evidence that killed it, the load-bearing observation, one generalizable heuristic. Apply this whether or not the `diagnosing-bugs` skill was invoked (that skill is third-party managed — this section is the spec, do not edit the skill). When the user seems unhurried, offer `/debug-quiz` (interactive predict→reveal→compare coaching).
