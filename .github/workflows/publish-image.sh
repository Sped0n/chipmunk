#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: publish-image.sh REPOSITORY ARTIFACT_DIRECTORY}
images=${2:?Usage: publish-image.sh REPOSITORY ARTIFACT_DIRECTORY}
tag=$(<"$images/image-amd64/tag.txt")
test "$tag" = "$(<"$images/image-arm64/tag.txt")"

work=$(mktemp -d -t chipmunk-publish.XXXXXXXX)
cleanup() {
  rm -rf "$work"
}
trap cleanup EXIT

digests=()
for arch in amd64 arm64; do
  archive="$images/image-$arch/image.tar.gz"
  config=$(tar -xzOf "$archive" manifest.json | jq -er '.[0].Config')
  tar -xzOf "$archive" "$config" | jq -e --arg arch "$arch" \
    '.os == "linux" and .architecture == $arch' >/dev/null

  # crane reads uncompressed Docker archives and can push to a digest reference.
  tarball="$work/$arch.tar"
  gzip -dc "$archive" > "$tarball"
  digest=$(crane digest --tarball "$tarball")
  reference="$image@$digest"
  crane push "$tarball" "$reference"
  digests+=("$reference")
  rm "$tarball"
done

crane index append \
  --manifest "${digests[0]}" \
  --manifest "${digests[1]}" \
  --tag "$image:$tag"
crane tag "$image:$tag" latest
