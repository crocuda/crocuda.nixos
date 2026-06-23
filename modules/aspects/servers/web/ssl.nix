{...}: {
  crocuda.ssl = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: let
      certbot_clean_certs =
        pkgs.writeShellScriptBin "certbot_clean_certs"
        (builtins.readFile
          ./dotfiles/letsencrypt-utils/clean_certs.sh);
    in {
      environment.systemPackages = [
        pkgs.certbot
        certbot_clean_certs
      ];

      systemd.services = with lib; let
        email = config.crocuda.web.letsencrypt.credentials.email;
        units =
          concatMapAttrs
          (
            name: domains: {
              "certbot_${name}_" = {
                description = "Certbot update ssl certificates for ${name}";
                wantedBy = ["certbot.target"];
                serviceConfig = {
                  Type = "oneshot";
                  User = "root";
                  Group = "users";
                  ExecStartPre = ''
                    -${certbot_clean_certs}/bin/certbot_clean_certs clean ${name}
                  '';
                  ExecStart =
                    ''
                      ${pkgs.certbot}/bin/certbot certonly \
                      --cert-name ${name} \
                    ''
                    + concatMapStrings (domain: "-d ${domain} ") domains
                    + ''
                      --standalone \
                      -n \
                    ''
                    + ''
                      --agree-tos \
                      --email ${email}
                    '';
                  StandardInput = "null";
                  StandardOutput = "journal+console";
                  StandardError = "journal";
                };
              };
            }
          )
          config.crocuda.web.letsencrypt.domains;
      in
        units;

      systemd.timers."certbot" = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "5m";
          OnUnitActiveSec = "5m";
          OnCalendar = "weekly";
        };
      };
    };
  };
  crocuda.ssl.test = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: let
      cfg = config.crocuda;
      pebbleConfig = pkgs.writeText "pebble.json" (builtins.toJSON {
        pebble = {
          listenAddress = "127.0.0.1:14000";
          managementListenAddress = "127.0.0.1:15000";
          certificate = "${pkgs.pebble.src}/test/certs/localhost/cert.pem";
          privateKey = "${pkgs.pebble.src}/test/certs/localhost/key.pem";

          # Defaults
          # httpPort = 5002;
          # tlsPort = 5001;

          # Production
          httpPort = 80;
          tlsPort = 442;

          ocspResponderURL = "";
          externalAccountBindingRequired = false;
        };
      });
    in
      with lib;
        mkIf cfg.servers.web.pebble.enable {
          environment.defaultPackages = with pkgs; [
            # https://github.com/letsencrypt/pebble
            pebble
            minica
          ];
          environment.etc = {
            "pebble/test".source = "${pkgs.pebble.src}/test";
          };
          # SSL suport
          # security.acme = {
          #   acceptTerms = true;
          #   defaults.email = "admin+acme@example.org";
          # };

          # Open ports in the firewall.
          # networking.firewall.allowedTCPPorts = [ ... ];

          systemd.services.pebble-challtestsrv = {
            enable = false;
            description = "Pebble ACME Challenge Test Server";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              # Environment = ["PEBBLE_VA_NOSLEEP=1" "PEBBLE_VA_ALWAYS_VALID=1"];
              # Environment = ["PEBBLE_VA_NOSLEEP=1"];
              ExecStart = "${pkgs.pebble}/bin/pebble-challtestsrv";
              DynamicUser = true;
            };
          };
          systemd.services.pebble = {
            description = "Pebble ACME Test Server";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              # Environment = ["PEBBLE_VA_NOSLEEP=1" "PEBBLE_VA_ALWAYS_VALID=1"];
              # Environment = ["PEBBLE_VA_NOSLEEP=1"];
              ExecStart = "${pkgs.pebble}/bin/pebble -config ${pebbleConfig}";
              DynamicUser = true;
            };
          };
        };
  };
}
