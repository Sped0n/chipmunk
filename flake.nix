{
  description = "CHIP host tools and ZAP CLI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
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
    in
    let
      perSystem = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ ccacheOverlay ];
          };
          zapCliBin = pkgs.callPackage ./packages/zap-cli-bin { };
          chipHostTools_1_5_0_1 = pkgs.callPackage ./packages/chip-host-tools/1.5.0.1 {
            inherit zapCliBin;
          };
          chipHostTools_1_5_1_0 = pkgs.callPackage ./packages/chip-host-tools/1.5.1.0 {
            inherit zapCliBin;
          };
          chipHostTools_1_6_0_0 = pkgs.callPackage ./packages/chip-host-tools/1.6.0.0 {
            inherit zapCliBin;
          };
          chipHostTools_1_6_1_0 = pkgs.callPackage ./packages/chip-host-tools/1.6.1.0 {
            inherit zapCliBin;
          };
          packages = {
            zap-cli-bin = zapCliBin;
            chip-host-tools_1_5_0_1 = chipHostTools_1_5_0_1;
            chip-host-tools_1_5_1_0 = chipHostTools_1_5_1_0;
            chip-host-tools_1_6_0_0 = chipHostTools_1_6_0_0;
            chip-host-tools_1_6_1_0 = chipHostTools_1_6_1_0;
            chip-host-tools = chipHostTools_1_6_1_0;
            default = chipHostTools_1_6_1_0;
          };
          mkPackageShell =
            package:
            pkgs.mkShell {
              packages = [ package ];
            };
        in
        {
          inherit packages;
          devShells = {
            zap-cli-bin = mkPackageShell packages.zap-cli-bin;
            chip-host-tools_1_5_0_1 = mkPackageShell packages.chip-host-tools_1_5_0_1;
            chip-host-tools_1_5_1_0 = mkPackageShell packages.chip-host-tools_1_5_1_0;
            chip-host-tools_1_6_0_0 = mkPackageShell packages.chip-host-tools_1_6_0_0;
            chip-host-tools_1_6_1_0 = mkPackageShell packages.chip-host-tools_1_6_1_0;
            chip-host-tools = mkPackageShell packages.chip-host-tools;
            default = mkPackageShell packages.default;
          };
        }
      );
    in
    {
      packages = forAllSystems (system: perSystem.${system}.packages);
      devShells = forAllSystems (system: perSystem.${system}.devShells);
    };
}
