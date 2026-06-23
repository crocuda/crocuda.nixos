{
  inputs,
  den,
  normal,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModule
    # inputs.normal.denful.normal
    (inputs.den.namespace "normal" inputs.normal)
    # inputs.normal.flakeModule
  ];

  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.hosts.x86_64-linux.default.users.anon = {};
  # den.hosts.x86_64-linux.default.users.root = {};

  den.aspects.default = {
    includes = [
      den.batteries.hostname
      den.aspects.anon
      normal.android
      normal.terminal.file_manager
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.hello
      ];
      users.users.anon = {
        isNormalUser = true;
        initialPassword = "anon";
      };
    };
  };

  den.aspects.anon = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];
    nixos = {user, ...}: {
      # users.users."${user.userName}" = {
      #   isNormalUser = true;
      #   initialPassword = "anon";
      # };
    };
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.vim];
    };
  };
}
