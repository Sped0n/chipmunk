{
  lib,
  runCommand,
  stdenv,
  examplePackages,
  src,
  version,
}:
runCommand "chip-examples-${version}"
  {
    nativeBuildInputs = [ stdenv.cc.bintools ];
    # Copying/stripping must not drag the unstripped outputs into the image closure.
    disallowedReferences = builtins.attrValues examplePackages;
  }
  ''
    mkdir -p "$out/bin"
    ${lib.concatMapStringsSep "\n" (package: ''
      for binary in ${package}/bin/*; do
        name=$(basename "$binary")
        install -m755 "$binary" "$out/bin/$name"
        before=$(stat -c %s "$binary")
        strip --strip-all "$out/bin/$name"
        after=$(stat -c %s "$out/bin/$name")
        printf '%s: %s -> %s bytes\n' "$name" "$before" "$after"
      done
    '') (builtins.attrValues examplePackages)}
    install -Dm644 ${src}/LICENSE "$out/share/licenses/chipmunk/LICENSE"
    install -Dm644 ${src}/NOTICE "$out/share/licenses/chipmunk/NOTICE"
  ''
