{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
  mkIf config.crocuda.shell.fish.enable {
    home.file = mkMerge [
      {
        # Prompt
        ".config/starship.toml".source = dotfiles/starship.toml;

        ## Shell aliases
        ".aliases".source = dotfiles/fish/.aliases;
        # Neovim client/server helpers and aliases
        ".config/fish/conf.d/neovim.fish".source = dotfiles/fish/neovim.fish;

        # Extra comfort
        ".config/fish/conf.d/title.fish".source = dotfiles/fish/title.fish;
        ".config/fish/conf.d/abbrev.fish".source = dotfiles/fish/abbrev.fish;
      }
      (mkIf config.crocuda.shell.fish.utils.enable {
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
      })
      (mkIf config.crocuda.shell.fish.utils.enable
        {
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
        })
    ];

    # Shell
    programs = mkMerge [
      {
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
      }
      (mkIf config.crocuda.shell.fish.utils.enable {
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
      })
    ];
  }
