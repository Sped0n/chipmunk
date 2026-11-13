#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: publish-image.sh REPOSITORY ARTIFACT_DIRECTORY}
images=${2:?Usage: publish-image.sh REPOSITORY ARTIFACT_DIRECTORY}
chip_version=$(<"$images/image-amd64/version.txt")
test "$chip_version" = "$(<"$images/image-arm64/version.txt")"

work=$(mktemp -d -t chipmunk-publish.XXXXXXXX)
cleanup() {
  rm -rf "$work"
}
trap cleanup EXIT

for arch in amd64 arm64; do
  archive="$images/image-$arch/image.tar.gz"
  config=$(tar -xzOf "$archive" manifest.json | jq -er '.[0].Config')
  tar -xzOf "$archive" "$config" | jq -e --arg arch "$arch" \
    '.os == "linux" and .architecture == $arch' >/dev/null

  # crane reads uncompressed Docker archives.
  gzip -dc "$archive" > "$work/$arch.tar"
done

crane index append "$work/index" \
  --manifest "$work/amd64.tar" \
  --manifest "$work/arm64.tar"

# Hash the exact multi-platform index bytes, without embedding the tag in them.
digest=$(sha256sum "$work/index/index.json")
digest=${digest%% *}
tag="$chip_version-${digest:0:12}"
reference=$(crane push --index "$work/index" "$image:$tag")
crane tag "$reference" latest
