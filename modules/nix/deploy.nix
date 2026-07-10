{inputs, ...}: {
  flake-file.inputs = {
    # Infra
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  perSystem = {
    pkgs,
    self,
    lib,
    ...
  }: {
    # devShells.default = lib.mkDefault (pkgs.mkShell {
    #   packages = with pkgs; [
    #       deploy-rs
    #     ];
    # });
  };

  flake = {
    lib,
    config,
    ...
  }: let
    mkNodes = lib.mapAttrs' (
      nixosConfigurationName: nixosConfiguration: let
        inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
      in {
        name = nixosConfigurationName;
        value = {
          hostname = nixosConfiguration.config.networking.hostName;
          profiles.system = {
            user = "root";
            path =
              inputs.deploy-rs.lib.${system}.activate.nixos
              nixosConfiguration;
          };
        };
      }
    );
  in {
    deploy.nodes =
      mkNodes config.nixosConfigurations;
  };
}
