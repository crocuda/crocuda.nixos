{inputs, ...}: {
  crocuda.shell.fish = {
    nixos = {
      config,
      pkgs,
      lib,
      inputs,
      ...
    }: {
      programs.fish.enable = true;

      # Retrieve tools installed with cargo,go and bun.
      environment.sessionVariables = rec {
        # Go env
        GOPATH = "$HOME/.go";
        GOBIN = "${GOPATH}/bin";
        CGO_ENABLED = 1;
        PATH = [
          "$HOME/.cargo/bin"
          "$HOME/.bun/bin"
          "$HOME/.go/bin"
        ];
      };

      environment.systemPackages = with pkgs; [
        # Move fast in filesystem
        atuin
        zoxide
        ripgrep

        # find file
        # fzf
        skim
        fd

        ## Fish Shell dependencies
        starship
        fish

        grc # Recolorize commands
        eza # Ls replacement
        htop # Process management
        bat # Display file
      ];
    };
    homeManager = {pkgs, ...}: {
      home.file = {
        # Prompt
        ".config/starship.toml".source = dotfiles/starship.toml;

        ## Shell aliases
        ".aliases".source = dotfiles/fish/.aliases;
        # Neovim client/server helpers and aliases
        ".config/fish/conf.d/neovim.fish".source = dotfiles/fish/neovim.fish;

        # Extra comfort
        ".config/fish/conf.d/title.fish".source = dotfiles/fish/title.fish;
        ".config/fish/conf.d/abbrev.fish".source = dotfiles/fish/abbrev.fish;
      };

      # Shell
      programs = {
        fish = {
          enable = true;
          shellInit = ''
            source ~/.aliases
          '';
          interactiveShellInit = ''
            source ~/.aliases
            source ~/.config/fish/conf.d/*
          '';
          plugins = with pkgs.fishPlugins; [
            {
              name = "grc";
              src = grc.src;
            }
          ];
        };
      };
    };
    crocuda.shell.utils = {
      homeManager = {pkgs, ...}: {
        home.files = {
          # Nushell
          ".config/nushell/config.nu".source = dotfiles/nushell/config.nu;
          ".config/nushell/env.nu".source = dotfiles/nushell/env.nu;

          # Process management
          # ".config/htop/htoprc".source = dotfiles/htop/htoprc;
          # Atuin
          ".config/atuin".source = dotfiles/atuin;

          ## Key bindings for colemak-DH
          ".config/fish/conf.d/interactive.fish".source = dotfiles/fish/interactive.fish;
          ".config/fish/conf.d/colemak.fish".source = dotfiles/fish/colemak.fish;

          # siketyan/ghr plugin and completion
          ".config/fish/conf.d/ghr.fish".text =
            ''
              ghr shell fish | source
              ghr shell fish --completion | source
            ''
            # Custom functions for fast source code browsing
            + ''
              function gcd;
                set dest $(ghr search "$argv" | head -n 1)
                ghr cd $dest
              end
              function gnv;
                set dest $(ghr search "$argv" | head -n 1)
                ghr cd $dest && nvid && exit
              end
            '';
          ".ghr/ghr.toml".text = inputs.nix-std.lib.serde.toTOML {
            applications.nvid = {
              cmd = "${pkgs.neovide}/bin/neovide";
              args = ["%p"];
            };
          };
        };
        programs = {
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
          atuin = {
            enable = true;
            enableFishIntegration = true;
          };
          skim = {
            enable = true;
            enableFishIntegration = true;
          };
          pay-respects = {
            enable = false;
          };
        };
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
      };
    };
  };
}
