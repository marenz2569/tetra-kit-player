{ pkgs, config, lib, ... }:
let
  cfg = config.services.tetra-kit-player;
in
{
  options.services.tetra-kit-player = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable tetra-kit-player service
      '';
    };
    hosts = mkOption {
      type = types.listOf
        (types.submodule {
          options.name = mkOption {
            type = types.str;
            default = "";
            description = ''
              name of this hosts
            '';
          };
          # options.host = mkOption {
          #   type = types.str;
          #   default = "127.0.0.1";
          #   description = ''
          #     To which IP data-accumulator should bind.
          #   '';
          # };
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
    systemd = {
      services = builtins.listToAttrs (builtins.map (host: {
        name = "tetra-kit-player-${host.name}";
        value = {
          enable = true;
          wantedBy = [ "multi-user.target" ];

          script = ''
            rm -rf * || true

            ln -s ${pkgs.tetra-kit-player}/bin bin
            ln -s ${pkgs.tetra-kit-player}/node_modules node_modules
            ln -s ${pkgs.tetra-kit-player}/client client
            ln -s ${pkgs.tetra-kit-player}/.parcelrc .parcelrc
            exec ${pkgs.nodejs}/bin/node --experimental-wasi-unstable-preview1 ./bin/index.js &
          '';

          environment = {
            "TETRA_KIT_RAW_PATH" = "${host.tetraKitRawPath}";
            "TETRA_KIT_LOG_PATH" = "${host.tetraKitLogPath}";
            "SERVER_PORT" = toString host.serverPort;
            "PARCEL_PORT" = toString host.parcelPort;
          };

          serviceConfig = {
            Type = "forking";
            User = cfg.user;
            WorkingDirectory = "/tmp";
            Restart = "always";
          };
        };
      }) cfg.hosts);
    };

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
