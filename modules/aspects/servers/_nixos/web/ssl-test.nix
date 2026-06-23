{
  config,
  pkgs,
  lib,
  inputs,
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
    }
