{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  cfg = config.crocuda;
  keaDDnsEnabled = config.services.kea.dhcp-ddns.enable;
  # hickory-dns-latest = pkgs.callPackage ./hickory.latest.nix {};

  base = pkgs.writeText "/var/lib/hickory-dns/vm.zone" ''
    ; SOA record
    @ IN SOA a.ns admin (
      1999010100 ; serial
      10800 ; refresh (3 hours)
      900 ; retry (15 minutes)
      604800 ; expire (1 week)
      86400 ; minimum (1 day)
    )
  '';
in
  with lib;
    mkIf config.crocuda.servers.dns.defaultConfig {
      users.users.hickory = {
        group = "users";
        isSystemUser = true;
      };

      systemd.services.hickory-dns = with lib; {
        serviceConfig = {
          User = "hickory";
          Group = "users";
          UMask = mkForce "0007";
          DynamicUser = mkForce false;
          StateDirectory = mkForce "/var/lib/hickory-dns";
        };
      };

      ## dns resolver/caching
      systemd.tmpfiles.rules = [
        "Z '/var/lib/hickory-dns' 764 hickory users - -"
        "Z '/run/hickory-dns' 764 hickory users - -"
        "f '/var/lib/hickory-dns/vm.zone' 764 hickory users - -"
      ];
      environment.systemPackages = [
        # pkgs-unstable.hickory-dns
        # hickory-dns-latest
      ];

      services.hickory-dns = {
        debug = true;
        package = pkgs.hickory-dns;
        # package = pkgs-unstable.hickory-dns;
        # package = hickory-dns-latest;
        settings = {
          user = "hickory";
          group = "users";
          listen_addrs_ipv4 = ["127.0.0.1"];
          listen_addrs_ipv6 = ["::1"];
          listen_port = 53;
          zones = let
            baseConfig = {
              trust_negative_responses = false;
              connections = [
                {protocol = {type = "udp";};}
                {protocol = {type = "tcp";};}
              ];
            };
          in [
            {
              zone = "vm";
              zone_type = "Primary";
              # stores = {type = "sqlite";};
            }
            {
              zone = "lan";
              zone_type = "External";
              stores = [
                {
                  type = "forward";
                  name_servers = [
                    {
                      ip = "192.168.1.1";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                    {
                      ip = "fe80::e0b0:beff:feb0:beb0";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                  ];
                }
              ];
            }
            {
              zone = ".";
              zone_type = "External";
              stores = [
                {
                  type = "forward";
                  name_servers = [
                    #Mullvad
                    {
                      ip = "194.242.2.4";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                    {
                      ip = "2a07:e340::4";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                    #Quad9
                    {
                      ip = "9.9.9.9";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                    {
                      ip = "2620:fe::fe";
                      inherit (baseConfig) trust_negative_responses connections;
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    }
