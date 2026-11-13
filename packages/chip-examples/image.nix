{
  dockerTools,
  chipExamples,
  chipVersion,
  chipRevision,
}:
dockerTools.buildLayeredImage {
  name = "ghcr.io/sped0n/chipmunk";
  tag = chipVersion;
  contents = [
    chipExamples
    dockerTools.fakeNss
  ];
  extraCommands = ''
    mkdir -p tmp
    chmod 1777 tmp
  '';
  config = {
    Cmd = [ "all-devices-app" ];
    Env = [
      "PATH=/bin"
      "HOME=/tmp"
    ];
    WorkingDir = "/tmp";
    User = "65534:65534";
    # Upstream uses /tmp for both the KVS and platform configuration/counters.
    Volumes."/tmp" = { };
    Labels = {
      "org.opencontainers.image.title" = "chipmunk";
      "org.opencontainers.image.description" = "Upstream Matter Linux example apps";
      "org.opencontainers.image.source" = "https://github.com/Sped0n/chipmunk";
      "org.opencontainers.image.version" = chipVersion;
      "org.opencontainers.image.licenses" = "Apache-2.0";
      "io.chipmunk.chip.version" = chipVersion;
      "io.chipmunk.chip.revision" = chipRevision;
    };
  };
}
