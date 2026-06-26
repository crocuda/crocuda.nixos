# Crocuda shell
{lib, ...}: {
  systems = lib.mkDefault lib.systems.flakeExposed;
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.default = with lib;
      mkOverride 2000 (pkgs.mkShell {
        packages = with pkgs; [
          sops
          age
          ssh-to-age # ed25519 to age
        ];
        shellHook = ''
          git fetch
          export SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/me);
        '';
      });
  };
}
