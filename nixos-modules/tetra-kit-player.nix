{ pkgs, config, lib, ... }:
let
  cfg = config.services.tetra-kit-player;
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
        options.port = mkOption {
          type = types.port;
          default = 10000;
          description = ''
            Port of the web server.
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
      "tetra-kit-player-${instanceName}" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        after = [ "setup-tetra-kit-player-${instanceName}.service" ];

        script = ''
          exec ${pkgs.nodejs}/bin/node ${pkgs.tetra-kit-player}/bin/index.js &
        '';

        environment = {
          "TETRA_KIT_RAW_PATH" = instanceConfig.tetraKitRawPath;
          "TETRA_KIT_LOG_PATH" = instanceConfig.tetraKitLogPath;
          "SERVER_PORT" = toString instanceConfig.port;
          "FRONTEND_PATH" = "${pkgs.tetra-kit-player}/frontend";
        };

        serviceConfig = {
          Type = "forking";
          User = cfg.user;
          Restart = "always";
        };
      };
    }) cfg.instances;

    # user accounts for systemd units
    users.users."${cfg.user}" = {
      name = "${cfg.user}";
      description = "This users runs tetra-kit-player";
      isNormalUser = false;
      isSystemUser = true;
      group = cfg.group;
    };
  };
}
