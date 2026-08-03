# Instructions index

A map from what you are doing to the file that covers it. Organised by task, not by
filename.

---

## Starting work

- Opening a session in this repo for the first time? → [project-standards.md](project-standards.md) (~150 lines)
- Proposing a plan, a design, or an alternative? → [interaction-preferences.md](interaction-preferences.md) (~215 lines)
- Deciding whether to plan or just do it? → [development-workflow.md](development-workflow.md) (~70 lines)
- Picking up from a previous session, or ending one? → [handovers.md](handovers.md) (~10 lines)

## Writing code

- Naming things, sizing functions, writing comments? → [code-style.md](code-style.md) (~105 lines)
- Catching, raising, suppressing, or logging an error? → [error-handling.md](error-handling.md) (~80 lines)
- Fixing a bug and wondering how far the pattern spreads? → [development-workflow.md](development-workflow.md) (~70 lines)
- Reaching for an external tool or integration? → [mcp-servers.md](mcp-servers.md) (~90 lines)

## Testing

- Writing tests, or staring at a failing one? → [testing.md](testing.md) (~130 lines)
- Deciding whether the code or the test is wrong? → [testing.md](testing.md) (~130 lines)

## Committing and merging

- Branching, committing, opening a pull request? → [git.md](git.md) (~130 lines)
- A hook blocked you, or you need to install or bypass one? → [git-hooks.md](git-hooks.md) (~105 lines)
- About to merge? → [merge-gates.md](merge-gates.md) (~95 lines)
- CI is red, or needs re-running? → [ci-hygiene.md](ci-hygiene.md) (~60 lines)

## Security

- Handling a credential, a token, or a key? → [secret-hygiene.md](secret-hygiene.md) (~85 lines)
- Touching hooks, permissions, auth, payments, or a lockfile? → [merge-gates.md](merge-gates.md) (~95 lines)

## Extending riprap itself

- Turning a fixed inconsistency into a rule that holds? → [guardrail-template.md](guardrail-template.md) (~85 lines)
- Adding a doc, a hook, or a stack command? → [project-standards.md](project-standards.md) (~150 lines)
- Adding an integration? → [mcp-servers.md](mcp-servers.md) (~90 lines)

---

## Reading strategy

**Check this map before opening anything.** Guessing from filenames costs more than
reading one list: `git.md` and `git-hooks.md` sound interchangeable and cover different
problems, and the file you want for "CI is red" is not named after CI in most repos.

**Read the smallest file that covers your question.** These are reference documents, not a
manual — nobody needs all of them, and reading a large one to reach one paragraph spends
context that the actual task needs.

**The line counts are there so you can budget.** Two 80-line files usually beat one
215-line file when either would answer the question.

---

## Reading chains

- **First time here** → [project-standards.md](project-standards.md) → [interaction-preferences.md](interaction-preferences.md) → [git.md](git.md)
- **First code change** → [development-workflow.md](development-workflow.md) → [code-style.md](code-style.md) → [testing.md](testing.md)
- **First merge** → [git.md](git.md) → [merge-gates.md](merge-gates.md) → [ci-hygiene.md](ci-hygiene.md)
- **Adding a guardrail** → [project-standards.md](project-standards.md) → [guardrail-template.md](guardrail-template.md) → [git-hooks.md](git-hooks.md)
