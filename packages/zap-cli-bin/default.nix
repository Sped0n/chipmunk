{
  fetchzip,
  lib,
  makeWrapper,
  asar,
  nodejs_24,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) isDarwin isLinux;

  sources = {
    x86_64-linux = {
      url = "https://github.com/project-chip/zap/releases/download/v2026.10.06/zap-linux-x64.zip";
      hash = "sha256-8onV9jQy4j89YzESdIOaTzTHhCqP8lXlT3QI1tFM0ks=";
    };
    aarch64-linux = {
      url = "https://github.com/project-chip/zap/releases/download/v2026.10.06/zap-linux-arm64.zip";
      hash = "sha256-k1WUryDlXTcr22DYUWdu5sZlqi3+//9GGaP9n2g5CAc=";
    };
    aarch64-darwin = {
      url = "https://github.com/project-chip/zap/releases/download/v2026.10.06/zap-mac-arm64.zip";
      hash = "sha256-7RI+UDRB+Mn9OYK4jtQ0vV6x440O+kfQpI857S2MAHA=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "zap-cli-bin is unsupported on ${stdenvNoCC.hostPlatform.system}");

  linuxMainProcess = "${placeholder "out"}/libexec/zap-cli-app/dist/src-electron/main-process/main.js";
in
stdenvNoCC.mkDerivation {
  pname = "zap-cli-bin";
  version = "2026.10.06";

  src = fetchzip {
    inherit (source) url hash;
    stripRoot = false;
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = lib.optionals isLinux [
    makeWrapper
    asar
  ];

  doInstallCheck = stdenvNoCC.hostPlatform.system == stdenvNoCC.buildPlatform.system;

  installPhase = ''
    runHook preInstall

    ${lib.optionalString isLinux ''
      install -d "$out/bin"

      asar extract ./resources/app.asar "$out/libexec/zap-cli-app"

      # The CLI runs under Node, where Electron's API module is unavailable.
      substituteInPlace "$out/libexec/zap-cli-app/dist/src-electron/util/env.js" \
        --replace-fail "const electron = require('electron');" \
          "const electron = process.versions.electron ? require('electron') : undefined;"

      makeWrapper ${lib.getExe nodejs_24} "$out/bin/zap-cli" \
        --argv0 zap-cli \
        --add-flags ${lib.escapeShellArg linuxMainProcess}
    ''}

    ${lib.optionalString isDarwin ''
      install -Dm755 ./zap-cli "$out/bin/zap-cli"
    ''}

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    if ! "$out/bin/zap-cli" --version; then
      "$out/bin/zap-cli" -v
    fi

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Prebuilt ZAP release assets packaged for Project CHIP";
    homepage = "https://github.com/project-chip/zap";
    license = licenses.asl20;
    mainProgram = "zap-cli";
    platforms = builtins.attrNames sources;
  };
}
