
function fish_user_key_bindings 
  # Rebind Ctrl-L (clear)
  ## Push prompt to bottom
  bind -M default \f 'clear -x; tput cup (math round "$LINES * 3/4") 0; commandline -f repaint-mode'
  bind -M insert \f 'clear -x; tput cup (math round "$LINES * 3/4") 0; commandline -f repaint-mode'

  # Do not close on ctrl-d
  bind --erase --preset -M insert \cd
  bind --erase --preset -M visual \cd
  bind -M visual \cd delete-char

end
set -g fish_user_key_bindings

## Push prompt to bottom
tput cup (math round "$LINES * 3/4") 0

## Deprecated plugin initialisation:
## handled by nix and home-manager.

## Plugins
# set -gx ATUIN_NOBIND "true"
# atuin init fish | source
# direnv hook fish | source
# devenv hook fish | source
# zoxide init fish | source
## Prompt
# starship init fish | source
# enable_transience


