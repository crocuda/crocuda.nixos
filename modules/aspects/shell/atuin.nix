{...}: {
  crocuda.shell.atuin = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.atuin = {
        enable = true;
        path = "/atuin";
        openRegistration = true;
        host = "127.0.0.1";
        port = 8181;
      };
    };
  };
}
