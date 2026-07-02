## Decription:
#
# Enables `nix run .#vm-<configuration_name>`.
# For each of your nixosConfigurations.
#
# This automatically spawns a new vm to test your
# configuration.
#
{
  inputs,
  self,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: let
    ## Create a small script that spawns a virtual machine
    ## with the host configuration.
    mkShellApp = host:
      pkgs.writeShellApplication {
        name = "vm-${host.networking.hostName}";
        text = ''
          ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
        '';
      };
    ## Create a package entry for each nixosConfiguration.
    ## You can run a vm with: `nix run .#vm-<configuration_name>`.
    mkVms = lib.mapAttrs' (nixosConfigurationName: nixosConfiguration: let
      hostConfig = nixosConfiguration.config;
    in {
      name = "vm-${nixosConfigurationName}";
      value = pkgs.writeShellApplication {
        name = "vm-${nixosConfigurationName}";
        text = ''
          rm -f ./${hostConfig.networking.hostName}.qcow2
          ${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild build-vm \
            --flake ".#${nixosConfigurationName}" "$@"
          ${hostConfig.system.build.vm}/bin/run-${hostConfig.networking.hostName}-vm "$@"
        '';
      };
    });
  in {
    packages = mkVms self.nixosConfigurations;
  };
}
