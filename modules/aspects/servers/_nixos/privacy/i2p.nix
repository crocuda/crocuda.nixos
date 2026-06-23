{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.crocuda;
  username = "i2pd";
in
  with lib;
    mkIf cfg.servers.web.i2p.enable {
      # Dedicated user and group
      users.groups.i2pd = {};
      users.users.${username} = {
        isSystemUser = true;
        group = "i2pd";
      };

      environment.systemPackages = with pkgs; [
        # Alternative networks
        # Nym nodes
        # nym

        # I2P network
        i2pd
      ];

      environment.etc = {
        "i2pd/i2pd.conf".source = dotfiles/i2pd/i2pd.conf;
        "i2pd/tunnels.conf".source = dotfiles/i2pd/tunnels.conf;
      };
      # Create working dir for Soft and Charm
      systemd.tmpfiles.rules = [
        "d /run/${username} 755 ${username} ${username}"
        "d /var/log/${username} 755 ${username} ${username}"
        "d /var/lib/${username} 755 ${username} ${username}"
      ];

      systemd.services."i2pd" = {
        enable = true;
        after = ["network.target"];

        description = "I2P Router written in C++";
        documentation = [
          "man:i2pd(1) https://i2pd.readthedocs.io/en/latest/"
        ];

        serviceConfig = {
          User = "i2pd";
          Group = "i2pd";
          RuntimeDirectory = "i2pd";
          RuntimeDirectoryMode = "0700";
          LogsDirectory = "i2pd";
          LogsDirectoryMode = "0700";
          Type = "forking";
          ExecStart = ''
            ${pkgs.i2pd}/bin/i2pd \
            --conf=/etc/i2pd/i2pd.conf \
            --tunconf=/etc/i2pd/tunnels.conf \
            --tunnelsdir=/etc/i2pd/tunnels.conf.d \
            --pidfile=/run/i2pd/i2pd.pid \
            --logfile=/var/log/i2pd/i2pd.log \
            --daemon --service
          '';
          ExecReload = "/bin/sh -c 'kill -HUP $MAINPID'";
          PIDFile = "/run/i2pd/i2pd.pid";
          ### Uncomment, if auto restart needed
          #Restart="on-failure";

          # Use SIGTERM to stop i2pd immediately.
          # Some cleanup processes can delay stopping, so we set 30 seconds timeout and then SIGKILL i2pd.
          KillSignal = "SIGTERM";
          TimeoutStopSec = "30s";
          SendSIGKILL = "yes";

          # If you have problems with hanging i2pd, you can try increase this
          LimitNOFILE = "8192";
          # To enable write of coredump uncomment this
          #LimitCORE=infinity
        };
        wantedBy = ["multi-user.target"];
      };
    }
