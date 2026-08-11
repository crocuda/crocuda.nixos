{...}: {
  crocuda.shell.fish = {
    nixos = {
      config,
      pkgs,
      lib,
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

        # Disk
        dysk # df replacement (rust)
        duf # df replacement (go)
        dua

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
      programs.fish = {
        shellAliases = {
          ls = "eza -b";
          lls = "eza -aalghb";
          ll = "eza -lghb";
          tree = "eza --tree -alghb -L 2";
          treee = "eza --tree -alghb";
        };
      };
      home.file = {
        ## Shell aliases
        ".aliases".source = dotfiles/fish/.aliases;

        # Disbale welcome message
        ".config/fish/conf.d/base.fish".text = ''
          set fish_greeting
        '';

        # Deprecated: replaced by "shellAliases"
        ".config/fish/conf.d/eza.fish".text = ''
          alias ls='eza -b'
          alias lls='eza -aalghb'
          alias ll='eza -lghb'
          alias tree='eza --tree -alghb -L 2'
          alias treee='eza --tree -alghb'
        '';

        # Extra comfort
        ".config/fish/conf.d/title.fish".source = dotfiles/fish/title.fish;
        # Atuin
        ".config/atuin".source = dotfiles/atuin;
      };

      # Prompt
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;

        enableTransience = true;
        settings = builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml);

        extraPackages = with pkgs; [starship-jj];
        # presets = ./dotfiles/starship.toml;
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
        atuin = {
          enable = true;
          enableFishIntegration = true;
        };
        zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    };
  };

  crocuda.shell.fish.colemak = {
    homeManager = {...}: {
      home.file = {
        ## Key bindings for colemak-DH
        ".config/fish/conf.d/interactive.fish".source = dotfiles/fish/interactive.fish;
        ".config/fish/conf.d/colemak.fish".source = dotfiles/fish/colemak.fish;
      };
    };
  };

  crocuda.shell.utils = {
    homeManager = {pkgs, ...}: {
      home.file = {
        # Nushell
        ".config/nushell/config.nu".source = dotfiles/nushell/config.nu;
        ".config/nushell/env.nu".source = dotfiles/nushell/env.nu;

        # Neovim client/server helpers and aliases
        ".config/fish/conf.d/neovim-next.fish".source = dotfiles/fish/neovim-next.fish;
        # Process management
        # ".config/htop/htoprc".source = dotfiles/htop/htoprc;

        ## FZF(skim) configuration
        ".config/fish/conf.d/skim.fish".text = ''
          bind -M default \cf "sk"
          bind -M insert \cf "sk"
        '';
      };
      programs = {
        direnv = {
          enable = true;
          enableFishIntegration = true;
          nix-direnv.enable = true;
        };
        atuin = {
          enable = true;
          enableFishIntegration = true;
        };
        zoxide = {
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

        pciutils
        lshw

        # Process management
        # btop
        lsof

        # Linux capabilities
        libcap

        # ssh
        ggh
      ];
    };
  };
}
