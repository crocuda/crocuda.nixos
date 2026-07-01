## Decription:
#
# Enables `nix run .#vm-<configuration_name>`.
# For each of your nixosConfigurations.
#
# This automatically spawns a new vm to test your
# configuration.
#
## Usage:
# ```nix`
# includes = [ crocuda.batteries.vm ];
# ```
{
  inputs,
  den,
  crocuda,
  ...
}: {
  crocuda.batteries.vm.larger = {
    nixos = {...}: {
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 4;
        };
      };
    };
  };

  crocuda.batteries.vm = {
    includes = [
      crocuda.batteries.vm.larger
      (den.batteries.vm-autologin "anon")
      # DANGER: do not use tty autologin in production.
      (den.batteries.tty-autologin "anon")
    ];
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
        inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
        hostConfig = nixosConfiguration.config;
      in {
        name = "vm-${nixosConfigurationName}";
        value = pkgs.writeShellApplication {
          name = "vm-${nixosConfigurationName}";
          text = ''
            ${hostConfig.system.build.vm}/bin/run-${hostConfig.networking.hostName}-vm "$@"
          '';
        };
      });
    in {
      packages = mkVms inputs.self.nixosConfigurations;
    };
  };
}
