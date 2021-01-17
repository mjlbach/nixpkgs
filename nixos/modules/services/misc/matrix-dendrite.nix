{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.matrix-dendrite;
  # pg = config.services.postgresql;
  settingsFormat = pkgs.formats.yaml {};
  configurationYaml = settingsFormat.generate "dendrite.yaml" cfg.settings;
  # hasLocalPostgresDB = let args = cfg.database_args; in
  #   usePostgresql && (!(args ? host) || (elem args.host [ "localhost" "127.0.0.1" "::1" ]));
in {
  options.services.matrix-dendrite = {
      enable = mkEnableOption "matrix.org dendrite";
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/matrix-dendrite";
        description = ''
          The directory where matrix-synapse stores its stateful data such as
          certificates, media and uploads.
        '';
      };
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
      default = {};
      description = ''
        Configuration for dendrite, see:
        <link xlink:href="https://github.com/matrix-org/dendrite"/>
      '';
    };
  };

  config = mkIf cfg.enable {
    services.matrix-dendrite.settings = {
      user = "matrix-dendrite";
      app_service_api = {
        config_files = [ ];
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:appservice.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        internal_api = {
          connect = "http://localhost:7777";
          listen = "http://localhost:7777";
        };
      };
      client_api = {
        enable_registration_captcha = false;
        external_api = {
          listen = "http://[::]:8071";
        };
        internal_api = {
          connect = "http://localhost:7771";
          listen = "http://localhost:7771";
        };
        rate_limiting = {
          cooloff_ms = 500;
          enabled = true;
          threshold = 5;
        };
        recaptcha_bypass_secret = "";
        recaptcha_private_key = "";
        recaptcha_public_key = "";
        recaptcha_siteverify_api = "";
        registration_disabled = false;
        registration_shared_secret = "";
        turn = {
          turn_password = "";
          turn_shared_secret = "";
          turn_uris = [ ];
          turn_user_lifetime = "";
          turn_username = "";
        };
      };
      edu_server = {
        internal_api = {
          connect = "http://localhost:7778";
          listen = "http://localhost:7778";
        };
      };
      federation_api = {
        external_api = {
          listen = "http://[::]:8072";
        };
        federation_certificates = [ ];
        internal_api = {
          connect = "http://localhost:7772";
          listen = "http://localhost:7772";
        };
      };
      federation_sender = {
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:federationsender.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        disable_tls_validation = false;
        internal_api = {
          connect = "http://localhost:7775";
          listen = "http://localhost:7775";
        };
        proxy_outbound = {
          enabled = false;
          host = "localhost";
          port = 8080;
          protocol = "http";
        };
        send_max_retries = 16;
      };

      global = {
        disable_federation = false;
        kafka = {
          addresses = [
            "localhost:2181"
          ];
          naffka_database = {
            conn_max_lifetime = -1;
            connection_string = "file:naffka.db";
            max_idle_conns = 2;
            max_open_conns = 10;
          };
          topic_prefix = "Dendrite";
          use_naffka = true;
        };
        key_validity_period = "168h0m0s";
        metrics = {
          basic_auth = {
            password = "metrics";
            username = "metrics";
          };
          enabled = false;
        };
        private_key = "matrix_key.pem";
        server_name = "localhost";
        trusted_third_party_id_servers = [
          "matrix.org"
          "vector.im"
        ];
      };
      key_server =
        {
          database = {
            conn_max_lifetime = -1;
            connection_string = "file:keyserver.db";
            max_idle_conns = 2;
            max_open_conns = 10;
          };
          internal_api = {
            connect = "http://localhost:7779";
            listen = "http://localhost:7779";
          };
        };

      logging = [{
        level = "info";
        params = {
          path = "${cfg.dataDir}/log";
        };
        type = "file";
      }];
      media_api = {
        base_path = "./media_store";
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:mediaapi.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        dynamic_thumbnails = false;
        external_api = {
          listen = "http://[::]:8074";
        };
        internal_api = {
          connect = "http://localhost:7774";
          listen = "http://localhost:7774";
        };
        max_file_size_bytes =
          10485760;
        max_thumbnail_generators = 10;
        thumbnail_sizes = [
          {
            height = 32;
            method = "crop";
            width = 32;
          }
          {
            height = 96;
            method = "crop";
            width = 96;
          }
          {
            height = 480;
            method = "scale";
            width = 640;
          }
        ];
      };
      mscs = {
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:mscs.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        mscs = [ ];
      };
      room_server = {
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:roomserver.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        internal_api = {
          connect = "http://localhost:7770";
          listen = "http://localhost:7770";
        };
      };
      signing_key_server = {
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:signingkeyserver.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        internal_api =
          {
            connect = "http://localhost:7780";
            listen = "http://localhost:7780";
          };
        key_perspectives = [
          {
            keys = [
              {
                key_id = "ed25519:auto";
                public_key = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
              }
              {
                key_id = "ed25519:a_RXGa";
                public_key = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
              }
            ];
            server_name = "matrix.org";
          }
        ];
        prefer_direct_fetch = false;
      };
      sync_api = {
        database = {
          conn_max_lifetime = -1;
          connection_string = "file:syncapi.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        external_api = {
          listen = "http://[::]:8073";
        };
        internal_api = {
          connect = "http://localhost:7773";
          listen = "http://localhost:7773";
        };
      };
      tracing = {
          enabled = false;
          jaeger = {
            disabled = false;
            rpc_metrics = false;
            serviceName = "";
            tags = [ ];
          };
        };
      user_api = {
        account_database = {
          conn_max_lifetime = -1;
          connection_string = "file:userapi_accounts.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        device_database = {
          conn_max_lifetime = -1;
          connection_string = "file:userapi_devices.db";
          max_idle_conns = 2;
          max_open_conns = 10;
        };
        internal_api = {
          connect = "http://localhost:7781";
          listen = "http://localhost:7781";
        };
      };
    };

    users.users.${cfg.settings.user} = {
      group = "matrix-dendrite";
      home = cfg.dataDir;
      createHome = true;
      shell = "${pkgs.bash}/bin/bash";
      isSystemUser = true;
    };

    users.groups.matrix-dendrite = {};

    systemd.services.matrix-dendriter-key-generator= {
      description = "Dendrite Matrix homeserver - Key Generator";
      wantedBy = [ "matrix-dendrite.service" ];
      requiredBy = [ "matrix-dendrite.service" ];
      before = [ "matrix-dendrite.service" ];
      path = with pkgs; [ matrix-dendrite ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = cfg.dataDir;
      };
      script = ''
        generate-keys --tls-cert server.crt --tls-key server.key
      '';
    };

    systemd.services.matrix-dendrite = {
      description = "Dendrite Matrix homeserver";
      after = [ 
        "network.target" 
        "matrix-dendriter-key-generator.service"
      ]; #++ optional hasLocalPostgresDB "postgresql.service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        User = "matrix-dendrite";
        Group = "matrix-dendrite";
        WorkingDirectory = cfg.dataDir;
        ExecStart = ''
          ${pkgs.matrix-dendrite}/bin/dendrite-monolith-server \
          --tls-cert server.crt \
          --tls-key server.key \
          --config ${configurationYaml}
        '';
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };
  };
  meta.maintainers = teams.matrix.members;
}
