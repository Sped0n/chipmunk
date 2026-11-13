# chipmunk

Matter/CHIP tooling.

## Nix usage

The default CHIP version is `1.6.1.0`. Host tools support `x86_64-linux`,
`aarch64-linux`, and `aarch64-darwin`. Example apps support both Linux architectures.

```bash
nix run github:Sped0n/chipmunk#chip-host-tools -- --help
nix shell github:Sped0n/chipmunk#chip-host-tools -c chip-cert help
nix run github:Sped0n/chipmunk#zap-cli-bin -- --version
nix run github:Sped0n/chipmunk#chip-lighting-app -- --help
nix shell github:Sped0n/chipmunk#chip-examples
```

`default` is an alias for `chip-host-tools`. To select an older host-tool version,
use a versioned package name:

```bash
nix build github:Sped0n/chipmunk#chip-host-tools_1_5_1_0
```

Available host-tool versions are `1.6.1.0`, `1.6.0.0`, `1.5.1.0`, and `1.5.0.1`.

For direnv:

```bash
use flake github:Sped0n/chipmunk#chip-host-tools
```

To add chipmunk as a flake input:

```nix
inputs.chipmunk.url = "github:Sped0n/chipmunk";
```

### Binary cache

Cache URL: <https://nix-cache.sped0n.com/nix-cache>

Public signing key:

```text
nix-cache.sped0n.com-1:2QjPOhbTs8xHYPpe0tuGIQQ+DFmEZMv05UAfHzU9Crg=
```

## Docker usage

`ghcr.io/sped0n/chipmunk` supports `linux/amd64` and `linux/arm64`. Docker selects
the host architecture automatically. Each container runs one executable and
accepts its upstream arguments. The default executable is `all-devices-app`.

These names work as both Nix package names and Docker commands:

- `all-devices-app`
- `chip-all-clusters-app`
- `chip-rvc-app`
- `chip-lighting-app`
- `chip-lock-app`
- `thermostat-app`
- `chip-bridge-app`
- `chip-ota-provider-app`
- `chip-ota-requestor-app`

The image has no shell. Get `chip-tool`, `chip-cert`, and ZAP from the Nix
packages.

To see an app's options:

```bash
docker run --rm ghcr.io/sped0n/chipmunk:latest chip-lighting-app --help
```

Run a light on a Linux Docker host and keep its state in a named volume:

```bash
docker run --rm --name matter-light --network host \
  -v matter-light:/tmp \
  ghcr.io/sped0n/chipmunk:latest \
  chip-lighting-app --discriminator 3840
```

Use `--device` to add endpoints to `all-devices-app`. This example creates a light
at endpoint 1 and a contact sensor at endpoint 2:

```bash
docker run --rm --network host -v matter-devices:/tmp \
  ghcr.io/sped0n/chipmunk:latest \
  all-devices-app --device on-off-light:1 --device contact-sensor:2
```

### Networking and state

- The apps use upstream test credentials. Use them for development and testing,
  not as production devices. Do not expose them on untrusted networks.
- Matter requires IPv6 and multicast discovery. Use host networking on Linux.
  Publishing UDP ports on a Docker bridge network does not provide the same
  access. Docker Desktop networking is untested.
- The apps use IP networking. BLE, Wi-Fi provisioning, and Thread are disabled.
  Containers do not need privileged mode or a host D-Bus mount.
- The process runs with user ID and group ID `65534`. Mount a separate named
  volume at `/tmp` for each device. Removing the volume deletes the device's
  commissioning state. Bind-mounted state directories must allow this user to
  write files.
- Containers share host ports. Give each device a distinct discriminator and
  `--secured-device-port` value. Use `--port` for `all-devices-app`. Do not share
  state volumes between devices.
- Use each app's upstream CLI or named-pipe controls to simulate events. Mount
  any required simulation inputs, OTA payloads, and configuration files where
  the container can read them.
- The OTA provider requires `--filepath` or `--otaImageList` and exits without one.
  OTA requestors can apply executable updates. Use only trusted test payloads in
  isolated environments.

### Image tags

- `latest` selects the latest published image.
- `<CHIP-version>-<12-character-content-hash>` selects specific image contents.

Both tags support AMD64 and ARM64. The content hash comes from the multi-platform
index digest. Use the full registry digest to pin an exact image.

### Build the image locally

```bash
nix build .#docker-image
docker load -i result
```

Read the local tag and run an app:

```bash
tag=$(nix eval --raw .#docker-image.imageTag)
docker run --rm "ghcr.io/sped0n/chipmunk:$tag" chip-lighting-app --help
```

Locally built images use the CHIP version as their tag.
