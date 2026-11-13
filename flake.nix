{
  description = "chipmunk: Matter host tools, Linux example apps, and ZAP CLI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      # Newest first: the first version drives both default host tools and the image.
      chipVersions = [
        "1.6.1.0"
        "1.6.0.0"
        "1.5.1.0"
        "1.5.0.1"
      ];
      defaultChipVersion = builtins.head chipVersions;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      ccacheOverlay = final: prev: {
        ccacheWrapper = prev.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_COMPRESS=1
            export CCACHE_SLOPPINESS=random_seed
            export CCACHE_UMASK=007

            if [ -d /nix/var/cache/ccache ] && [ -w /nix/var/cache/ccache ]; then
              export CCACHE_DIR=/nix/var/cache/ccache
            else
              export CCACHE_DIR="''${TMPDIR:-/tmp}/ccache"
              mkdir -p "$CCACHE_DIR"
            fi
          '';
        };
      };

      perSystem = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ ccacheOverlay ];
          };

          zapCliBin = pkgs.callPackage ./packages/zap-cli-bin { };

          sdkByVersion = pkgs.lib.genAttrs chipVersions (
            version: pkgs.callPackage (./packages/chip-sdk/versions + "/${version}.nix") { }
          );
          defaultSdk = sdkByVersion.${defaultChipVersion};

          buildChip = args: pkgs.callPackage ./packages/chip-sdk/build.nix (args // { inherit zapCliBin; });

          hostToolsByVersion = pkgs.lib.genAttrs chipVersions (
            version:
            pkgs.callPackage ./packages/chip-host-tools {
              inherit buildChip;
              sdk = sdkByVersion.${version};
            }
          );
          hostTools = hostToolsByVersion.${defaultChipVersion};
          versionedPackages = pkgs.lib.mapAttrs' (
            version: package:
            pkgs.lib.nameValuePair "chip-host-tools_${builtins.replaceStrings [ "." ] [ "_" ] version}" package
          ) hostToolsByVersion;

          exampleDefinitions = import ./packages/chip-examples/apps.nix;
          examplePackages = pkgs.lib.mapAttrs (
            appName: appPath:
            pkgs.callPackage ./packages/chip-examples {
              inherit buildChip appName appPath;
              sdk = defaultSdk;
            }
          ) exampleDefinitions;

          chipExamples = pkgs.callPackage ./packages/chip-examples/bundle.nix {
            inherit examplePackages;
            inherit (defaultSdk) src version;
          };

          packages =
            versionedPackages
            // {
              zap-cli-bin = zapCliBin;
              chip-host-tools = hostTools;
              default = hostTools;
            }
            // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (
              examplePackages
              // {
                chip-examples = chipExamples;

                docker-image = pkgs.callPackage ./packages/chip-examples/image.nix {
                  inherit chipExamples;
                  chipVersion = defaultChipVersion;
                  chipRevision = defaultSdk.src.rev;
                };
              }
            );
        in
        {
          inherit packages;

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              prek

              actionlint
              crane
              nixfmt
            ];
          };
        }
      );
    in
    {
      lib = {
        inherit chipVersions defaultChipVersion;
      };

      packages = forAllSystems (system: perSystem.${system}.packages);
      devShells = forAllSystems (system: perSystem.${system}.devShells);
    };
}
