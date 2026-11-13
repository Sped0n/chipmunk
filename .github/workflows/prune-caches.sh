#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_REPOSITORY:?Set GITHUB_REPOSITORY}"
: "${GITHUB_REF:?Set GITHUB_REF}"

work=$(mktemp -d -t chipmunk-prune.XXXXXXXX)
cleanup() {
  rm -rf "$work"
}
trap cleanup EXIT

gh cache list --repo "$GITHUB_REPOSITORY" --ref "$GITHUB_REF" --limit 10000 \
  --json id,key,ref,createdAt > "$work/caches.json"

# Called only after all builds, publications, and clean-store downloads succeed.
jq -r --arg ref "$GITHUB_REF" '
  map(select(.ref == $ref)) |
  (
    (.[] | select(.key | test("^nix-(store-build|image)-")) | .id),
    (
      map(select(.key | test("^ccache-(image-(X64|ARM64)|(Linux-(X64|ARM64)|macOS-ARM64)-chip-host-tools_[0-9_]+)-[0-9a-f]{64}$"))) |
      group_by(.key | sub("-[0-9a-f]{64}$"; ""))[] |
      sort_by(.createdAt, .id) | reverse | .[1:][] | .id
    )
  )
' "$work/caches.json" > "$work/delete-ids"

while IFS= read -r id; do
  gh cache delete "$id" --repo "$GITHUB_REPOSITORY"
done < "$work/delete-ids"
