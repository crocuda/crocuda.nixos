{...}: {
  crocuda.logs = {
    nixos = {pkgs, ...}: {
      services.rsyslogd = {
        enable = true;
        # defaultConfig = ''
        # '';
      };
      services.logrotate = {
        enable = true;
      };
      environment.systemPackages = with pkgs; [
        logrotate
        rsyslog
      ];
    };
  };
}
