{crocuda, ...}: {
  crocuda.network.tools = {
    ## Add Users to network group.
    policies.to-users = {user, ...}: {
      nixos = {...}: {
        users.groups = {
          networkmanager.members = user;
        };
      };
    };
    includes = [crocuda.network.policies.to-users];

    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      ##########################
      ## Dns
      # Enable dns local caching instead of resolvd.
      # services.unbound.enable = true;

      ##########################
      ## Firewall
      # Replace legacy iptables with nftables
      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        # Network configuration
        nftables
        dhcpcd

        # Trafic inspection
        whois
        # tshark
        iftop
        speedtest-go
        traceroute

        # Host scanning
        dig
        bind

        nmap

        # Query content
        curl
        grpcurl

        # VPN
        # wireguard-tools
        # mullvad-vpn
      ];
    };
  };
  ## Unused -> should deprecated?
  crocuda.network.multicast-forwarding = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      # Compile kernel with multicast forwarding.
      boot.kernelPackages = with pkgs;
        linuxPackagesFor
        (
          pkgs.linux.override {
            structuredExtraConfig = with lib.kernel; {
              MROUTE = yes;
              # Options from: https://github.com/troglobit/smcroute
              IP_MROUTE = yes;
              IP_PIMSM_V1 = yes;
              IP_PIMSM_V2 = yes;
              IP_MROUTE_MULTIPLE_TABLES = yes;
              IPV6_MROUTE_MULTIPLE_TABLES = yes;
            };
            ignoreConfigErrors = true;
          }
        );
      # Add multicast forwarding daemon.
      environment.systemPackages = with pkgs; [
        smcroute
      ];
      # Run the daemon in the background.
      systemd.services.smcroute = {
        enable = true;
        description = "smcroute - static multicast routing for linux.";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = with pkgs; let
          package = smcroute;
        in {
          Type = "oneshot";
          User = "root";
          Group = "users";
          ExecStart = ''
            ${package}/bin/smcrouted -n -s
          '';
          StandardInput = "null";
          StandardOutput = "journal+console";
          StandardError = "journal+console";
        };
      };
    };
  };
}
