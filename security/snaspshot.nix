{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Snapshots
    snapper
  ];

  # Enable Snapper
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = {
      # Root filesystem snapshots
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = ["root" "@wheel"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # Retention policy
        TIMELINE_MIN_AGE = "1800"; # 30 minutes
        TIMELINE_LIMIT_HOURLY = "24"; # keep 24 hourly
        TIMELINE_LIMIT_DAILY = "7"; # keep 7 daily
        TIMELINE_LIMIT_WEEKLY = "4"; # keep 4 weekly
        TIMELINE_LIMIT_MONTHLY = "6"; # keep 6 monthly
        TIMELINE_LIMIT_YEARLY = "1"; # keep 1 yearly
      };

      # Home directory snapshots
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = ["admin"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = "36";
        TIMELINE_LIMIT_DAILY = "14";
        TIMELINE_LIMIT_WEEKLY = "4";
        TIMELINE_LIMIT_MONTHLY = "3";
        TIMELINE_LIMIT_YEARLY = "0";
      };
    };
  };

  # Ensure snapper directories exist
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root root -"
  ];
}
