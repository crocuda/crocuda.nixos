{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  ...
}:
with lib;
  mkIf config.crocuda.shell.fish.utils.enable {
    home.packages = with pkgs; [
      # File convertion
      # dasel

      # Get info on dir
      fastfetch
      onefetch

      # Js utils
      # jo
      jq
      # yq-go

      # Inspect fs and io

      # Disk
      duf # df replacement (go)
      dysk # df replacement (rust)
      dua

      pciutils
      lshw

      # Process management
      # btop
      lsof

      # Linux capabilities
      libcap

      # ssh
      ggh

      # Git repository manager
      siketyan-ghr
    ];
  }
