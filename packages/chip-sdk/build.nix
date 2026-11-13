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
  sdk,
  pname,
  targets,
  extraGnArgs,
  installCommands,
  checkCommands,
  meta,
  gnRoot ? null,
  chipRoot ? "",
  sourcePatches ? "",
  additionalSubmodules ? [ ],
}:
let
  inherit (sdk)
    version
    src
    openthreadSrc
    fetchedSubmoduleSources
    ;
  skippedSubmodulePaths = sdk.skippedSubmodulePaths or [ ];
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
    ''chip_crypto="openssl"''
    "symbol_level=0"
    "is_debug=false"
    ''custom_toolchain="//${chipRoot}build/toolchain/custom"''
    ''target_cc="${ccCompiler}"''
    ''target_cxx="${cxxCompiler}"''
    ''target_ar="${stdenv.cc.bintools}/bin/ar"''
    ''target_cpu="${gnTargetCpu}"''
  ]
  ++ extraGnArgs
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ ''mac_deployment_target="darwin"'' ];

  submoduleSources =
    map
      (
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
      )
      (
        (map (name: sdk.additionalSubmoduleSources.${name}) additionalSubmodules) ++ fetchedSubmoduleSources
      )
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
  inherit pname version src;

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

    ${sourcePatches}

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
      ${lib.optionalString (gnRoot != null) "--root=${gnRoot}"} \
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
      ${lib.concatStringsSep " " targets}
    )
    ninjaBuildPhase
  '';

  installPhase = ''
    runHook preInstall

    ${installCommands}

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    set -o pipefail

    ${checkCommands}

    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://github.com/project-chip/connectedhomeip";
    license = lib.licenses.asl20;
  }
  // meta;
}
