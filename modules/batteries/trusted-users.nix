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
    nixos = {...}: {
      ##########################
      # Nix substituters
      # and Binary caches
      nix.settings = {
        trusted-users = ["@wheel"];
      };
    };
  };
}
