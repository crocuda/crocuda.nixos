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
      user,
      ...
    }: {
      imports = [
        inputs.boulette.nixosModules.default
      ];

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
