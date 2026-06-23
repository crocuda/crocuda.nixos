{
  config,
  pkgs-stable,
  lib,
  inputs,
  system,
  ...
}: let
  cfg = config.crocuda;
  pkgs = pkgs-stable;
in
  with lib;
    mkIf cfg.finance.wownero.enable {
      boot.kernelParams = mkAfter ["nr_hugepages=1024"];

      environment.systemPackages = with pkgs; [
        wownero
        # Mining
      ];

      systemd.tmpfiles.rules = [
        "d /persist/wownero 755 wownero users - -"
      ];
      users.users.wownero = {
        home = "/persist/wownero";
        isNormalUser = true;
      };

      environment.etc = {
        "wownero/wownerod.conf".source = dotfiles/wownero/wownerod.conf;
      };

      # Run wownero node
      systemd.services."wownerod" = {
        enable = true;
        after = ["network.target"];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.wownero}/bin/wownerod \
              --config-file /etc/wownero/wownerod.conf \
              --non-interactive
          '';
          User = "wownero";
          Group = "users";
          Type = "simple";
          # WorkingDirectory = "~";
          StateDirectory = "wownero";
          LogsDirectory = "wownero";
        };
        wantedBy = ["multi-user.target"];
      };
    }
