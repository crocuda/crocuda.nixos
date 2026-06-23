{inputs, ...}: {
  flake = {
    lib,
    pkgs,
    ...
  }: {
    crocuda_lib =
      {}
      // (import ./lib/network {
        inherit (pkgs) lib;
      })
      // {
        hugepages = import ./lib/hugepages.nix {
          inherit (pkgs) lib;
        };
      }
      // {
        dns = import ./lib/dns-zones.nix {
          inherit inputs;
          inherit (pkgs) lib;
        };
      };
    # lib = {...}: {
    #   imports = builtins.filter (p: lib.hasSuffix ".nix" p && !lib.hasInfix "/_" p) (
    #     lib.filesystem.listFilesRecursive ./_lib
    #   );
    # };
  };
}
