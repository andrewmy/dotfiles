# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Usage

In Claude Code, a hook rewrites commands automatically (`git status` →
`rtk git status`, transparent, 0 tokens overhead). In other agents
(opencode, codex, …) there is no hook — prefix dev commands with `rtk`
yourself (git, gh, grep/rg, find, ls, tree, test runners, docker, kubectl).
