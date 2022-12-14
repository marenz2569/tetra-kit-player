{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;

    utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachSystem [ utils.lib.system.x86_64-linux ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tetra-kit-player = pkgs.callPackage ./derivation.nix { };
        in
        rec {
          packages = {
            tetra-kit-player = tetra-kit-player;
            default = tetra-kit-player;
          };

          checks = packages // {
            test-tetra-kit-player-packaging = pkgs.callPackage "${nixpkgs}/nixos/tests/make-test-python.nix" {
              name = "test-tetra-kit-player-packaging";
              nodes = {
                server = { lib, config, pkgs, ... }: {
                  imports = [
                    self.nixosModules.tetra-kit-player
                  ];

                  services.tetra-kit-player = {
                    enable = true;
                    instances = {
                      "test" = {
                        tetraKitLogPath = "/tmp";
                        tetraKitRawPath = "/tmp";
                      };
                    };
                  };
                };
              };
              testScript = ''
                import time

                start_all()
                server.wait_for_unit("tetra-kit-player-test.service")
                time.sleep(5)
                server.succeed("${pkgs.wget}/bin/wget http://localhost:10000")
                server.succeed("systemctl restart tetra-kit-player-test.service")
              '';
            } {
              inherit pkgs;
              inherit (pkgs) system;
            };
          };
        }
      ) // {
        # TODO fix this overlay
      overlays.default = final: prev: {
        inherit (self.packages."x86_64-linux")
        tetra-kit-player;
      };

      nixosModules = {
        tetra-kit-player = {
          imports = [
            ./nixos-modules/tetra-kit-player.nix
          ];

          nixpkgs.overlays = [
            self.overlays.default
          ];
        };
        default = self.nixosModules.tetra-kit-player;
      };
    };

}
