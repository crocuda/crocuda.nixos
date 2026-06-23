# Ferron - A webserver written in Rust
{...}: {
  crocuda.web.ferron = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        ferron
      ];

      systemd.services."ferron" = {
        description = "Ferron - A fast, memory-safe web server written in Rust.";
        documentation = ["https://ferron.sh/docs"];
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.ferron}/bin/ferron --config /etc/ferron/config.kdl";
          ExecReload = "kill -HUP $MAINPID";
          Restart = "on-failure";
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        };
      };

      crocuda.web.ferron.config = with lib; mkBefore (builtins.readFile ./dotfiles/ferron/default.kdl);
      environment.etc.
        "ferron/config.kdl".text = config.crocuda.web.ferron.config;
    };
  };
}
