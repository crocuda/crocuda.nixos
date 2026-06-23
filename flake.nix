{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  description = "crocuda.nixos - NixOS configuration modules for servers (and paranoids and hypochondriacs)";

  inputs = {
    import-tree.url = "github:denful/import-tree";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    ###################################
    ## NixOs pkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-deprecated.url = "github:nixos/nixpkgs/nixos-25.11";

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
    # inputs.nixos-cli.url = "github:nix-community/nixos-cli";
  };
}
