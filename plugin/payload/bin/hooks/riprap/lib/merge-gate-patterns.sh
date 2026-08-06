#!/usr/bin/env bash
# Shared pattern library for the security-sensitive merge gate.
# Sourced by bin/hooks/riprap/claude/block-unreviewed-merge.sh.
# See merge-gates.md for the rule and the hold procedure.
#
# The rule: changes to these paths are never merged autonomously, however clean
# the review and however green the CI. It was written after a self-reviewed PR
# touching a security hook came within one step of merging with a real
# regression in it. The review still has value — it caught real bugs that time —
# but the merge decision for these paths belongs to a human.

# Paths where an autonomous merge is not permitted.
#
# Note the hook directories are on this list deliberately: they are the guardrail
# machinery itself. A change there can disable every other control in this repo,
# and no test suite reliably catches "the guardrail stopped guarding".
#
# The list covers other projects' hook layouts, not just riprap's, and that is
# not defensive padding: riprap installs *alongside* whatever a repo already had,
# so the machinery this gate protects is routinely in a directory riprap did not
# choose. A gate that only recognises its own paths waves through edits to the
# hooks actually doing the enforcing.
MERGE_GATE_PATTERNS=(
  'bin/hooks/'
  '.claude/hooks/'
  '.claude/settings.json'
  '.githooks/'
  '.husky/'
  'lefthook.yml'
  '.pre-commit-config.yaml'
  '.github/workflows/'
  '.github/CODEOWNERS'
)

# Filename fragments that usually mean money, identity, or access.
MERGE_GATE_KEYWORDS=(
  auth
  session
  token
  credential
  permission
  policy
  payment
  billing
  invoice
  checkout
)

# Dependency manifests and lockfiles: a new dependency is the classic
# supply-chain vector, and a lockfile diff is exactly where it hides.
MERGE_GATE_MANIFESTS=(
  'package.json' 'package-lock.json' 'yarn.lock' 'pnpm-lock.yaml'
  'requirements.txt' 'pyproject.toml' 'poetry.lock' 'uv.lock'
  'Gemfile' 'Gemfile.lock'
  'go.mod' 'go.sum'
  'Cargo.toml' 'Cargo.lock'
  'composer.json' 'composer.lock'
)

# Echo every gated path from a newline-separated file list on stdin.
# Returns 0 if any matched, 1 if none did.
merge_gate_match() {
  local files="$1" found=1 f pat kw base
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    base="${f##*/}"

    for pat in "${MERGE_GATE_PATTERNS[@]}"; do
      case "$f" in *"$pat"*) echo "$f  (matches $pat)"; found=0; continue 2 ;; esac
    done
    for kw in "${MERGE_GATE_KEYWORDS[@]}"; do
      case "$f" in *"$kw"*) echo "$f  (matches *$kw*)"; found=0; continue 2 ;; esac
    done
    for pat in "${MERGE_GATE_MANIFESTS[@]}"; do
      [ "$base" = "$pat" ] && { echo "$f  (dependency manifest)"; found=0; continue 2; }
    done
  done <<< "$files"
  return $found
}

# --- project extension point ------------------------------------------------
# riprap owns this file and overwrites it on every update, so a pattern added
# here is gone the next time. Project-specific patterns go in the file below
# instead: riprap never writes anywhere in bin/hooks/lib/. It is sourced last, so
# it can append to any array above or replace a function outright.
#
# Without this the only way to add one pattern is to fork the whole library, and
# forking it gives up every future upstream fix to the other patterns in it.
_riprap_local="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lib/merge-gate-patterns.local.sh"
if [ -r "$_riprap_local" ]; then
  # shellcheck source=/dev/null
  . "$_riprap_local"
fi
unset _riprap_local
