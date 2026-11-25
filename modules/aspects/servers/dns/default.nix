{...}: {
  crocuda.dns = {
    nixos = {
      crocuda_lib,
      config,
      lib,
      pkgs,
      ...
    }: let
      nsdEnabled = config.services.nsd.enable;
      unboundEnabled = config.services.unbound.enable;
      keaDDnsEnabled = config.services.kea.dhcp-ddns.enable;
    in
      with lib; {
        ##########################
        # Set privacy respecting static DNS
        environment.systemPackages = with pkgs; [
          drill
        ];

        networking.resolvconf.enable = false;

        # Force static content inside /etc/resolv.conf
        # to override nixpkgs systemd-resolved configuration.
        environment.etc."resolv.conf.d/resolv.conf.default".text = (
          concatMapStrings
          (x: "nameserver ${x}\n")
          config.networking.nameservers
          + "options edns0 trust-ad"
        );
        systemd.tmpfiles.rules = [
          "L+ /etc/resolv.conf - - - - /etc/resolv.conf.d/resolv.conf.default"
        ];

        networking.dhcpcd.extraConfig = "nohook resolv.conf";
        services.resolved = {
          settings.Resolve = {
            DNS = [
              # adguard
              "2a10:50c0::ad1:ff"
              "2a10:50c0::ad2:ff"

              # quad9
              # "2620:fe::9"
              # "2620:fe::fe"

              # router
              "fe80::1"

              # quad9
              # "9.9.9.9"

              # AdGuard
              "94.140.14.14"
              "94.140.15.15"

              # router
              "192.168.10.1"
            ];
            # DNSSEC = mkDefault true;
            # Domains = mkDefault ["~."];
            # DNSOverTLS = mkDefault true;
            FallbackDNS = config.networking.nameservers;
          };
        };
        # networking.nameservers = lib.mkDefault [
        networking.nameservers = [
          # Ipv6 first
          # Mullvad
          # "2a07:e340::4"
          # Quad9
          # "2620:fe::fe"
          # "2620:fe::9"

          # AdGuard
          "2a10:50c0::ad1:ff"
          "2a10:50c0::ad2:ff"

          # Ipv4 support
          # Mullvad
          # "194.242.2.4"
          # Quad9
          # "9.9.9.9"

          # AdGuard
          "94.140.14.14"
          "94.140.15.15"

          # Local
          "127.0.0.1"
          "::1"
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

          zones = {};
        };

        # Recursive DNS
        services.unbound = {
          settings = {
            server = {
              # tls-service-key = "/etc/pki/tls/certs/ca-bundle.crt";
              # tls-service-pem ="/etc/ssl/certs/"

              unblock-lan-zones = "yes";
              val-permissive-mode = "yes";

              # send minimal amount of information to upstream.
              hide-identity = "yes";
              hide-version = "yes";
              verbosity = 3;

              interface = [
                "::1"
                "127.0.0.1"
                # "::0"
                # "0.0.0.0"
              ];
            };
            # access-control = ["::1 allow"];
            remote-control = {
              control-enable = true;
              control-interface = [
                "::1"
                "127.0.0.1"
              ];
            };
            forward-zone = [
              {
                name = ".";
                # forward-tls-upstream = "yes";
                forward-addr = [
                  (mkIf nsdEnabled "127.0.0.1@53020")
                  (mkIf nsdEnabled "::1@53020")

                  # VM dns
                  # (mkIf keaDDnsEnabled "127.0.0.1@53010")
                  # (mkIf keaDDnsEnabled "::1@53010")

                  #Mullvad
                  # "2a07:e340::4"
                  # "194.242.2.4"

                  #Quad9
                  # "2620:fe::fe"
                  # "9.9.9.9"

                  # AdGuard
                  "2a10:50c0::ad1:ff"
                  "2a10:50c0::ad2:ff"
                  "94.140.14.14"
                  "94.140.15.15"
                ];
              }
            ];
          };
        };
      };
  };
}
