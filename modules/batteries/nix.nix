{...}: {
  crocuda.batteries.nix = {
    nixos = {pkgs, ...}: {
      ##########################
      ## Lix
      nix.package = pkgs.lixPackageSets.stable.lix;
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
      };
    };
  };
}
