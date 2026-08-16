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
{
  self,
  lib,
  ...
}: {
  flake-file.inputs = {
    # Dns
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # (optionally)
    };
  };
  crocuda.batteries.zone = with self.inputs.dns.lib;
  with self.inputs.dns.lib.combinators;
  with self.crocuda_lib.zones; let
    mkDomain = {
      base = {
        domain,
        ipv4,
        ipv6,
      }: {
        useOrigin = true;
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
      };
      mail = {
        domain,
        ipv4,
        ipv6,
      } @ args:
        mkDomain.base args
        // {
          # Reverse dns
          PTR = [
            (mkIPv6ReverseRecord ipv6)
            (mkIPv4ReverseRecord ipv4)
            # (ipv6_to_ptr ipv6)
            # (ipv4_to_ptr ipv4)
          ];
          # autodiscover/autoconfig mailbox
          SRV = [
            {
              service = "autodiscover";
              proto = "tcp";
              port = 443;
              target = "autoconfig";
            }
          ];
          MX = with mx; [
            (mx 10 "mx1")
          ];
          TXT = [
            (txt "v=spf1 mx ~all")
            (txt "v=DMARC1; p=none; adkim=r; aspf=r; fo=0; pct=100; rf=afrf; ri=86400; rua=mailto:admin@${domain}; sp=none;")
          ];
        };
    };
    mkSubdomains = {
      base = {
        domain,
        ipv4,
        ipv6,
      }: {
        ns1 = host ipv4 ipv6;
        ns2 = host ipv4 ipv6;
        "*" = host ipv4 ipv6;
      };
      mail = {
        domain,
        ipv4,
        ipv6,
      }: {
        # Mark domain as MTA-STS compatible (see the next section)
        # and request reports about failures to be sent to postmaster@example.org
        _mta-sts = {
          TXT = [(txt "v=STSv1; id=1")];
        };
        "_smtp._tls" = {
          TXT = [(txt "v=TLSRPTv1;rua=mailto:admin@${domain}")];
        };
        autoconfig = {
          A = [
            (a ipv4)
          ];
          AAAA = [
            (aaaa ipv6)
          ];
        };
        mx1 = {
          A = [
            (a ipv4)
          ];
          AAAA = [
            (aaaa ipv6)
          ];
          TXT = [
            (txt "v=spf1 a ~all")
          ];
        };
      };
    };
    # Create a zone as an attribute set.
    _mkDefaultZone = {
      domain,
      ipv4,
      ipv6,
    } @ args:
      {
        useOrigin = true;
      }
      // mkDomain.base args
      // {subdomains = mkSubdomains.base args;};
    _mkDefaultMailZone = {
      domain,
      ipv4,
      ipv6,
    } @ args:
      {
        useOrigin = true;
      }
      // mkDomain.base args
      // mkDomain.mail args
      // {subdomains = (mkSubdomains.base args) // (mkSubdomains.mail args);};

    mkDefaultZoneConfig = {
      domain,
      ipv4,
      ipv6,
    } @ args: {
      ${domain}.data =
        self.inputs.dns.lib.toString "${domain}" (_mkDefaultZone args);
    };
    mkDefaultMailZoneConfig = {
      domain,
      ipv4,
      ipv6,
    } @ args: {
      ${domain}.data =
        self.inputs.dns.lib.toString "${domain}" (_mkDefaultMailZone args);
    };
  in {
    base = {
      domain,
      ipv4,
      ipv6,
    } @ args: {
      nixos = {...}: {
        services.nsd = {
          zonefilesCheck = true;
          zones = mkDefaultZoneConfig args;
        };
      };
    };
    mail = {
      domain,
      ipv4,
      ipv6,
    } @ args: {
      nixos = {...}: {
        services.nsd = {
          zonefilesCheck = true;
          zones = mkDefaultMailZoneConfig args;
        };
      };
    };
  };
}
