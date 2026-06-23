{
  inputs,
  lib,
  ...
}: {
  flake = {
    description = "crocuda.nixos - Dendritic server modules for paranoids and hypochondriacs";
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
  flake-file.inputs = {
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    den.url = lib.mkDefault "github:denful/den";
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###################################
    ## NixOs pkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-deprecated.url = "github:nixos/nixpkgs/nixos-25.11";
  };
}
