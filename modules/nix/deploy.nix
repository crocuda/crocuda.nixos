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
      hostname: nixosConfiguration: let
        inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
      in {
        name = hostname;
        value = {
          inherit hostname;
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
