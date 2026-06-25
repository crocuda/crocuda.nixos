# Add a user to wheel group.
#
# Usage:
#
#```nix
# den.aspects.anon.includes = [
#    (crocuda.batteries.user-wheel "anon")
# ];
#```
{...}: {
  crocuda.batteries.user-wheel = user: {
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
      users.groups = {
        wheel.members = [user];
      };
      ###################################
      # Other
      services.dbus.implementation = "broker";
      security.polkit.enable = true;
    };
  };
}
