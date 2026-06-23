{inputs, ...}: {
  flake-file.inputs = {
    # SysAdmin
    boulette = {
      url = "github:pipelight/boulette?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  crocuda.servers.security = {
    nixos = {
      config,
      lib,
      ...
    }: {
      imports = [
        inputs.boulette.nixosModules.default
      ];
      ###################################
      # Admin users
      # loosen security for fast sudoing
      security.sudo.extraRules = [
        {
          groups = ["wheel"];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
      users.groups = {
        wheel.members = config.crocuda.users;
      };

      ###################################
      # Molly guard
      services.boulette = {
        enable = true;
        enableFish = true;
        enableBash = true;
        sshOnly = false;
        enableSudoWrapper = true;
        challengeType = "hostname";
      };

      ###################################
      # Other
      services.dbus.implementation = "broker";
      security.polkit.enable = true;
    };
    homeManager = {...}: {
      imports = [
        inputs.boulette.hmModules.default
      ];
      services.boulette = {
        enable = true;
        # enableFish = true;
        enableBash = true;
        sshOnly = false;
        enableSudoWrapper = true;
        challengeType = "hostname";
      };
    };
  };
}
