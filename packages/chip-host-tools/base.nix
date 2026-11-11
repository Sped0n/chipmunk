{
  lib,
  stdenv,
  fetchgit,
  applyPatches,
  zapCliBin,
  gn,
  ninja,
  pkg-config,
  python3,
  glib,
  ccache,
  ccacheWrapper,
  dbus,
  avahi,
  libevent,
  openssl,
  readline,
  version,
  src,
  openthreadSrc,
  fetchedSubmoduleSources,
  skippedSubmodulePaths ? [ ],
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      click
      coloredlogs
      jinja2
      lark
      lxml
      ps."python-path"
    ]
  );

  ccCompiler = "${ccacheWrapper}/bin/cc";
  cxxCompiler = "${ccacheWrapper}/bin/c++";
  gnTargetCpu =
    {
      aarch64 = "arm64";
      x86_64 = "x64";
      i686 = "x86";
      armv7l = "arm";
    }
    .${stdenv.hostPlatform.parsed.cpu.name}
      or (throw "Unsupported GN target_cpu for ${stdenv.hostPlatform.system}");

  gnArgs = [
    "chip_build_tools=true"
    ''chip_mdns="platform"''
    ''chip_crypto="openssl"''
    "chip_inet_config_enable_ipv4=false"
    "symbol_level=0"
    "is_debug=false"
    ''custom_toolchain="//build/toolchain/custom"''
    ''target_cc="${ccCompiler}"''
    ''target_cxx="${cxxCompiler}"''
    ''target_ar="${stdenv.cc.bintools}/bin/ar"''
    ''target_cpu="${gnTargetCpu}"''
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ ''mac_deployment_target="darwin"'' ];

  submoduleSources =
    map (
      { path, ... }@source:
      let
        src = fetchgit (removeAttrs source [ "path" ]);
      in
      {
        inherit path;
        src =
          if path == "third_party/libwebsockets/repo" && lib.versionOlder version "1.6" then
            applyPatches {
              inherit src;
              name = "libwebsockets-const-correct";
              postPatch = ''
                # strchr preserves const with newer toolchains; the username buffer stays mutable.
                substituteInPlace lib/plat/unix/unix-caps.c \
                  --replace-fail "char *colon =" "const char *colon =" \
                  --replace-fail ", u[33];" $';\n\tchar u[33];'
              '';
            }
          else
            src;
      }
    ) fetchedSubmoduleSources
    ++ [
      {
        path = "third_party/openthread/repo";
        src = openthreadSrc;
      }
    ];

  linkedSubmoduleSources = builtins.filter (
    source: !(builtins.elem source.path skippedSubmodulePaths)
  ) submoduleSources;

  linkSubmodules = lib.concatMapStringsSep "\n" (
    { path, src }:
    ''
      rmdir "${path}"
      mkdir -p "$(dirname "${path}")"
      ln -s ${src} "${path}"
    ''
  ) linkedSubmoduleSources;
in
stdenv.mkDerivation {
  pname = "chip-host-tools";
  inherit version src;

  strictDeps = true;
  enableParallelBuilding = true;
  hardeningDisable = lib.optionals stdenv.hostPlatform.isDarwin [ "stackclashprotection" ];

  nativeBuildInputs = [
    ccache
    gn
    ninja
    pkg-config
    zapCliBin
    pythonEnv
    glib
  ];

  buildInputs = [
    glib
    libevent
    openssl
    readline
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    avahi
    dbus
  ];

  doInstallCheck = true;

  postPatch = ''
    ${linkSubmodules}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      python -c '
      from pathlib import Path

      path = Path("examples/chip-tool/BUILD.gn")
      old = """if (chip_device_platform == \"darwin\" || chip_crypto == \"boringssl\") {"""
      new = """if (chip_crypto == \"boringssl\") {"""
      content = path.read_text()
      if old in content:
          path.write_text(content.replace(old, new, 1))
      '
    ''}

    cat > build_overrides/pigweed_environment.gni <<'EOF'
    # Generated for Nix builds.
    # The full Pigweed bootstrap flow downloads external tools and is intentionally skipped here.
    EOF
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    export CC="${ccCompiler}"
    export CXX="${cxxCompiler}"

    build_dir="$PWD/out/host"
    mkdir -p "$build_dir"

    gn gen \
      --check \
      --fail-on-unused-args \
      --script-executable="${pythonEnv}/bin/python" \
      "$build_dir" \
      --args='${lib.concatStringsSep " " gnArgs}'

    runHook postConfigure
  '';

  buildPhase = ''
    ninjaFlagsArray+=(
      -C "$PWD/out/host"
      chip-tool
      chip-cert
    )
    ninjaBuildPhase
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 out/host/chip-tool "$out/bin/chip-tool"
    install -Dm755 out/host/chip-cert "$out/bin/chip-cert"

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    set -o pipefail

    payload_parse_output="$TMPDIR/chip-tool-payload-parse.txt"
    "$out/bin/chip-tool" payload parse-setup-payload 34970112332 2>&1 | tee "$payload_parse_output"
    grep -q "Passcode:.*20202021" "$payload_parse_output"

    "$out/bin/chip-cert" help

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Matter host tools from Project CHIP";
    homepage = "https://github.com/project-chip/connectedhomeip";
    license = licenses.asl20;
    mainProgram = "chip-tool";
    platforms = platforms.unix;
  };
}
