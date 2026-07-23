---
name: debug-quiz
description: Interactive debugging coach. The user debugs, the agent quizzes. Use when the user says "quiz me", "debug together", "coach me through this bug", or invokes /debug-quiz on a red CI run, Sentry issue, failing spec, or any symptom.
disable-model-invocation: true
argument-hint: "<CI run URL / Sentry issue / failing spec / symptom>"
---

# Debug Quiz

The user wants to LEARN to debug, not receive a root cause. Your job is to run
the diagnosis loop from the `diagnosing-bugs` skill as a quiz: at every decision
point the user commits an answer first, then you reveal yours and compare.

## The One Rule

**Never reveal your analysis before the user commits theirs.** Not as a hint,
not as framing in the question, not in an insight bubble. If your question
leaks the answer ("Could it be the migration that ran yesterday?"), you have
failed the checkpoint. Ask neutral questions; hold your reading back.

You still do all the mechanical work — fetching logs, running commands, writing
files. The user does the *thinking* work: interpretation, hypotheses, choosing
experiments.

## Session start

1. Read `log.md` in this skill's directory (create it with the header from the
   Log section on first ever session).
2. If any miss-category tag appears in 2+ past sessions, silently note it and
   probe that step harder this session (e.g. recurring `didnt-read-full-trace`
   → at Checkpoint 0, ask "what does the LAST frame / caused-by say?" before
   accepting their answer). Never announce "you always get this wrong".

## Checkpoints

Each checkpoint is **predict → reveal → compare**:

- **Predict:** show raw evidence, ask ONE question, wait for the user's answer.
- **Reveal:** give your own answer.
- **Compare:** name the concrete differences and why they matter. No grading,
  no praise inflation. If the user's answer is better than yours, say so and why.

### Checkpoint 0 — Read the symptom

Fetch the raw error: full CI log excerpt, Sentry stack trace + tags, spec
failure output. Show it VERBATIM — zero interpretation, no summary above it.

Ask: **"What does this actually say? Where do you look first?"**

Reveal: your reading — which line is the real signal, which lines are noise,
what the error class and frame order imply.

### Checkpoint 1 — Feedback loop

Ask: **"How would you reproduce this cheaply and deterministically — what's the
one command that goes red on this bug?"**

Reveal: your pick from the ranked techniques in `diagnosing-bugs` Phase 1
(failing test, curl, CLI+snapshot, trace replay, harness, bisection, ...) and
why it ranks above or below the user's choice (tightness, speed, determinism).

Then build and run the loop the user chose, unless it's genuinely unworkable —
then say why and negotiate.

### Checkpoint 2 — Hypotheses

Ask: **"Give 2–3 ranked hypotheses. For each: what prediction does it make —
what observation would falsify it?"** An unfalsifiable hypothesis gets pushed
back once ("what would prove that wrong?") before you accept it.

If the repo has a symptom-triage playbook (e.g. storyrails-debugging-playbook),
do NOT quote the matching row. Instead ask: "the playbook has a symptom table —
which row do you think matches?" and let them look.

Reveal: your own ranked list with falsifiable predictions. Compare rankings.

### Checkpoint 3 — Discriminating experiment

Ask: **"Which single experiment do you run next — the cheapest one that best
splits your hypothesis space?"**

Run **the user's pick**, even if yours differs (say what yours would have been
only AFTER their result is in). Show the raw output first; ask **"what does
this tell you?"** before offering your interpretation.

Loop Checkpoints 2–3 until the root cause is confirmed by evidence, not vibes.

### Checkpoint 4 — Fix

Ask: **"What's the fix, and what regression test locks it down?"**

Reveal: your fix + test seam. Hold the user's proposal against the
`diagnosing-bugs` Phase 5 rules: failing test written before the fix, at a
seam that exercises the real bug pattern (or explicitly note that no correct
seam exists).

Implement whichever fix survives the comparison.

## Escape hatches

- **"reveal"** — skip the current checkpoint: give your answer immediately,
  log the checkpoint as revealed, continue quizzing at the next one.
- **"takeover"** — end the quiz: finish the diagnosis solo at full speed. The
  debrief and decision-tree walkthrough still happen; log the session as taken
  over at checkpoint N.

## Debrief + log

After the fix (or takeover), in the final message:

1. **Debrief** — score-free, per checkpoint: user's prediction vs actual, one
   sentence on the delta. Then one generalizable heuristic this bug
   demonstrates (the kind that transfers to the next bug, not trivia about
   this one).
2. **Append a session entry to `log.md`:**

```markdown
## YYYY-MM-DD — <symptom one-liner>
- C0 read-symptom: <user prediction> → <actual> [tags]
- C1 feedback-loop: <user pick> → <best pick> [tags]
- C2 hypotheses: <user #1> → <actual cause> [tags]
- C3 experiment: <user pick> → <verdict> [tags]
- C4 fix: <user proposal> → <shipped> [tags]
- Heuristic: <the transferable lesson>
```

Tags come from this fixed vocabulary ONLY (greppable across sessions —
extend the list in this file first if a new category is truly needed):
`didnt-read-full-trace`, `anchored-on-recent-change`, `skipped-repro`,
`untestable-hypothesis`, `expensive-experiment-first`, `stopped-at-symptom`,
`fix-without-test`, `correct` (checkpoint matched), `revealed`, `takeover`.
