{inputs, ...}: {
  flake = {
    pkgs,
    lib,
    ...
  }: rec {
    crocuda_lib = {
      network = import ../lib/network.nix;
      hugepages = import ../lib/hugepages.nix;
    };
    ## Unit tests
    tests = import ../lib/_test_network.nix {
      inherit crocuda_lib;
      inherit lib;
    };
  };
}
