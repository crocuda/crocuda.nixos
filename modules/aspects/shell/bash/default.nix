{...}: {
  crocuda.shell.bash = {
    nixos = {lib, ...}: {
      # programs.bash.interactiveShellInit = lib.readFile ./dotfiles/title.sh;
    };
  };
}
