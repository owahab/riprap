---
title: Installing riprap
---

# Installing riprap

Three commands, and nothing to clone.

```
/plugin marketplace add owahab/riprap
/plugin install riprap@riprap
/riprap:install
```

Run the first two once, in any Claude Code session. Run the third from inside each project
you want guarded.

---

## What each step does

**`/plugin marketplace add owahab/riprap`** registers this repository as a plugin
marketplace. riprap is its own marketplace, so there is no directory to go through.

**`/plugin install riprap@riprap`** installs the plugin: 16 guardrail documents, four
skills, and the Claude hook registrations. The form is `plugin@marketplace`, and here both
are called `riprap` — the repetition is correct, not a typo. Nothing lands in any
repository. You can stop here if all you want is the documents and skills.

**`/riprap:install`** adds the half that has to live in the repo: the guardrail scripts,
their shared pattern libraries, the git hooks, and the four stack commands the hooks call.
Run it from the root of a git repository with a clean working tree.

It is also the update path. Re-run it any time; it is idempotent.

---

## Requirements

- **Claude Code.** The plugin and its skills are a Claude Code feature.
- **A git repository** with a clean working tree, for `/riprap:install`. The clean-tree
  requirement is what makes `git checkout --` the undo button, so nothing is backed up to
  `.orig` files that then need cleaning up.
- **`jq`**, for the Claude hooks. `brew install jq` or `apt-get install jq`.

`jq` is worth installing before anything else. The hooks read the tool payload as JSON on
stdin, and without it the three blocking hooks — secret hygiene, the destructive-command
blocker, the merge gate — **refuse every call they inspect**, with a message telling you to
install it. That is deliberate: a guardrail that waved things through because a dependency
was missing would be worse than one that stops you. The git hooks and `bin/riprap` do not
need `jq`.

---

## What lands in your repository

Only these. Nothing else in your project is touched.

```
bin/
  test lint format setup    the only stack-specific files. You fill these in.
  riprap                    wire / verify
  hooks/
    git/                    pre-commit, pre-push — yours, delegating to riprap's
    riprap/                 riprap's own, refreshed on every install
```

| Tier | What | On re-install |
|---|---|---|
| namespaced | `bin/hooks/riprap/**`, `bin/riprap` | Replaced wholesale; files riprap stops shipping are removed |
| seed | `bin/hooks/git/*`, `bin/{test,lint,format,setup}` | Written once if absent, never replaced |

**Your `CLAUDE.md` and `.claude/settings.json` are never touched.** The documents reach the
model through a SessionStart hook and the skills are namespaced by the harness as
`/riprap:learn`, `/riprap:spec`, `/riprap:council`, `/riprap:branch-cleaner`. There is
nothing to merge, and a project with its own `/learn` keeps it.

Everything riprap overwrites lives under a path only riprap uses, so installing into a repo
that already has its own instructions, skills, and hooks cannot clobber any of them.

---

## After installing

### Fill in the stack seams

`bin/test`, `bin/lint`, `bin/format`, and `bin/setup` are the only files that know what
language you write in. Hooks and CI call **only** these, which is what stops local checks
drifting from CI.

Each ships as a stub carrying a line reading `# riprap:stub`. Until you replace it, the
hook that calls it does nothing — `bin/riprap verify` lists which are outstanding.
`/riprap:install` will look at your project, propose wrappers over what it finds, and ask
before writing them.

### Tell your teammates

`core.hooksPath` is **local git config. It is not cloned.** A teammate who checks the repo
out has no hooks at all until something runs `bin/riprap wire` — and they may not have the
plugin installed either, which is exactly why that command is a script in the repo rather
than only a slash command.

Add it to whatever people already run on a fresh clone:

```bash
# in bin/setup
bin/riprap wire
```

### Verify

```bash
bin/riprap verify
```

Checks that the hooks are present and executable, that their pattern libraries resolve,
that the stack seams are configured — and that `core.hooksPath` points at a directory which
actually contains an executable `pre-commit`. That last one catches the common state where
the setting looks configured and enforces nothing.

---

## If another tool already owns your git hooks

`bin/riprap wire` **will not take `core.hooksPath` from husky, lefthook, or a hand-rolled
`.githooks/`.** That setting names one directory and git stops looking anywhere else, so
claiming it would disable every one of their hooks with no error and no output.

Instead it refuses and prints the line to add to the incumbent's `pre-commit`, just after
the shebang:

```bash
"$(git rev-parse --show-toplevel)"/bin/hooks/riprap/git/pre-commit "$@" || exit $?
```

For `pre-push`, add `</dev/null` before `|| exit $?`. Git feeds the list of refs being
pushed on stdin, and a subprocess that reads it consumes it — leaving the incumbent with an
empty stream and no way to know.

Both sets of checks then run on every commit.

---

## Extending riprap's rules

Your own guardrails go in `bin/hooks/lib/`, which riprap never writes to.

To add a pattern to a rule riprap *already* enforces, do not fork its library — you would
lose every future upstream fix to the rest of it. Add
`bin/hooks/lib/<rule>-patterns.local.sh` instead; riprap's library sources it if present,
so your patterns survive an update.

```bash
# bin/hooks/lib/secret-patterns.local.sh
SECRET_TOKEN_PATTERNS+=( 'acme_[A-Za-z0-9]{32}' )
```

---

## Updating

Update the plugin through `/plugin`, then re-run `/riprap:install` in each project to
refresh the repo-side half. `bin/riprap verify` warns when the two halves have drifted,
since they update through different channels.

## Removing it

```bash
bin/riprap wire --uninstall     # unwire the git hooks
rm -rf bin/hooks/riprap bin/riprap
```

Then uninstall the plugin through `/plugin`. Your seed files — the git hook entry points
and the four stack commands — are yours, and deleting them is your call.

---

## Further reading

- [Guardrail architecture](guardrails.md) — how a rule is made to hold
- [Source on GitHub](https://github.com/owahab/riprap)
