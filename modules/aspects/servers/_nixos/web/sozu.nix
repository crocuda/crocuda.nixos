{
  config,
  pkgs,
  pkgs-unstable,
  pkgs-deprecated,
  lib,
  inputs,
  ...
}: let
  cfg = config.crocuda;
  sozu = pkgs-unstable.sozu;
in
  with lib;
    mkIf cfg.servers.web.sozu.enable {
      environment.systemPackages = [
        # Tcp proxy written in Rust
        sozu
      ];

      # Main daemon config
      crocuda.servers.web.sozu.config = mkBefore {
        command_socket = "/etc/sozu/sozu.sock";
        saved_state = "/etc/sozu/state.json";

        log_level = "info";
        log_target = "stdout";
        access_logs_target = "stdout";

        command_buffer_size = 16384;
        worker_count = 2;
        handle_process_affinity = false;
        max_connections = 500;
        max_buffers = 500;
        buffer_size = 16384;
        activate_listeners = true;
      };

      environment.etc.
        "sozu/config.toml".text =
        inputs.nix-std.lib.serde.toTOML cfg.servers.web.sozu.config;

      # Systemd unit template adapted from sozu doc/recipe.md
      systemd.services."sozu" = {
        description = "Sozu - A HTTP reverse proxy, configurable at runtime, fast and safe, built in Rust.";
        documentation = ["https://docs.rs/sozu/"];
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = "${sozu}/bin/sozu start --config /etc/sozu/config.toml";
          ExecReload = "${sozu}/bin/sozu --config /etc/sozu/config.toml reload";
          Restart = "on-failure";
          # User = "sozu";
          # Group = "users";
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        };
      };
      systemd.tmpfiles.rules = [
        "d /etc/sozu 754 root users - -"
        "f /etc/sozu/state.json 754 root users - -"
      ];
    }
