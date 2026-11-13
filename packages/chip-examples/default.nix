{
  lib,
  buildChip,
  sdk,
  appName,
  appPath,
}:
buildChip {
  inherit sdk;
  pname = appName;
  gnRoot = appPath;
  chipRoot = "third_party/connectedhomeip/";
  targets = [ appName ];
  additionalSubmodules = [ "miniaudio" ];
  extraGnArgs = [
    ''chip_mdns="minimal"''
    "chip_inet_config_enable_ipv4=true"
    "chip_config_network_layer_ble=false"
    "chip_enable_wifi=false"
    "chip_enable_thread=false"
  ];

  installCommands = ''
    install -Dm755 out/host/${appName} "$out/bin/${appName}"
  '';

  checkCommands = ''
    "$out/bin/${appName}" --help > "$TMPDIR/help.txt" 2>&1
    grep -q -- '--discriminator' "$TMPDIR/help.txt"
  '';

  meta = {
    description = "Matter ${appName} Linux example";
    mainProgram = appName;
    platforms = lib.platforms.linux;
  };
}
