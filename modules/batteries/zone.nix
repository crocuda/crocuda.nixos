## Decription:
#
# Creates a dns zone file.
#
## Usage:
#
#```nix
# includes = [
#   (crocuda.batteries.zone
#     {
#       domain = "test.com";
#       ipv4 = "127.0.0.1";
#       ipv6 = "2002:7f00:1::";
#     })
# ];
#```
{self, ...}: {
  flake-file.inputs = {
    # Dns
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # (optionally)
    };
  };
  crocuda.batteries.zone = {
    domain,
    ipv4,
    ipv6,
  }: let
    # Create a zone as an attribute set.
    _mkDefaultZone = {
      domain,
      ipv4,
      ipv6,
    }:
      with self.inputs.dns.lib.combinators;
      with self.crocuda_lib.zones; {
        SOA = {
          nameServer = "ns1.${domain}.";
          adminEmail = "admin@${domain}";
          serial = 2019030800;
        };
        NS = [
          "ns1.${domain}"
          "ns2.${domain}"
        ];
        A = [
          (a ipv4)
        ];
        AAAA = [
          (aaaa ipv6)
        ];
        subdomains = rec {
          ns1 = host ipv4 ipv6;
          ns2 = ns1;
          api = host ipv4 ipv6;
          "analytics" = host ipv4 ipv6;
          "*" = host ipv4 ipv6;
        };
        PTR = [
          (ipv6_to_ptr ipv6)
          (ipv4_to_ptr ipv4)
        ];
      };

    # Create a zone as a string.
    mkDefaultZoneString = {
      domain,
      ipv4,
      ipv6,
    }:
      self.inputs.dns.lib.toString "${domain}" (_mkDefaultZone {
        inherit domain;
        inherit ipv4;
        inherit ipv6;
      });

    mkDefaultZoneConfig = {
      domain,
      ipv4,
      ipv6,
    }: {
      ${domain}.data = self.inputs.dns.lib.toString "${domain}" (_mkDefaultZone {
        inherit domain;
        inherit ipv4;
        inherit ipv6;
      });
    };
  in {
    nixos = {...}: {
      services.nsd = {
        zonefilesCheck = true;
        zones = mkDefaultZoneConfig {
          inherit domain;
          inherit ipv4;
          inherit ipv6;
        };
      };
    };
  };
}
