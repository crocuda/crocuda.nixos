# Git / Github and forge helper.
{inputs, ...}: {
  flake-file.inputs = {
    nix-std.url = "github:chessai/nix-std";
  };
  crocuda.shell.git = {
    homeManager = {pkgs, ...}: {
      home.file = {
        # siketyan/ghr plugin and completion
        ".config/fish/conf.d/git.fish".text =
          ''
            alias gitu='git add . && git commit && git push'
          ''
          +
          ## Jujutsu
          ''
            abbr -a jjdiffedit NVIM_APPNAME=nvchad jj diffedit
            abbr -a jjsplit NVIM_APPNAME=nvchad jj split
          '';

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
    };
  };
}
