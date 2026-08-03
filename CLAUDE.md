# CLAUDE.md — working on riprap itself

Guidance for Claude Code working **on this repository**. If you are looking for the rules
riprap ships to projects, those are in [template/CLAUDE.md](template/CLAUDE.md).

## What this repo is

riprap is a distributable template. Three things must not be confused:

| | What it is |
|---|---|
| **This repo** | riprap's own source. You develop *on* it. |
| **`template/`** | The payload that gets installed into a project. Mirrors the target layout exactly. |
| **An adopting project** | An unrelated repo that received a *copy* of the payload plus a manifest. Never a fork. |

A change to `template/` changes what every future adopter receives. A change outside it
changes only riprap.

## The rules that are easy to get wrong here

**`template/MANIFEST` is the allowlist, and it is generated.** `bin/install` copies only
what it lists and refuses anything unlisted. After adding or removing a file under
`template/`, run `bin/build-manifest`. CI fails if it drifts.

**Nothing binary or generated goes in `template/`.** A `.pyc` or `.DS_Store` carries
absolute source paths and identifiers that no text scrubber can see inside, and a
recursive copy will happily deliver one into someone's public repo. `bin/scrub-check`
refuses non-text files outright.

**`template/.claude/` is markdown only** — plus `settings.json`, because the harness
requires that exact path. Every executable lives under `template/bin/`. CI enforces this
with one `find`.

**Two hook families, two exit codes.** `template/bin/hooks/claude/` blocks a tool call
with exit 2 and its message must go to **stderr**; `template/bin/hooks/git/` rejects a
commit with exit 1. They share pattern libraries in `template/bin/hooks/lib/` so a rule
has one definition and two enforcers.

**Everything published gets scrubbed.** riprap is distilled from a private codebase.
`bin/scrub-check` gates `template/` and `docs/` in CI, and every file promoted by
`bin/contribute`. If a hit is deliberate, add it to `allowed()` or `allowed_line()`
**with a stated reason** — an unexplained exemption is indistinguishable from an oversight.

## Before you commit

```bash
bin/build-manifest --check                       # manifest matches the tree
bin/scrub-check template/ docs/ README.md        # nothing leaks
for t in template/bin/hooks/tests/test-*.sh; do bash "$t"; done
shellcheck -S warning $(find bin template/bin -type f \( -name '*.sh' -o -perm -u+x \))
```

Changes to hooks deserve more than that: install into a scratch repo and confirm a fresh
install still commits cleanly. riprap's own test fixtures contain token-shaped strings,
and without their `lint-ok:secrets` markers the secret hook blocks its own installation.
That is the kind of bug only a round trip finds.

## Style

Match what is already here. Every rule states *why*, ideally with the cost of getting it
wrong — a rule whose reason is missing gets worked around by whoever finds it inconvenient.
Where a rule came from an incident, keep the mechanism and the cost, and drop anything that
identifies a person, a company, or a date.

Prefer prose that a tired reader gets right on the first pass over prose that is shorter.
