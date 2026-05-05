{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  # Maddy config
  cfg = config.crocuda.servers;
  domains = cfg.mail.maddy.domains;
  accounts = cfg.mail.maddy.accounts;
  primaryDomain = builtins.elemAt domains 0;

  # Get certificates from caddy
  caddy_dir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
  # Get certificates from certbot
  certbot_dir = "/etc/letsencrypt/live";

  ## Tls certificate function.

  # Generate extra configuration.
  # Create an xml file served by caddy for mail client autoconf.
  _make_caddy_extraconf = domains:
    lib.concatLines (
      lib.lists.forEach domains (
        name: ''
          autoconfig.${name}/mail/config-v1.1.xml {
            respond "${_generate_xml name}" 200
          }
        ''
      )
    );
  # Usage: _make_certs ["example.com"] -> [{cert = ""; key = ""}]
  _generate_xml = name: ''
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <clientConfig version=\"1.1\">
      <emailProvider id=\"${name}\">
         <domain>example.com</domain>
         <incomingServer type=\"imap\">
            <hostname>imap.${name}</hostname>
            <port>993</port>
            <socketType>SSL</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
         </incomingServer>
         <incomingServer type=\"imap\">
            <hostname>imap.${name}</hostname>
            <port>143</port>
            <socketType>STARTTLS</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
         </incomingServer>
         <outgoingServer type=\"smtp\">
            <hostname>smtp.${name}</hostname>
            <port>465</port>
            <socketType>SSL</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
         </outgoingServer>
         <outgoingServer type=\"smtp\">
            <hostname>smtp.${name}</hostname>
            <port>587</port>
            <socketType>STARTTLS</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
         </outgoingServer>
      </emailProvider>
    </clientConfig>
  '';

  _make_certificates = domains:
    lib.lists.forEach domains (
      name:
      # {
      # certPath = "${certbot_dir}/${name}/fullchain.pem";
      # keyPath = "${certbot_dir}/${name}/privkey.pem";
      # }
      {
        certPath = "${caddy_dir}/${name}/${name}.crt";
        keyPath = "${caddy_dir}/${name}/${name}.key";
      }
    );
in
  with lib;
    mkIf cfg.mail.maddy.enable {
      systemd.tmpfiles.rules = [
        # Maddy directories
        # Make them by hand if maddy unit fails
        "d /run/maddy 774 maddy users - -"
        "Z /run/maddy 774 maddy users - -"
        # Symlink to nginx-unit certs
        "L+ /etc/maddy/certs - - - - /var/spool/unit/certs"
        "Z /etc/letsencrypt 754 root users - -"
      ];

      # The mail server
      services.maddy = {
        group = "users";
        enable = true;

        hostname = primaryDomain;
        localDomains = domains;
        inherit primaryDomain;

        openFirewall = false;
        ensureAccounts = accounts;
        config = builtins.readFile ./dotfiles/maddy.conf;
        tls = {
          loader = "file";
          certificates = _make_certificates domains;
        };
      };

      # Serve autodiscovery/autoconfig xml files
      services.caddy = {
        extraConfig = _make_caddy_extraconf domains;
      };
      users.users."root" = {
        initialPassword = "root";
      };
      users.users."anon" = {
        isNormalUser = true;
        initialPassword = "anon";
      };
    }
