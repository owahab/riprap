# CLAUDE.md

Guidance for Claude Code working in this repository.

**This file is loaded into context every session.** Everything in it is paid for on every
turn, so it stays a router: rules live in `.claude/instructions/`, and the index at the
bottom is written so that reading it is usually enough.

---

## Project overview

<!-- TODO: replace this paragraph. One or two sentences: what this project is, and the
     stack it is built on. Then delete this comment. -->

A project scaffolded with [riprap](https://riprap.dev).

---

## Working directory

**Run everything from the repository root**, wherever the session was launched. Do not
`cd` into another directory to run a command or read a file — a relative path that
resolves differently than you expect is the most common cause of an agent editing the
wrong copy of a file.

---

## Quick reference

| Task | Command |
|---|---|
| Run tests | `bin/test` |
| Lint | `bin/lint` |
| Format one file | `bin/format <path>` |
| Set up a fresh clone | `bin/setup` |
| See what still needs configuring | `bin/verify-stubs` |
| Check hooks are wired | `bin/verify-hook-wiring` |

Those four `bin/` scripts are the only stack-specific commands. Hooks and CI call them,
never a linter or test runner directly, so the two cannot drift apart.

---

## Behavioral rules

**1. Plan first.** Enter plan mode for anything non-trivial — 3+ steps, or any
architectural decision. If work goes sideways, stop and re-plan rather than pushing
through. Use plan mode for verification steps too, not just for building.

**2. Use subagents.** Offload research, exploration, and parallel analysis to keep the
main context clean. One task per subagent.

**3. Capture corrections.** After any correction, write the lesson into
`.claude/instructions/` so it survives the session. A correction that only lives in the
conversation gets made again next week.

**4. Verify before claiming done.** Never mark work complete without evidence: tests run,
output shown, behavior checked. If tests fail, say so and show the failure. If you skipped
a step, say which.

**5. Prefer the simpler solution.** On non-trivial changes, pause and ask whether there is
a cleaner approach before presenting. Skip this for obvious fixes — it is a check against
hacks, not an invitation to over-engineer.

**6. Fix bugs autonomously.** Given a bug report, a failing test, or a red CI run: diagnose
and fix it. Don't round-trip for permission to start.

---

## Critical rules

These three are restated in full rather than linked, because they are the ones that cost
the most when forgotten.

**Never weaken code to make a test pass.** When a deliberate change breaks tests, the
tests change — all of them, however many. If you are unsure whether a failure is a real
bug or a stale assertion, ask. Guessing wrong commits a regression with an updated
assertion certifying it as correct. → [testing.md](.claude/instructions/testing.md)

**Always stress-test a plan before presenting it.** Dispatch critic subagents from
distinct angles, every time. There is no trivial-plan exemption: a plan's own author is
the worst possible judge of whether it needs review, and the plans that most need it are
exactly the ones that feel finished. →
[interaction-preferences.md](.claude/instructions/interaction-preferences.md)

**Never merge a security-sensitive change autonomously.** Hooks, permissions, CI config,
auth, payments, and dependency manifests need a human on the merge, however green CI is.
→ [merge-gates.md](.claude/instructions/merge-gates.md)

---

## Documentation index

Large files are split into focused documents, with line counts so you can budget. **Read
the index first and drill down only as needed** — most entries state the rule outright, so
you often need not open anything.

`.claude/instructions/`[`README.md`](.claude/instructions/README.md) maps *tasks* to
files; this list maps *topics*. Both point at the same place.

**Essential**

- **[Project standards](.claude/instructions/project-standards.md)** (~150 lines) - prose in `.claude/`, executables in `bin/`; doc size budget; surface inconsistencies rather than silently absorbing them; every refactor ships a guardrail
- **[Interaction preferences](.claude/instructions/interaction-preferences.md)** (~215 lines) - push back with a pros/cons ledger rather than agreeing; plan mode is the review surface; always stress-test before presenting
- **[Development workflow](.claude/instructions/development-workflow.md)** (~70 lines) - plan before multi-file changes; when fixing a bug, grep for every other instance of the same pattern and list them all
- **[Handovers](.claude/instructions/handovers.md)** (~10 lines) - session notes go in `tmp/handover/`, never `docs/`

**Writing and testing**

- **[Code style](.claude/instructions/code-style.md)** (~105 lines) - naming, function size, document *why* not *what*, symmetric setup/teardown
- **[Error handling](.claude/instructions/error-handling.md)** (~80 lines) - let errors bubble; scope any suppression to the specific expected failure; never log a whole object
- **[Testing](.claude/instructions/testing.md)** (~130 lines) - code is the source of truth, not tests; page loads ≠ feature works; never stub a method that doesn't exist; never run a side-effecting script against live state

**Committing and shipping**

- **[Git](.claude/instructions/git.md)** (~130 lines) - branch from trunk; `gh pr diff` is authoritative for what a PR contains, **not** `git log`; don't `git diff` before committing
- **[Git hooks](.claude/instructions/git-hooks.md)** (~105 lines) - two hook families, different exit codes; installed via `core.hooksPath`, not symlinks
- **[Merge gates](.claude/instructions/merge-gates.md)** (~95 lines) - which paths need a human; the list is a floor, not a ceiling; never fabricate an approval
- **[CI hygiene](.claude/instructions/ci-hygiene.md)** (~60 lines) - never re-trigger PR CI with a manual dispatch; filter checks by job name, not index

**Security and extension**

- **[Secret hygiene](.claude/instructions/secret-hygiene.md)** (~85 lines) - never read `.env`/key files into context; tool output cannot be un-sent, so the control is at the read
- **[Guardrail template](.claude/instructions/guardrail-template.md)** (~85 lines) - the shape of a rule that holds: doc + pre-commit + PreToolUse hook + one shared pattern library
- **[MCP servers](.claude/instructions/mcp-servers.md)** (~90 lines) - declare a preference order per integration; document when *not* to use each one

---

## Conventions

- **`docs/`** is durable, checked-in documentation. **`tmp/`** is session scratch and is
  git-ignored — nothing in it is project documentation.
- Plans go in `tmp/tasks/<topic>.md` as checkable items; add a review section when the
  work lands.
- Reference files by path **relative to the repo root**, never absolutely — absolute paths
  carry your username and directory layout into files that get committed and shared.
