{...}: {
  flake-file.inputs = {
    nixos-cli.url = "github:nix-community/nixos-cli";
  };
  crocuda.nixos-helpers = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        # Nix generations diff tool
        nvd
        # Nixos documentation
        nh
        # Lix/Nix unit testing
        nix-unit

        # Deployment
        nixos-anywhere
        nixos-generators
        disko
        deploy-rs

        # Secrets and keys
        sops
        age
        ssh-to-age # ed25519 to age
      ];

      #########################
      # Nixos improved cli
      programs.nixos-cli = {
        enable = true;
        settings = {
          use_nvd = true;
        };
      };
    };
    homeManager = {pkgs, ...}: {
      home.file = {
        ".config/fish/conf.d/nixos-helpers.fish".text = ''
          function where;
            set BIN $argv[1]
            set BIN_PATH $(readlink -f $(which $BIN))
            echo $BIN_PATH
          end
          function what;
            set BIN $argv[1]
            set BIN_PATH $(readlink -f $(which $BIN))
            set STORE_PATH $(echo $BIN_PATH | cut -d "/" -f 1-4)
            echo $STORE_PATH
          end

        '';
      };
    };
  };
}
