{
  inputs,
  den,
  crocuda,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
    inputs.crocuda.flakeModules.default
    # OR
    # (inputs.den.namespace "crocuda" inputs.crocuda)
  ];

  den.hosts.default = {
    hostName = "nixos";
    system = "x86_64-linux";
    users.anon = {};
  };
  den.aspects.default = {
    nixos = {pkgs, ...}: {
      users.users.anon = {
        isNormalUser = true;
        initialPassword = "anon";
      };
      imports = [
        ../../commons/configuration.nix
        ../../commons/hardware-configuration.nix
      ];
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
