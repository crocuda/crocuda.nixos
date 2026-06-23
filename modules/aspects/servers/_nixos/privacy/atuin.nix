{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.crocuda;
in
  with lib;
    mkIf cfg.servers.atuin.enable {
      services.atuin = {
        enable = true;
        path = "/atuin";
        openRegistration = true;
        host = "127.0.0.1";
        port = 8181;
      };
    }
