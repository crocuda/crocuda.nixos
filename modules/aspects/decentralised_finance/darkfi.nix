{inputs, ...}: {
  flake-file.inputs = {
    # DarkIRC
    darkfi.url = "github:pipelight/darkfi.nix?ref=dev";
  };

  crocuda.darkfi = {
    nixos = {
      pkgs,
      lib,
      system,
      ...
    }: let
      darkfi = inputs.darkfi.packages.${system}.default;
    in {
      environment.systemPackages = [
        # Darkfi suit
        darkfi
      ];
      ## Darkirc messaging background service
      systemd.user.services."darkircd" = {
        description = "DarkIRC - Strong anonymity P2P chat.";
        enable = true;
        after = ["network.target"];
        serviceConfig = {
          ExecStart = "${darkfi}/bin/darkirc";
        };
        wantedBy = ["multi-user.target"];
      };
    };
  };
}
