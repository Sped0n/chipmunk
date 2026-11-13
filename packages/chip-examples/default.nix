{
  lib,
  buildChip,
  sdk,
  app,
}:
buildChip {
  inherit sdk;
  pname = app.binary;
  gnRoot = app.path;
  chipRoot = "third_party/connectedhomeip/";
  targets = [ app.binary ];
  additionalSubmodules = [ "miniaudio" ];
  extraGnArgs = [
    ''chip_mdns="minimal"''
    "chip_inet_config_enable_ipv4=true"
    "chip_config_network_layer_ble=false"
    "chip_enable_wifi=false"
    "chip_enable_thread=false"
  ];

  installCommands = ''
    install -Dm755 out/host/${app.binary} "$out/bin/${app.binary}"
  '';

  checkCommands = ''
    "$out/bin/${app.binary}" --help > "$TMPDIR/help.txt" 2>&1
    grep -q -- '--discriminator' "$TMPDIR/help.txt"
  '';

  meta = {
    description = "Matter ${app.binary} Linux example";
    mainProgram = app.binary;
    platforms = lib.platforms.linux;
  };
}
