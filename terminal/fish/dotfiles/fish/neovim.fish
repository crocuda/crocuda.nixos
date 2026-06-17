## Move to the current working directory.
function get_cwd;
  ## Set the socket name to pwd or first arg on command line ($1)
  set -l cwd $PWD
  if set -q argv[1]
    set -l PATH $argv[1]

    if path is -d $PATH
      set cwd $PATH
    else if path is -f $PATH
      set cwd $(path dirname $PATH)
    end
  end
  echo $cwd
end

## INFO: Works.
## Creates a nvim server socket file under the current directory,
## or the sepecified directory.
function make_local_socket;
  set socket_file 'nvim.socket'

  ## Set the socket name to pwd or first arg on command line ($1)
  set -l socket_dir "."
  if set -q "$argv[1]"
    set socket_dir $(path dirname "$argv[1]")
  end
  set socket $socket_dir/$socket_file

  echo $socket
end

## WARNING: Do not work because of UNIX relic behavior,
## the socket path length limitation,
## the sun_len of maximum 108 char length.
function make_tidy_socket;
  ## Set the socket name to pwd or first arg on command line ($1)
  set -l socket_dir $PWD
  if set -q "$argv[1]"
    set socket_dir $( path dirname "$argv[1]")
  end

  set working_dir '/var/lib/nvim/servers'
  set socket_file 'nvim.socket'

  ## Escape the socket name
  set socket_dir $(echo $socket_dir | sed 's/\//%2F/g')
  # Encode slash
  set socket $working_dir/$socket_dir/$socket_file

  mkdir -p  $working_dir/$socket_dir
  ## Failed attempt to circumvent sun_len
  # Symlink for sun_len complience
  set link "$socket_name/nvim.socket"
  ln $socket $link

  echo $link
end

## Restore session .
##
## Nvim auto-session works after GUI initialization.
## However we do not initiae GUI here, so we need to send a command
## to trigger the plugin.
##
function nvim_restore_session;
  # Args
  set dir $argv[1]

  # Set socket path
  set socket $(make_local_socket $dir)

  ## Extra commands
  set extra "nvim \
    --server $socket \
    --remote-send ':<cmd>AutoSession restore<cr><esc>'"
  set cmd $extra
  set orphan "sh -c { $cmd & } >/dev/null 2>&1 &"
  eval $orphan

end

function nvid_listen;
  # Args
  set dir $argv[1]

  ## Run GUI
  if string match -e -q ':' $dir == $dir
    # ssh
    set -l socket $dir
    set gui "neovide --fork --server $socket"
    set cmd $gui
    eval $cmd
  else
    # local
    # Set socket path
    set -l socket $(make_local_socket $dir)
    set cwd $(get_cwd $dir)
    set gui "cd $cwd && neovide --fork --server $socket"
    set cmd $gui
    eval $cmd
  end
end

function nvim_serve;
  # Args
  set dir $argv[1]

  # Set socket path
  set socket $(make_local_socket $dir)

  ## Run server
  set cwd $(get_cwd $dir)
  set server "cd $cwd \
    && nvim \
      --headless \
      --listen $socket"
  set cmd $server
  set orphan "sh -c { $cmd & } >/dev/null 2>&1 &"
  eval $orphan
end

# Run a neovide instance over a nvim server
# Usage: 
#  - nvidd
#  - nvidd <directory>
function nvidd;
  # Args
  set dir $argv[1]

  ## Run server
  nvim_serve $dir
  ## Run GUI
  nvid_listen $dir
  ## Extra commands
  nvim_restore_session $dir
end

