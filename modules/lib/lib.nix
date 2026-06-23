{inputs, ...}: {
  flake = {
    pkgs,
    lib,
    ...
  }: rec {
    crocuda_lib =
      {}
      // (import ./_lib/network {
        inherit lib;
      })
      // {
        hugepages = import ./_lib/hugepages.nix {
          inherit lib;
        };
      }
      // {
        dns = import ./_lib/dns-zones.nix {
          inherit inputs;
          inherit lib;
        };
      };
    ## Unit tests
    tests = import ./_lib_tests/network.nix {
      inherit crocuda_lib;
      inherit lib;
    };
  };
}
