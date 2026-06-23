{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.crocuda;
in
  with lib;
    mkIf cfg.servers.web.tor.enable {
      environment.systemPackages = with pkgs; [
        # Tor
        torsocks
        tor-browser
      ];
      ## Tor background service
      services.tor = {
        enable = true;
      };
    }
