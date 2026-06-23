{
  inputs,
  den,
  crocuda,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModule
    inputs.crocuda.flakeModules.default
    # (inputs.den.namespace "crocuda" inputs.crocuda)
    # inputs.normal.flakeModule
  ];

  den.hosts.default = {
    system = "x86_64-linux";
    users.anon = {};
  };
  den.aspects.default = {
    nixos = {pkgs, ...}: {
      users.users.anon = {
        isNormalUser = true;
        initialPassword = "anon";
      };
    };
    includes = [
      # Den helpers
      den.batteries.hostname
      den.aspects.anon
      # Crocuda modules
      crocuda.shell.fish
    ];
  };
}
