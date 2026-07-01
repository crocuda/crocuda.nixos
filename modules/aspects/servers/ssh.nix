{...}: {
  crocuda.ssh = {
    nixos = {...}: {
      ################################
      # Ssh
      #
      # Caution:
      # This service silently modifies the firewall to
      # allow tcp and udp on the specified ports.
      #

      # Enable the agent
      programs.ssh.startAgent = true;
      services.gnome.gcr-ssh-agent.enable = false;

      services.openssh = {
        enable = true;
        # require public key authentication for better security
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;

          # Raise the limit for virshle ssh-agent auth.
          MaxAuthTries = 12;

          Macs = [
            # rust libssh2 compat
            "hmac-sha2-256"
            "hmac-sha2-512"
            # default
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];
          # PermitRootLogin = "yes";
        };
      };
    };
  };
}
