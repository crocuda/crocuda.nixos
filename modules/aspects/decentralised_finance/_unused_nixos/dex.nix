{
  config,
  pkgs,
  pkgs-stable,
  lib,
  inputs,
  system,
  ...
}: let
  cfg = config.crocuda;
in
  with lib;
    mkIf cfg.finance.dex.enable {
      environment.systemPackages = with pkgs; [
        # Wallet
        # exodus

        ## Exchange
        # Dex
        # bisq-desktop
      ];
    }
