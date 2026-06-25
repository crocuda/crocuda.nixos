# Add a wheel group and some users to trusted-users.
#
# Usage:
#
#```nix
# den.aspects.anon.includes = [
#    (crocuda.batteries.trusted-users ["anon"])
#    # OR
#    (crocuda.batteries.trusted-users)
# ];
#```
{...}: {
  den.batteries.trusted-users = {users ? []}: {
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
