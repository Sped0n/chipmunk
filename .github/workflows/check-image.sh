#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: check-image.sh IMAGE}
: "${CHIP_TOOL:?Set CHIP_TOOL to the matching chip-tool executable}"
: "${CHIP_SOURCE:?Set CHIP_SOURCE to the matching connectedhomeip source directory}"
cd "$(dirname "$0")/../.."
work=$(mktemp -d -t chipmunk-check.XXXXXXXX)
volume="chipmunk-${work##*/}"
container=

cleanup() {
  status=$?
  if [ "$status" -ne 0 ]; then
    if [ -n "$container" ]; then docker logs "$container" >&2 || true; fi
    for log in "$work"/*.log; do
      if [ -f "$log" ]; then cat "$log" >&2; fi
    done
  fi
  if [ -n "$container" ]; then docker rm -fv "$container" >/dev/null || true; fi
  docker volume rm "$volume" >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

wait_for_start() {
  for ((attempt = 0; attempt < 30; attempt++)); do
    if [ "$(docker inspect "$container" --format '{{.State.Running}}')" != true ]; then
      return 1
    fi
    if docker logs "$container" 2>&1 | grep -F 'Server Listening...' >/dev/null; then
      return 0
    fi
    sleep 1
  done
  return 1
}

apps=$(nix eval --json --file packages/chip-examples/apps.nix \
  --apply builtins.attrNames)
mapfile -t binaries < <(jq -r '.[]' <<< "$apps")
printf '%s\n' '{"deviceSoftwareVersionModel":[]}' > "$work/ota-images.json"
chmod 644 "$work/ota-images.json"
for binary in "${binaries[@]}"; do
  docker run --rm "$image" "$binary" --help > "$work/$binary.log" 2>&1
  grep -q -- '--discriminator' "$work/$binary.log"
  rm "$work/$binary.log"
  port_option=--secured-device-port
  if [ "$binary" = all-devices-app ]; then port_option=--port; fi
  docker_args=()
  app_args=()
  if [ "$binary" = chip-ota-provider-app ]; then
    docker_args=(--mount "type=bind,src=$work/ota-images.json,dst=/ota-images.json,readonly")
    app_args=(--otaImageList /ota-images.json)
  fi
  container=$(docker run -d --network host "${docker_args[@]}" "$image" "$binary" \
    --discriminator 3841 "$port_option" 5541 "${app_args[@]}")
  wait_for_start
  echo "Started $binary"
  docker stop -t 10 "$container" >/dev/null
  docker rm -v "$container" >/dev/null
  container=
done

# Test a real fabric and operational state across replacement of the container.
docker volume create "$volume" >/dev/null
start_light() {
  container=$(docker run -d --network host -v "$volume:/tmp" "$image" \
    chip-lighting-app --discriminator 3841 --secured-device-port 5541)
  wait_for_start
}
chip_tool() {
  timeout 90 "$CHIP_TOOL" "$@" --storage-directory "$work" \
    --paa-trust-store-path "$CHIP_SOURCE/credentials/development/paa-root-certs"
}
start_light
chip_tool pairing already-discovered 1 20202021 ::1 5541 > "$work/pairing.log" 2>&1
chip_tool onoff on 1 1 > "$work/on.log" 2>&1
chip_tool onoff read on-off 1 1 > "$work/read.log" 2>&1
grep -q 'OnOff: TRUE' "$work/read.log"
docker stop -t 10 "$container" >/dev/null
docker rm "$container" >/dev/null
container=
start_light
chip_tool onoff off 1 1 > "$work/off-after-restart.log" 2>&1
chip_tool onoff read on-off 1 1 > "$work/read-after-restart.log" 2>&1
grep -q 'OnOff: FALSE' "$work/read-after-restart.log"
echo 'All apps started; commissioning, control, and persisted fabric checks passed.'
