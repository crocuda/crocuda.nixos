## Decription:
#
# Loosen wheel group security
#
## Usage:
#
#```nix
# includes = [ crocuda.batteries.user-wheel ];
#```
{...}: {
  crocuda.batteries.loose-wheel = {
    nixos = {
      config,
      lib,
      ...
    }: {
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
      ##########################
      ## Ssh config to allow private flakes
      security.sudo.extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';

      ###################################
      # Other
      services.dbus.implementation = "broker";
      security.polkit.enable = true;
    };
  };
}
