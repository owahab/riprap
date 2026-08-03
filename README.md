# claude-code-starter

A starter scaffold for software projects built with [Claude Code](https://claude.com/claude-code).

Clone it and you begin with a tuned Claude Code setup already in place: behavioral guidelines that
push Claude toward planning and verification instead of guessing, two workflow skills, a convention
for capturing corrections so the same mistake doesn't recur, and a working-directory layout that
keeps session scratch out of your commits.

It is deliberately language- and framework-agnostic. There is no build system, no dependencies, and
nothing to install — just structure.

---

## Quick start

**New project** — click **[Use this template](https://github.com/owahab/claude-code-starter/generate)**
on GitHub to get your own repo with a clean history. Or clone and reset it yourself:

```bash
git clone git@github.com:owahab/claude-code-starter.git my-project
cd my-project
rm -rf .git && git init
```

**Existing project** — copy the scaffold in:

```bash
cp -r /path/to/claude-code-starter/{CLAUDE.md,.claude,docs,tmp} .
cat /path/to/claude-code-starter/.gitignore >> .gitignore
```

Then edit [CLAUDE.md](CLAUDE.md) to describe *your* project — build commands, architecture, house
style. The behavioral rules it ships with are a starting point, not scripture.

---

## What's inside

```
CLAUDE.md                       Behavioral guidelines Claude loads every session
.claude/
  settings.json                 Permission allowlist (pre-approved tool calls)
  instructions/                 Topic-specific rules, linked from CLAUDE.md
    handovers.md                Where session handover docs belong
  skills/
    learn/                      /learn  — capture session learnings
    spec/                       /spec   — structured feature interview
docs/                           Durable, checked-in project documentation
tmp/                            Session scratch — git-ignored
  tasks/                        Plans with checkable items, one file per topic
  handover/                     Session handoff notes
.gitignore                      Keeps tmp/ contents and .DS_Store out of commits
LICENSE                         MIT
```

Each `tmp/` directory keeps a `.gitignore` that ignores everything but itself, so the layout
survives a clone while nothing you write there is ever committed.

---

## Behavioral guidelines

[CLAUDE.md](CLAUDE.md) is loaded into context at the start of every session. It sets six rules:

| Rule | What it does |
|------|--------------|
| **Plan mode default** | Plan before any task of 3+ steps or with architectural stakes. If work goes sideways, stop and re-plan rather than pushing through. |
| **Subagent strategy** | Offload research, exploration, and parallel analysis to subagents — one task each — to keep the main context clean. |
| **Self-improvement loop** | After any correction, write the lesson into `.claude/instructions/` so it survives past the session. |
| **Verification before done** | Never call a task complete without evidence: tests run, logs checked, behavior diffed. |
| **Demand elegance** | On non-trivial changes, pause and ask whether there's a cleaner approach. Skipped for obvious fixes. |
| **Autonomous bug fixing** | Given a bug report, fix it — no hand-holding round-trips. |

Two core principles sit underneath: **simplicity first** (smallest change that solves it) and
**no laziness** (root causes, not band-aids).

Read [CLAUDE.md](CLAUDE.md) for the full text. Keep it small — push detail into
`.claude/instructions/` and link to it from there.

---

## Bundled skills

Both live in [.claude/skills/](.claude/skills/) and are available as slash commands in any session
opened from this repo.

### `/learn`

Reviews the session and writes what was learned into `CLAUDE.md` or `.claude/instructions/` — new
conventions, pitfalls, and permission prompts you approved repeatedly. Run it after a session where
you corrected Claude, so the correction sticks. It proposes; you decide.

See [learn/SKILL.md](.claude/skills/learn/SKILL.md).

### `/spec`

A planning-only stakeholder interview for defining a feature. Runs five phases — Vision, Users,
Scope, Integration, Constraints — and challenges the request at two checkpoints against redundancy,
value, complexity, integration fit, and how competitors handle it. Produces a feature document with
phased acceptance criteria, plus optional UI mockups. Writes no source code.

It also handles acceptance testing once every task under a feature is resolved.

See [spec/SKILL.md](.claude/skills/spec/SKILL.md).

---

## Conventions

**Where things go.** `docs/` is for durable documentation that belongs in the repo — plans,
contracts, runbooks. `tmp/` is session scratch and is git-ignored; nothing in it should be treated
as project documentation.

**Task tracking.** Plans go in `tmp/tasks/<topic>.md` as checkable items. Mark them off as you go,
and append a review section when the work lands.

**Handovers.** Session handoff notes go in `tmp/handover/`, named
`handover-<YYYY-MM-DD>-<topic>.md` — never in `docs/` or the repo root. When resuming, read from
there. See [handovers.md](.claude/instructions/handovers.md).

**Capturing corrections.** When you correct Claude, the fix belongs in
`.claude/instructions/<topic>.md` as a rule that prevents the mistake next time. `/learn` automates
this. `handovers.md` is the seed example of the pattern.

**Permissions.** [.claude/settings.json](.claude/settings.json) pre-approves tool calls so routine
work doesn't stop for a prompt. Add your own project's safe commands there.

---

## Recommended tools

All three are **optional** and configured in your user-level `~/.claude/` directory, not in this
repo — cloning the starter does not install them. The only thing this repo contributes is the
`Bash(rtk *)` allowlist in [.claude/settings.json](.claude/settings.json).

### Superpowers

<https://claude.com/plugins/superpowers>

A large library of process skills — brainstorming, systematic debugging, test-driven development,
writing plans, verification before completion — that pair naturally with the behavioral rules above.

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

### RTK

<https://github.com/rtk-ai/rtk>

A token-optimized CLI proxy. Wraps common dev commands (`git status`, builds, test runs) and filters
their output, cutting token use substantially on noisy operations. `rtk gain` reports what you saved.

Install the binary, then wire it up with a `PreToolUse` hook on `Bash` in `~/.claude/settings.json`
so commands are rewritten transparently. This repo allowlists `Bash(rtk *)` so the rewritten calls
don't prompt.

### Peon Ping

<https://www.peonping.com/>

Character-voice audio notifications for long-running sessions — you hear when Claude needs you
instead of watching the terminal. Runs as a user-level hook; wiring it to `PermissionRequest` means
it fires the moment Claude is waiting on your input. Ships skills for toggling, volume, and
voice-pack selection.

---

## License

MIT — see [LICENSE](LICENSE).
