{...}: {
  flake-file.inputs = {
    lix-unit = {
      url = "github:adisbladis/lix-unit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake = {
    pkgs,
    lib,
    ...
  }: let
    load = file: import file {inherit lib;};
  in rec {
    lib = crocuda_lib;
    crocuda_lib = builtins.mapAttrs (_: load) {
      network = ../lib/network.nix;
      hugepages = ../lib/hugepages.nix;
    };
    ## Unit tests
    tests = import ../lib/_test_network.nix {
      inherit crocuda_lib;
      inherit lib;
    };
  };
}
