---
title: Guardrail architecture
---

# Guardrail architecture

A convention that lives only in a document is a suggestion. Riprap's rules have four
layers, and the fourth is the one that matters.

## The four layers

1. **The document** — `.claude/instructions/<topic>.md`: the rule, why it exists, the
   correct usage, and the exceptions.
2. **A pre-commit check** — a block in `bin/hooks/git/pre-commit` scanning staged
   additions, emitting `file:line` violations, exiting 1.
3. **A PreToolUse hook** — `bin/hooks/claude/lint-<topic>.sh`, catching the same patterns
   at edit time rather than commit time, exiting 2 with the reason on stderr.
4. **One shared pattern library** — `bin/hooks/lib/<topic>-patterns.sh`, holding the
   patterns *and* the allow-list, sourced by both hooks above.

Layer 4 is the one people skip. With two copies of a regex set they drift, and the day
they drift is the day one of them silently stops enforcing what you believe is enforced.

## Two hook families

They are different systems and confusing them is the most common mistake:

| | Trigger | Blocks with | Message goes to |
|---|---|---|---|
| `bin/hooks/claude/` | a tool call | exit **2** | **stderr** — stdout is discarded |
| `bin/hooks/git/` | a commit or push | exit **1** | stdout is fine |

Exit 0 means allow, and is also the right answer for every "this does not concern me"
case: wrong tool, wrong file type, exempt path, empty content.

## Fail closed

Where a hook cannot verify something, it blocks. The destructive-command blocker refuses
when it cannot determine the working directory; the merge gate refuses when it cannot
determine which files a PR touches. An unverifiable action is indistinguishable from an
unsafe one, and treating them differently is how a guardrail becomes decorative.

## Every rule needs an escape hatch

A line tagged `lint-ok:<rule>` is skipped. This is not a weakness — a guardrail with no
way out gets disabled wholesale the first time it is wrong, and then it protects nothing.
Riprap's own test suite needs it: the secret hook would otherwise block every commit that
includes the tests written to verify it.

## Verify the wiring

```bash
bin/verify-hook-wiring
```

A hook that exists but is not referenced in `settings.json` is worse than no hook, because
you stop thinking about the thing it was meant to cover. This check exists because exactly
that happened: a lint hook and its pattern library were written, reviewed, merged — and
silently never wired. It looked enforced for months.
