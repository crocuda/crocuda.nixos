## Description:
# Faster virtual machines + ease of use.
## Usage:
# ```nix`
# includes = [ crocuda.batteries.vm ];
# ```
{
  den,
  crocuda,
  ...
}: {
  crocuda.batteries.vm.larger = {
    nixos = {...}: {
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 4;
        };
      };
    };
  };

  crocuda.batteries.vm = {
    includes = [
      crocuda.batteries.vm.larger
      (den.batteries.vm-autologin "anon")
      # DANGER: do not use tty autologin in production.
      # (den.batteries.tty-autologin "anon")
    ];
  };
}
