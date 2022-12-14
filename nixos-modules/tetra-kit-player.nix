{ pkgs, config, lib, ... }:
let
  cfg = config.services.tetra-kit-player;
  home = "/var/lib/tetra-kit-player";
in {
  options.services.tetra-kit-player = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable tetra-kit-player service
      '';
    };
    instances = mkOption {
      type = types.attrsOf (types.submodule {
        options.serverPort = mkOption {
          type = types.port;
          default = 10000;
          description = ''
            Port which is user facing.
          '';
        };
        options.parcelPort = mkOption {
          type = types.port;
          default = 10001;
          description = ''
            Port where only the website is hosted.
            Proxying is already done in tetra-kit-player.
          '';
        };
        options.tetraKitRawPath = mkOption {
          type = types.either types.path types.str;
          default = "";
          description = ''
            Path to the directory where data can be saved for the service.
          '';
        };
        options.tetraKitLogPath = mkOption {
          type = types.either types.path types.str;
          default = "";
          description = ''
            Path to the tetra-kit log file for parsing.
          '';
        };
      });
      default = [ ];
      description = ''
        List of hosts for the service
      '';
    };
    user = mkOption {
      type = types.str;
      default = "tetra-kit-player";
      description = ''
        systemd user
      '';
    };
    group = mkOption {
      type = types.str;
      default = "tetra-kit-player";
      description = ''
        group of systemd user
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.concatMapAttrs (instanceName: instanceConfig: {
      "setup-tetra-kit-player-${instanceName}" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          mkdir -p ${home}/${instanceName}
        '';

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
        };
      };

      "tetra-kit-player-${instanceName}" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        after = [ "setup-tetra-kit-player-${instanceName}.service" ];

        script = ''
          rm -rf * || true
          rm -rf .parcelrc || true

          ln -s ${pkgs.tetra-kit-player}/bin bin
          ln -s ${pkgs.tetra-kit-player}/node_modules node_modules
          ln -s ${pkgs.tetra-kit-player}/client client
          ln -s ${pkgs.tetra-kit-player}/.parcelrc .parcelrc
          exec ${pkgs.nodejs}/bin/node --experimental-wasi-unstable-preview1 ./bin/index.js &
        '';

        environment = {
          "TETRA_KIT_RAW_PATH" = "${instanceConfig.tetraKitRawPath}";
          "TETRA_KIT_LOG_PATH" = "${instanceConfig.tetraKitLogPath}";
          "SERVER_PORT" = toString instanceConfig.serverPort;
          "PARCEL_PORT" = toString instanceConfig.parcelPort;
        };

        serviceConfig = {
          Type = "forking";
          User = cfg.user;
          WorkingDirectory = "${home}/${instanceName}";
          Restart = "always";
        };
      };
    }) cfg.instances;

    # user accounts for systemd units
    users.users."${cfg.user}" = {
      inherit home;
      name = "${cfg.user}";
      description = "This users runs tetra-kit-player";
      isNormalUser = false;
      isSystemUser = true;
      createHome = true;
      group = cfg.group;
    };
  };
}
