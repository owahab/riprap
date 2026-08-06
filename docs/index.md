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

riprap is a Claude Code plugin. There is nothing to clone.

```
/plugin marketplace add owahab/riprap
/plugin install riprap
/riprap:install
```

The plugin carries the documents, the skills, and the Claude hooks — none of which put a
file in your repository, and none of which touch your `CLAUDE.md` or `.claude/settings.json`.
`/riprap:install` adds the half that has to live in the repo: the guardrail scripts, their
pattern libraries, the git hooks, and the four stack commands the hooks call.

Everything it writes there lives under `bin/hooks/riprap/`, a path only riprap uses, so
installing into a repo that already has its own instructions, skills, and hooks cannot
overwrite any of them. Run it again any time — it is also the update path.

Full instructions, including requirements, teammates, and what to do when another tool
already owns your git hooks: **[Installing riprap](install.md)**.

Improvements flow back as ordinary pull requests.

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

## License

riprap is **source-available** under PolyForm Perimeter 1.0.1, not an OSI open source licence.

Use it for anything, including commercially and at work. What you may not do is provide to others
a product that competes with riprap — you cannot repackage and sell it, and you cannot publish a
competing fork, free ones included. Attribution travels with every copy, and the name is reserved.

Installing riprap places a copy of the licence at `bin/hooks/riprap/LICENSE` in your repository. If
your organisation runs automated licence scanning, that file will be flagged as an unrecognised
licence, because PolyForm has no SPDX identifier. Worth knowing before you install rather than
after.

## Further reading

- [Installing riprap](install.md) — the three commands, and what lands where
- [Guardrail architecture](guardrails.md) — how a rule is made to hold
- [Licence](https://github.com/owahab/riprap/blob/main/LICENSE) ·
  [Trademark policy](https://github.com/owahab/riprap/blob/main/TRADEMARK.md) ·
  [Contributing](https://github.com/owahab/riprap/blob/main/CONTRIBUTING.md)
- [Source on GitHub](https://github.com/owahab/riprap)
