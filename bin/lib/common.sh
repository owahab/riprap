#!/usr/bin/env bash
# Shared helpers for the riprap CLI. Sourced, never executed.

# Resolve the riprap repo root from any script under bin/.
riprap_root() {
  local d
  d="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
  printf '%s\n' "$d"
}

# Portable sha256. macOS ships `shasum`, Linux ships `sha256sum`.
sha256_of() {  # $1 = file
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

# The manifest of record: tier<TAB>path, one line per payload file.
# Comments and blank lines are ignored. This file IS the allowlist — nothing
# reaches an adopting project unless it is named here.
manifest_entries() {  # $1 = riprap root
  grep -vE '^[[:space:]]*(#|$)' "$1/template/MANIFEST"
}

die() { printf '%s\n' "$*" >&2; exit 1; }

# Refuse to operate on a target with uncommitted changes: install and update
# both overwrite files, and an adopter needs `git diff` to be a truthful record
# of what we did.
require_clean_tree() {  # $1 = target dir
  git -C "$1" rev-parse --git-dir >/dev/null 2>&1 || die "not a git repository: $1"
  [ -z "$(git -C "$1" status --porcelain)" ] || \
    die "target has uncommitted changes: $1
Commit or stash them first — you want git diff to show exactly what riprap changed."
}

# Write .riprap-manifest.json from records on stdin, one per line:
#   path<TAB>tier<TAB>sha256<TAB>state
#
# The sha256 recorded is always "what riprap last wrote", never "what is on disk
# now". That distinction is the whole basis of conflict detection: if we recorded
# the project's edited hash instead, the next update would mistake their work for
# ours and overwrite it.
write_manifest() {  # $1 = target dir, $2 = version string
  local target="$1" version="$2" entries="" path tier sha state
  while IFS=$'\t' read -r path tier sha state; do
    [ -n "$path" ] || continue
    entries="$entries$(printf '\n    {"path": "%s", "tier": "%s", "sha256": "%s", "state": "%s"},' \
      "$path" "$tier" "$sha" "$state")"
  done
  entries="${entries%,}"

  cat > "$target/.riprap-manifest.json" <<JSON
{
  "riprap_version": "$version",
  "note": "Written by riprap. Records which files riprap owns and the hash of what riprap last wrote, so 'riprap update' can tell your edits from ours. Safe to commit.",
  "tiers": {
    "template": "owned upstream; 'riprap update' refreshes it unless you changed it",
    "seed": "yours from the moment it lands; never overwritten"
  },
  "files": [$entries
  ]
}
JSON
}

# Hash recorded for a path in an existing manifest, if any.
recorded_sha() {  # $1 = manifest file, $2 = path
  [ -f "$1" ] || return 0
  awk -v p="\"$2\"" '
    index($0, "\"path\": " p) { found = 1 }
    found && /"sha256"/ {
      match($0, /"sha256": "[0-9a-f]*"/)
      print substr($0, RSTART + 11, RLENGTH - 12); exit
    }' "$1"
}

# Version stamp recorded in the target's manifest, so `update` can report what
# it is moving from and to.
riprap_version() {  # $1 = riprap root
  local tag sha
  sha=$(git -C "$1" rev-parse --short HEAD 2>/dev/null || echo unknown)
  tag=$(git -C "$1" describe --tags --exact-match 2>/dev/null || echo "")
  [ -n "$tag" ] && printf '%s (%s)\n' "$tag" "$sha" || printf '%s\n' "$sha"
}
