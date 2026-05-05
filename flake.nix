{
  description = "crocuda.nixos - NixOS configuration modules for servers (and paranoids and hypochondriacs)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    ###################################
    # NixOs pkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-deprecated.url = "github:nixos/nixpkgs/nixos-25.05";

    ###################################
    ## Crocuda dependencies
    # Libraries
    nix-std.url = "github:chessai/nix-std";
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # (optionally)
    };
    # NixOs tidy and dependencies
    nixos-tidy = {
      url = "github:pipelight/nixos-tidy?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dora = {
      url = "github:pipelight/dora";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # CI/CD
    # pipelight.url = "github:pipelight/pipelight?ref=dev";
    # SysAdmin
    boulette = {
      url = "github:pipelight/boulette?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # inputs.nixos-cli.url = "github:nix-community/nixos-cli";
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    nixpkgs-deprecated,
    ...
  } @ inputs: let
    lib = crocuda_lib;
    self_lib = crocuda_lib;
    crocuda_lib =
      {}
      // (import ./lib/network {
        inherit (nixpkgs) lib;
      })
      // {
        hugepages = import ./lib/hugepages.nix {
          inherit (nixpkgs) lib;
        };
      }
      // {
        dns = import ./lib/dns-zones.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
      };

    tidy_lib = inputs.nixos-tidy.lib;
    specialArgs = {
      inherit inputs;
      inherit crocuda_lib;
      inherit self_lib;
      pkgs = import nixpkgs;
      pkgs-stable = import nixpkgs-stable;
      pkgs-unstable = import nixpkgs-unstable;
      pkgs-deprecated = import nixpkgs-deprecated;
    };
    umport = {
      paths = [
        ./.
      ];
      exclude = [
        # Testing directory
        ./templates

        # Vm disk images
        ./hardware
        ./rices

        # Flake functions library
        ./lib

        ./flake.nix
        ./default.nix

        # package derivations (imported by other means)
        ./servers/dns/hickory.latest.nix
        ./servers/web/ferron.latest.nix
      ];
    };
  in {
    inherit lib;
    ###################################
    # Nixos modules
    nixosModules = {
      inherit specialArgs;
      default = {...}: {
        imports =
          [
            # Tidy
            inputs.nixos-tidy.nixosModules.allow-unfree
            # SysAdmin
            inputs.boulette.nixosModules.default
            # inputs.nixos-cli.nixosModules.nixos-cli
            # Dhcp: experimental dhcp server.
            inputs.dora.nixosModules.default
          ]
          ++ tidy_lib.getNixModules umport;
      };
    };
    ###################################
    # Home manager modules
    homeModules = {
      inherit specialArgs;
      default = {...}: {
        imports =
          [
            # Boulette
            inputs.boulette.hmModules.default
          ]
          ## Clever hack :)
          # Add same configuration options definition as
          # So user can configure both at one time.
          ++ [./options.nix]
          # Every home.*.nix files
          ++ tidy_lib.getHomeModules umport;
      };
    };
    ## Unit tests
    tests = import ./lib/network/test.nix {
      inherit self_lib;
      inherit (nixpkgs) lib;
    };
  };
}
