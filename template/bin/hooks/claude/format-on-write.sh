#!/usr/bin/env bash
# PostToolUse hook: format a file right after it is written.
#
# Keeps formatting out of the review conversation entirely — nobody spends a
# round trip on indentation if the file was already formatted before anyone
# looked at it.
#
# Delegates to bin/format so this hook knows nothing about your stack. If that
# stub is still unconfigured, this is a silent no-op: a template that errors on
# every edit before you have set it up would just get deleted.
set -euo pipefail

INPUT=$(cat)

# PostToolUse payloads carry the path in either shape depending on the tool.
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$FILE" ] || exit 0
[ -f "$FILE" ] || exit 0

FORMAT="${CLAUDE_PROJECT_DIR:-$(pwd)}/bin/format"
[ -x "$FORMAT" ] || exit 0
grep -q '^# riprap:stub$' "$FORMAT" 2>/dev/null && exit 0   # not configured yet

# exec so the formatter's own exit code becomes the hook's, and so a formatter
# that decides a file is out of scope reports that rather than being second
# guessed here.
exec "$FORMAT" "$FILE"
