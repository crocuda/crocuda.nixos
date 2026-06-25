# Add a wheel group and to trusted-users.
#
# Usage:
#
#```nix
# den.aspects.anon.includes = [
#    crocuda.batteries.trusted-users
# ];
#```
{...}: {
  crocuda.batteries.trusted-users = {
    ##########################
    # Nix substituters
    # and Binary caches
    nix.settings = {
      trusted-users = ["@wheel"];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
