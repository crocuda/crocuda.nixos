{inputs, ...}: {
  flake = {
    pkgs,
    lib,
    ...
  }: rec {
    crocuda_lib = {
      network = import ./_lib/network {
        inherit lib;
      };
      hugepages = import ./_lib/hugepages.nix {
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
