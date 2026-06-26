{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  crocuda.batteries.lix-and-flakes = {
    nixos = {pkgs, ...}: {
      ##########################
      ## Lix
      nix.package = let
        system = pkgs.stdenv.hostPlatform.system;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
        };
      in
        pkgs-unstable.lixPackageSets.latest.lix;
      # nix.package = pkgs.lixPackageSets.git.lix;
      ## Nix
      # Enable Flakes
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;

        sandbox = "relaxed";
        # sandbox = true;
        # sandbox = false;

        # max-jobs = 3;
        # cores = 4;

        # cores = 12;

        # Nix substituters and Binary caches
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
