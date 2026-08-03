---
name: learn
description: Review the current session and update CLAUDE.md and .claude/instructions/ with new learnings, patterns, or insights discovered. Use when the user runs /learn or asks to document what was learned this session.
license: MIT
---

# Learn - Document Session Learnings

Review the current session and update CLAUDE.md with any new learnings, patterns, or insights discovered.

## Steps

1. **Review session context**: Identify new patterns/conventions, model/controller/view structures, testing patterns, configuration details, common pitfalls, **and repeated permission prompts** (same tool + argument approved 2+ times in the session).

2. **Read current CLAUDE.md** and `.claude/instructions/` files relevant to the session's domain.

3. **Identify gaps**: What new information would help future sessions? What's missing or outdated?

4. **Update documentation**: Add to `.claude/instructions/` or enhance existing files:
   - Keep additions concise and actionable
   - Follow existing document style
   - Group related information logically
   - Avoid duplicating existing content

## Guidelines

- Only add information that would genuinely help future Claude sessions
- Prefer specific, actionable guidance over general observations
- Keep entries concise — this is a reference document, not a journal
- If no significant learnings *and* no repeated permission prompts, report that and skip the update
- Keep CLAUDE.md small and refer to instructions from `.claude/instructions/`
- Permission suggestions are always user-approved — the skill proposes, the user decides
