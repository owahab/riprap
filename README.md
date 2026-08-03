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

---

## Every rule here has an incident behind it

This is what separates riprap from a list of things that sound sensible:

- **A secret scanner**, written after an API key matched a broad `grep`, landed in a tool
  result, and entered the conversation. The key had to be rotated — tool output cannot be
  un-sent. That is why the control sits at the *read*, not at some later filtering step.
- **A destructive-command blocker**, hardened across **five separate sandbox escapes** — a
  quoted path containing a space, an escaped quote that opened a fake quoted run, a
  dash-leading operand after `--`, and two more. Each is now a named regression test, and
  each is paired with a must-not-false-block control.
- **"Never source a side-effecting script against live state"**, written after a bug repro
  fired seven real writes against a live system and corrupted an unrelated record. Nothing
  was permanently lost, but only because a later write happened to overwrite the damage.
  That was luck, not a control.
- **A merge gate**, added after a self-reviewed PR touching a security hook came within one
  step of merging with a genuine regression in it.
- **A one-shot-consume warning on handover files**, written after a session destroyed its
  own state by "verifying" a write it had just made — the read printed the file *and
  deleted it*. A verification step that consumes the thing it verifies is not a
  verification step.

---

## Install

```bash
git clone git@github.com:owahab/riprap.git ~/Projects/riprap
ln -s ~/Projects/riprap/bin/riprap /usr/local/bin/riprap   # optional

riprap install ~/Projects/my-app
cd ~/Projects/my-app && bin/setup
```

Your project is **not** a fork of riprap. It receives a copy plus a manifest, and keeps
its own history and remote. Then:

```bash
riprap update ~/Projects/my-app                # pull improvements, keeping your edits
riprap contribute ~/Projects/my-app <path>     # send one back upstream
```

### What update will and will not touch

Every installed file is one of two tiers, recorded in `.riprap-manifest.json`:

| Tier | Behaviour |
|---|---|
| `template` | Owned upstream. `update` refreshes it — **unless you changed it**, in which case it reports the conflict and leaves your version alone. |
| `seed` | Yours from the moment it lands: `CLAUDE.md`, `.claude/settings.json`, and the four `bin/` stubs. Never overwritten. |

The manifest records the hash of what riprap last wrote, which is what lets `update` tell
your work from ours rather than guessing.

---

## What you get

```
CLAUDE.md                      loaded every session; a router, not a rulebook
.claude/
  settings.json                permissions + hook wiring
  instructions/                14 docs, indexed by task
  skills/                      /learn  /spec  /council  /branch-cleaner
bin/
  test lint format setup       ← the only stack-specific files. You fill these in.
  verify-stubs                 what still needs configuring
  verify-hook-wiring           catches a hook that exists but is not wired
  hooks/
    claude/                    PreToolUse / PostToolUse — exit 2 blocks a tool call
    git/                       pre-commit, pre-push — exit 1 rejects a commit
    lib/                       pattern libraries, shared by BOTH families
    tests/                     71 assertions, runnable in your own repo
docs/ tmp/                     durable docs; git-ignored session scratch
```

### The stack seam

Four executable stubs are the only files that know what language you write in:

| Stub | Contract | Called by |
|---|---|---|
| `bin/test` | run the suite | pre-push, CI |
| `bin/lint` | lint the repo, or the given paths | pre-commit, CI |
| `bin/format` | format one file | format-on-write hook |
| `bin/setup` | install hooks and dependencies | you, once |

Hooks and CI call these and nothing else, so **local checks and CI cannot drift apart** —
there is one definition of "run the tests". Each stub ships with examples for common
ecosystems and a `# riprap:stub` marker to delete. Until you do, they degrade to a notice
rather than an error.

### The guardrail architecture

A convention that lives only in a document is a suggestion. Riprap's rules have four
layers: the document, a pre-commit check, a PreToolUse hook, and **one shared pattern
library sourced by both hooks**.

That fourth layer is the one people skip and the one that matters. With two copies of a
regex set they drift, and the day they drift is the day one of them silently stops
enforcing what you believe is enforced.

`bin/hooks/claude/lint-example.sh` and `bin/hooks/lib/example-patterns.sh` are a working
skeleton to copy; `.claude/instructions/guardrail-template.md` is the document shape.

---

## Behavioral rules

`CLAUDE.md` ships six, loaded every session:

| Rule | What it does |
|---|---|
| **Plan first** | Plan before any 3+ step or architectural task. If work goes sideways, stop and re-plan rather than pushing through. |
| **Use subagents** | Offload research and parallel analysis, one task each, to keep the main context clean. |
| **Capture corrections** | After any correction, write the lesson into `.claude/instructions/` so it outlives the session. |
| **Verify before done** | Never claim complete without evidence. If tests fail, say so and show the output. |
| **Prefer the simpler solution** | On non-trivial changes, pause and ask whether there is a cleaner approach. |
| **Fix bugs autonomously** | Given a failing test or a red CI run, diagnose and fix it without a round trip. |

Plus three restated in full because they cost the most when forgotten: never weaken code
to make a test pass; always stress-test a plan before presenting it; never merge a
security-sensitive change autonomously.

---

## Conventions

- **`docs/`** is durable, checked-in documentation. **`tmp/`** is session scratch and is
  git-ignored — nothing in it is project documentation.
- Plans go in `tmp/tasks/<topic>.md` as checkable items, with a review section when the
  work lands.
- Session handovers go in `tmp/handover/`, named `handover-<YYYY-MM-DD>-<topic>.md`.
- Reference files by path relative to the repo root, never absolutely.

---

## Honest limits

- These are one codebase's conclusions. They are a floor to extend, not a ceiling.
- Several encode trade-offs another team would reasonably resolve the other way. The merge
  gate in particular is deliberately conservative and will occasionally annoy you.
- The permission deny-list in `settings.json` stops **mistakes**, not a determined bypass.
  Prefix matching cannot do more than that, and the file says so out loud. The hooks are
  the real enforcement.
- `bin/format` runs on every write. If your formatter is slow, you will feel it.

---

## Recommended tools

All optional, all configured in your user-level `~/.claude/`, not by this repo.

**[Superpowers](https://claude.com/plugins/superpowers)** — process skills (brainstorming,
systematic debugging, TDD, writing plans, verification) that pair naturally with the rules
above.

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

**[RTK](https://github.com/rtk-ai/rtk)** — a token-optimized CLI proxy that wraps noisy dev
commands and filters their output. `settings.json` allowlists `Bash(rtk *)`.

**[Peon Ping](https://www.peonping.com/)** — character-voice audio notifications, so you
hear when Claude needs you instead of watching the terminal.

---

## License

MIT — see [LICENSE](LICENSE).
