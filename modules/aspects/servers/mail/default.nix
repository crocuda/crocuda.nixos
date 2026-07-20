{...}: {
  crocuda.mail.server = {
    nixos = {
      config,
      pkgs,
      lib,
      inputs,
      ...
    }:
      with lib; let
        # Extract domain from email list.
        _extract_domains = mails:
          lib.lists.unique (
            lib.lists.forEach mails (
              mail:
              # Extract domain from mail
                lib.list.last (lib.string.splitString "@")
            )
          );

        # Generate extra configuration.
        # Create an xml file served by caddy for mail client autoconf.
        _make_caddy_extraconf = domains:
          lib.concatLines (
            lib.lists.forEach domains (
              name: ''
                mx1.${name} {
                  #used for cert generation only!
                }
                autoconfig.${name} {
                  handle /mail/config-v1.1.xml {
                      respond "${_generate_xml name}"
                  }
                }
              ''
            )
          );
        # Usage: _make_certs ["example.com"] -> [{cert = ""; key = ""}]
        _generate_xml = name: ''
          <?xml version=\"1.0\"?>
          <clientConfig version=\"1.1\">
            <emailProvider id=\"${name}\">
               <domain>${name}</domain>
               <domain>mx1.${name}</domain>
               <displayName>${name}</displayName>
               <displayNameShort>${name}</displayNameShort>
               <incomingServer type=\"imap\">
                  <hostname>mx1.%EMAILDOMAIN%</hostname>
                  <port>993</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
               </incomingServer>
               <incomingServer type=\"imap\">
                  <hostname>mx1.%EMAILDOMAIN%</hostname>
                  <port>143</port>
                  <socketType>STARTTLS</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
               </incomingServer>
               <outgoingServer type=\"smtp\">
                  <hostname>mx1.%EMAILDOMAIN%</hostname>
                  <port>465</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
               </outgoingServer>
               <outgoingServer type=\"smtp\">
                  <hostname>mx1.%EMAILDOMAIN%</hostname>
                  <port>587</port>
                  <socketType>STARTTLS</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
               </outgoingServer>
            </emailProvider>
            <documentation url=\"${name}\"></documentation>
          </clientConfig>
        '';

        ## Tls certificate function.
        #
        # Get certificates from caddy
        caddy_dir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
        # Get certificates from certbot
        certbot_dir = "/etc/letsencrypt/live";

        _make_certificates = domains:
          lib.lists.forEach domains (
            name:
            # {
            # certPath = "${certbot_dir}/${name}/fullchain.pem";
            # keyPath = "${certbot_dir}/${name}/privkey.pem";
            # }
            {
              certPath = "${caddy_dir}/mx1.${name}/mx1.${name}.crt";
              keyPath = "${caddy_dir}/mx1.${name}/mx1.${name}.key";
            }
          );
      in {
        ###################################
        # Options definition
        options.crocuda.mail = {
          enable = mkEnableOption ''
            Toggle the module
          '';
          accounts = mkOption {
            type = with types; listOf str;
            description = ''
              List of account to create.
            '';
            default = ["anon@example.com"];
          };
        };

        systemd.tmpfiles.rules = [
          # Maddy directories
          # Make them by hand if maddy unit fails
          "d /run/maddy 774 maddy users - -"
          "Z /run/maddy 77 maddy users - -"

          # Symlink to nginx-unit certs
          # "Z /etc/letsencrypt 754 root users - -"
          # "L+ /etc/maddy/certs - - - - /var/spool/unit/certs"
          # Symlink to caddy certs
          "Z /var/lib/caddy 775 caddy users - -"
          "L+ /etc/maddy/certs - - - - ${caddy_dir}"
        ];

        # The mail server
        services.maddy = let
          domains = _extract_domains config.crocuda.servers.mail.accounts;
          primaryDomain = lib.list.first domain;
        in {
          group = "users";
          enable = true;

          inherit primaryDomain;
          hostname = primaryDomain;
          localDomains = domains;

          openFirewall = false;
          ensureAccounts = accounts;
          config = builtins.readFile ./dotfiles/maddy.conf;
          tls = {
            # loader = "acme";
            loader = "file";
            certificates = _make_certificates domains;
          };
        };

        # Serve autodiscovery/autoconfig xml files
        services.caddy = {
          extraConfig = _make_caddy_extraconf domains;
        };
        # users.users."root" = {
        #   initialPassword = "root";
        # };
        # users.users."anon" = {
        #   isNormalUser = true;
        #   initialPassword = "anon";
        # };
      };
  };
}
