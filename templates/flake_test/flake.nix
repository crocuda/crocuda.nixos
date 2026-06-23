{
  description = "A flake that uses crocuda.nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    crocuda.url = "github:pipelight/crocuda.nixos?ref=dev";

    ###################################
    ### crocuda.nixos dependencies
    nixos-tidy = {
      url = "github:pipelight/nixos-tidy?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###################################
    ## Servers
    # Git
    radicle = {
      url = "git+https://seed.radicle.garden/z3gqcJUoA1n9HaHKufZs5FCSGazv5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Dns
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # (optionally)
    };
    dora = {
      url = "github:pipelight/dora";
    };
    # CI/CD
    pipelight = {
      url = "github:pipelight/pipelight?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Virtualization
    # virshle = {
    #   url = "github:pipelight/virshle?ref=dev";
    # };
    # Admin safeguard
    boulette = {
      url = "github:pipelight/boulette?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs;
  in rec {
    nixosConfigurations = {
      # Default module
      default = pkgs.lib.nixosSystem rec {
        specialArgs = {inherit inputs;};

        modules = let
          ### The Nix AND Home module configuration
          # To be inported once as a regular module and once in home-manager.
          crocudaCfg = {...}: {
            crocuda = {
              users = ["anon"];
              shell = {
                fish.enable = true;
                utils.enable = true;
              };
              servers = {
                ssh.enable = true;
              };
            };
          };
        in [
          # Base hardware config for tests
          ../commons/configuration.nix
          ../commons/hardware-configuration.nix

          inputs.crocuda.nixosModules.default
          crocudaCfg

          ###################################
          # You may move this module into its own file.
          ({
            pkgs,
            lib,
            config,
            inputs,
            ...
          }: {
            users.users."root" = {
              initialPassword = "root";
            };
            users.users."anon" = {
              isNormalUser = true;
              initialPassword = "anon";
            };
          })

          ###################################
          # You may move this module into its own file.
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users."anon" = {...}: {
              home.stateVersion = "25.05";
              imports = [
                inputs.crocuda.homeModules.default
                crocudaCfg
              ];
            };
          }
        ];
      };
    };
    packages."${system}" = {
      default = nixosConfigurations.default.config.system.build.toplevel;
    };
  };
}
