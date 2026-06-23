{
  crocuda_lib,
  config,
  lib,
  ...
}: let
  nsdEnabled = config.services.nsd.enable;
  unboundEnabled = config.services.unbound.enable;
  keaDDnsEnabled = config.services.kea.dhcp-ddns.enable;
in
  with lib;
  # enabled on privacy feature only
    mkIf config.crocuda.servers.dns.defaultConfig {
      ##########################
      # Set privacy respecting static DNS
      networking.nameservers = lib.mkDefault [
        # Ipv6 first
        # Mullvad
        "2a07:e340::4"
        # Quad9
        "2620:fe::fe"
        "2620:fe::9"

        # Ipv4 support
        # Mullvad
        "194.242.2.4"
        # Quad9
        "9.9.9.9"
      ];

      ##########################
      # Enable a recursive DNS(unbound) and a authoritative DNS(nsd),
      # on the same server.
      # Public recursive DNS(::0:53) <-can communicate with-> Private authoritative DNS(::1:53020).
      # or
      # Public authoritative DNS(::0:53).

      # Authoritative DNS
      services.nsd = {
        # zonefilesCheck = false;
        verbosity = 4;
        extraConfig = ''
          server:
            hide-identity: yes
            hide-version: yes
        '';
        port =
          if unboundEnabled
          # Run on non default port if unbound is already running
          then 53020
          # Listen on default port
          else 53;

        interfaces =
          if unboundEnabled
          # Listen on localhost only if unbound is already running.
          then ["127.0.0.1" "::1"]
          # Listen on public
          else ["0.0.0.0" "::0"];

        zones = with crocuda_lib.dns;
          {}
          // mkDefaultZone {
            domain = "vm";
            ipv4 = null;
            ipv6 = null;
          };
      };

      # Recursive DNS
      services.unbound = {
        settings = {
          server = {
            unblock-lan-zones = "yes";
            val-permissive-mode = "yes";

            # send minimal amount of information to upstream.
            hide-identity = "yes";
            hide-version = "yes";
            verbosity = 3;

            interface = [
              "0.0.0.0"
              "::0"
            ];
          };
          # access-control = ["::1 allow"];
          remote-control = {
            control-enable = true;
            control-interface = [
              "127.0.0.1"
              "::1"
            ];
          };
          forward-zone = [
            {
              name = ".";
              forward-addr = [
                (mkIf nsdEnabled "127.0.0.1@53020")
                (mkIf nsdEnabled "::1@53020")

                # VM dns
                # (mkIf keaDDnsEnabled "127.0.0.1@53010")
                # (mkIf keaDDnsEnabled "::1@53010")

                #Mullvad
                "2a07:e340::4"
                "194.242.2.4"
                #Quad9
                "2620:fe::fe"
                "9.9.9.9"
              ];
            }
          ];
        };
      };
    }
