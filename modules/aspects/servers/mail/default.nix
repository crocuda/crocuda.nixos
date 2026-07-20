{crocuda, ...}: {
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  crocuda.mails = {
    include = [crocuda.mail.secrets];
    nixos = {
      config,
      options,
      pkgs,
      lib,
      ...
    }: let
      # Extract domain from email list.
      _extract_domains = mails:
        lib.lists.unique (
          lib.lists.forEach mails (
            mail:
            # Extract domain from mail
              lib.lists.last (lib.strings.splitString "@" mail)
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
      # certbot_dir = "/etc/letsencrypt/live";
      #
      # Usage: _make_certificates ["example.com"] -> [{cert = ""; key = ""}]
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

      accounts = config.crocuda.mails.accounts;
      domains = _extract_domains accounts;
      primaryDomain = builtins.elemAt domains 0;
    in {
      ###################################
      # Options definition
      options.crocuda.mails = {
        enable = lib.mkEnableOption ''
          Toggle the module
        '';
        accounts = lib.mkOption {
          type = with lib.types; listOf str;
          description = ''
            List of account to create.
          '';
          default = ["anon@example.com"];
        };
      };

      config = {
        systemd.tmpfiles.rules = [
          # Maddy directories
          # Make them by hand if maddy unit fails
          "d /run/maddy 774 maddy users - -"
          "Z /run/maddy 774 maddy users - -"

          # Symlink to nginx-unit certs
          # "Z /etc/letsencrypt 754 root users - -"
          # "L+ /etc/maddy/certs - - - - /var/spool/unit/certs"
          # Symlink to caddy certs
          # "Z /var/lib/caddy 775 caddy users - -"
          "L+ /etc/maddy/certs - - - - ${caddy_dir}"
        ];

        # The mail server
        systemd.services."maddy-ensure-permissions" = {
          enable = true;
          wantedBy = ["maddy.service"];
          serviceConfig = {
            User = "root";
            ExecStart = ''
              ${pkgs.coreutils}/bin/chmod -R g+rx ${caddy_dir}
            '';
          };
        };
        systemd.services."maddy" = {
          after = [
            "caddy.service"
            "maddy-ensure-permissions.service"
          ];
          serviceConfig = {
          };
        };
        services.maddy = {
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
      };
    };
  };
  crocuda.mails.secrets = {
    nixos = {
      config,
      options,
      pkgs,
      lib,
      ...
    }: let
      accounts = config.crocuda.mails.accounts;
    in {
      ## Only if sops enable
      config = lib.optionalAttrs (builtins.hasAttr "sops" options) {
        sops.secrets = builtins.listToAttrs (lib.forEach accounts (
          account: {
            name = "mails/${account}";
            value = {
              owner = "root";
              group = "users";
              mode = "0440";
              path = "/var/lib/maddy/secrets/${account}";
            };
          }
        ));
        systemd.services."maddy-ensure-passwords" = {
          enable = true;
          wantedBy = ["maddy.service"];
          serviceConfig = {
            User = "root";
            ExecStart = lib.concatLines (
              lib.forEach accounts (account: ''
                cat ${config.sops.secrets."mails/${account}".path} | ${pkgs.maddy}/bin/maddyctl creds password
              '')
            );
          };
        };
      };
    };
  };
}
