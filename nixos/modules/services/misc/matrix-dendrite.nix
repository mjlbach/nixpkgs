{ config, lib, pkgs, ... }:

let
  cfg = config.services.matrix-dendrite;
  settingsFormat = pkgs.formats.yaml {};
  configurationYaml = settingsFormat.generate "dendrite.yaml" cfg.settings;
in
{
  options.services.matrix-dendrite = {
    enable = lib.mkEnableOption "matrix.org dendrite";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/matrix-dendrite";
      description = ''
        The directory where matrix-dendrite stores its stateful data such as
        certificates, media and uploads.
      '';
    };
    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 8008;
      description = ''
        The directory where matrix-dendrite stores its stateful data such as
        certificates, media and uploads.
      '';
    };
    httpsPort = lib.mkOption {
      type = lib.types.int;
      default = 8448;
      description = ''
        The directory where matrix-dendrite stores its stateful data such as
        certificates, media and uploads.
      '';
    };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options.global = {
          server_name = lib.mkOption {
            type = lib.types.str;
            example = "example.com";
            default = config.networking.hostName;
            description = ''
              The domain name of the server, with optional explicit port.
              This is used by remote servers to connect to this server,
              e.g. matrix.org, localhost:8080, etc.
              This is also the last part of your UserID.
            '';
          };
          private_key = lib.mkOption {
            type = lib.types.str;
            example = "/path/to/matrix_key.pem";
            default = "matrix_key.pem";
            description = ''
              The servers 
            '';
          };
          trusted_third_party_id_servers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            example = [ "matrix.org" ];
            default = [ "matrix.org" "vector.im" ];
            description = ''
              The servers 
            '';
          };
        };
      };
      default = {};
      description = ''
        Configuration for dendrite, see:
        <link xlink:href="https://github.com/matrix-org/dendrite"/>
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.matrix-dendrite = {
      group = "matrix-dendrite";
      home = cfg.dataDir;
      createHome = true;
      shell = "${pkgs.bash}/bin/bash";
      isSystemUser = true;
    };

    users.groups.matrix-dendrite = {};

    systemd.services.matrix-dendriter-key-generator = {
      description = "Dendrite Matrix homeserver - Key Generator";
      wantedBy = [ "matrix-dendrite.service" ];
      requiredBy = [ "matrix-dendrite.service" ];
      before = [ "matrix-dendrite.service" ];
      path = with pkgs; [ matrix-dendrite ];
      serviceConfig = {
        Type = "oneshot";
        User = "matrix-dendrite";
        Group = "matrix-dendrite";
        RemainAfterExit = true;
        WorkingDirectory = cfg.dataDir;
      };
      script = ''
        generate-keys --tls-cert server.crt --tls-key server.key --private-key matrix_key.pem
      '';
    };

    systemd.services.matrix-dendrite = {
      description = "Dendrite Matrix homeserver";
      after = [
        "network.target"
        "matrix-dendriter-key-generator.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        User = "matrix-dendrite";
        Group = "matrix-dendrite";
        WorkingDirectory = cfg.dataDir;
        ExecStart = lib.strings.concatStringsSep " " [
          "${pkgs.matrix-dendrite}/bin/dendrite-monolith-server"
          "--config ${configurationYaml}"
          "--http-bind-address :${builtins.toString cfg.httpPort}"
          "--https-bind-address :${builtins.toString cfg.httpsPort}"
          "--tls-cert server.crt"
          "--tls-key server.key"
        ];
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };
  };
  meta.maintainers = lib.teams.matrix.members;
}
