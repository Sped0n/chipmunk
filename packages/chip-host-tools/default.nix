{
  lib,
  stdenv,
  buildChip,
  sdk,
}:
(buildChip {
  inherit sdk;
  pname = "chip-host-tools";
  targets = [
    "chip-tool"
    "chip-cert"
  ];
  extraGnArgs = [
    "chip_build_tools=true"
    ''chip_mdns="platform"''
    "chip_inet_config_enable_ipv4=false"
  ];

  sourcePatches = lib.optionalString stdenv.hostPlatform.isDarwin ''
    python -c '
    from pathlib import Path

    path = Path("examples/chip-tool/BUILD.gn")
    old = """if (chip_device_platform == \"darwin\" || chip_crypto == \"boringssl\") {"""
    new = """if (chip_crypto == \"boringssl\") {"""
    content = path.read_text()
    if old in content:
        path.write_text(content.replace(old, new, 1))
    '
  '';

  installCommands = ''
    install -Dm755 out/host/chip-tool "$out/bin/chip-tool"
    install -Dm755 out/host/chip-cert "$out/bin/chip-cert"
  '';

  checkCommands = ''
    payload_parse_output="$TMPDIR/chip-tool-payload-parse.txt"
    "$out/bin/chip-tool" payload parse-setup-payload 34970112332 2>&1 | tee "$payload_parse_output"
    grep -q "Passcode:.*20202021" "$payload_parse_output"

    "$out/bin/chip-cert" help
  '';

  meta = {
    description = "Matter host tools from Project CHIP";
    mainProgram = "chip-tool";
    platforms = lib.platforms.unix;
  };
}).overrideAttrs
  {
    stripAllList = [ "bin" ];

    # Mach-O must retain external symbols used by the dynamic linker.
    stripAllFlags =
      if stdenv.hostPlatform.isDarwin then
        [
          "-S"
          "-x"
        ]
      else
        [
          "-s"
          "-p"
        ];
  }
