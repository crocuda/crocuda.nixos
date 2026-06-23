{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.crocuda;
  certbot_clean_certs =
    pkgs.writeShellScriptBin "certbot_clean_certs"
    (builtins.readFile
      ./dotfiles/letsencrypt-utils/clean_certs.sh);
in
  mkIf cfg.servers.web.letsencrypt.enable {
    environment.systemPackages = [
      pkgs.certbot
      certbot_clean_certs
    ];

    systemd.services = let
      email = cfg.servers.web.letsencrypt.credentials.email;
      units =
        concatMapAttrs
        (
          name: domains: {
            "certbot_${name}_" = {
              description = "Certbot update ssl certificates for ${name}";
              wantedBy = ["certbot.target"];
              serviceConfig = {
                Type = "oneshot";
                User = "root";
                Group = "users";
                ExecStartPre = ''
                  -${certbot_clean_certs}/bin/certbot_clean_certs clean ${name}
                '';
                ExecStart =
                  ''
                    ${pkgs.certbot}/bin/certbot certonly \
                    --cert-name ${name} \
                  ''
                  + concatMapStrings (domain: "-d ${domain} ") domains
                  + ''
                    --standalone \
                    -n \
                  ''
                  + ''
                    --agree-tos \
                    --email ${email}
                  '';
                StandardInput = "null";
                StandardOutput = "journal+console";
                StandardError = "journal";
              };
            };
          }
        )
        cfg.servers.web.letsencrypt.domains;
    in
      units;

    systemd.timers."certbot" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        OnCalendar = "weekly";
      };
    };
  }
