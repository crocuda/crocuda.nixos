{...}: {
  crocuda.wheel = {
    nixos = {
      config,
      lib,
      user,
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
        wheel.members = user;
      };
      ###################################
      # Other
      services.dbus.implementation = "broker";
      security.polkit.enable = true;
    };
  };
}
