{inputs, ...}: {
  flake-file.inputs = {
    # Dns
    dns = {
      url = "github:kirelagin/dns.nix";
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
      with inputs.dns.lib.combinators;
      with inputs.crocuda.lib.zones; {
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
      inputs.dns.lib.toString "${domain}" (_mkDefaultZone {
        inherit domain;
        inherit ipv4;
        inherit ipv6;
      });

    mkDefaultZoneConfig = {
      domain,
      ipv4,
      ipv6,
    }: {
      ${domain} = inputs.dns.lib.toString "${domain}" (_mkDefaultZone {
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
