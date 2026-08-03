---
title: riprap
---

# riprap

Guardrails, conventions, and enforcement for projects built with
[Claude Code](https://claude.com/claude-code).

> **Every rule in riprap was earned in production.**
>
> This is the distilled output of ≈6 months of continuous, daily agent-assisted
> development on a live codebase — 53 instruction documents (≈10,800 lines), 12
> enforcement hooks, 20 skills, and 16 agent roles, all of it running against real code
> with real consequences.
>
> Nothing here was written because it sounded like good practice. Every rule is here
> because something broke first, and the incident that caused it is recorded next to it.

Riprap is deliberately not a framework starter, a deploy pipeline, or an issue-tracker
integration. It assumes nothing about your stack beyond four scripts in `bin/`.

## Install

```bash
git clone git@github.com:owahab/riprap.git ~/Projects/riprap
ln -s ~/Projects/riprap/bin/riprap /usr/local/bin/riprap

riprap install ~/Projects/my-app
cd ~/Projects/my-app && bin/setup
```

Your project does not become a fork. It receives a copy plus a manifest, and keeps its own
history and remote.

```bash
riprap update ~/Projects/my-app                # pull improvements, keeping your edits
riprap contribute ~/Projects/my-app <path>     # send one back upstream
```

## Every rule has an incident behind it

- **A secret scanner**, after an API key matched a broad `grep`, landed in a tool result,
  and entered the conversation. The key had to be rotated — tool output cannot be un-sent.
- **A destructive-command blocker**, hardened across five separate sandbox escapes, each
  now a named regression test paired with a must-not-false-block control.
- **"Never source a side-effecting script against live state"**, after a bug repro fired
  seven real writes and corrupted an unrelated record. Nothing was permanently lost, but
  only because a later write happened to overwrite the damage. That was luck.
- **A merge gate**, after a self-reviewed PR touching a security hook came within one step
  of merging with a genuine regression in it.

## Further reading

- [Guardrail architecture](guardrails.md) — how a rule is made to hold
- [Source on GitHub](https://github.com/owahab/riprap)
