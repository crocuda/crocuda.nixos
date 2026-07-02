{
  den,
  crocuda,
  inputs,
  ...
}: {
  flake-file.inputs = {
    nixos-cli.url = "github:nix-community/nixos-cli";
  };
  ## Description:
  # Faster virtual machines + ease of use.
  ## Usage:
  # ```nix`
  # includes = [ crocuda.batteries.vm ];
  # ```
  crocuda.batteries.vm = {
    includes = [
      crocuda.batteries.vm.policies.to-host
    ];
    policies.to-host = {user, ...}: {
      includes = [
        (den.batteries.vm-autologin user.name)
        # DANGER: Do not use in production
        # (den.batteries.tty-autologin user.name)
      ];
    };
    nixos = {...}: {
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 4;
        };
      };
    };
  };
  ## Description:
  # Add a testing user.
  ## Usage:
  # ```nix`
  # includes = [ crocuda.batteries.vm ];
  # ```
  crocuda.batteries."testing-user" = {
    nixos = {...}: {
      users.users."test" = {
        isNormalUser = true;
        initialPassword = "test";
      };
    };
    includes = [
      {
        den.homes.test = {
          system = "x86_64-linux";
          includes = [
            (den.batteries.user-shell "fish")
          ];
        };
      }
    ];
  };
}
