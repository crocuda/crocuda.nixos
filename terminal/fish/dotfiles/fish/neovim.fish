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

# Usage: 
#  - nvidd
#  - nvidd <directory>
function nvidd;

  # Set socket path
  set socket $(make_local_socket $argv[1])

  set pwd $PWD
  set cwd $(get_cwd $argv[1])

  ## Run server
  set server "cd $cwd \
    && nvim \
      --headless \
      --listen $socket"
  set cmd $server
  set orphan "sh -c { $cmd & } >/dev/null 2>&1 &"
  eval $orphan

  ## Run GUI
  set gui "cd $cwd && neovide --fork --server $socket"
  set cmd $gui
  eval $cmd

  ## Extra commands
  set extra "nvim \
    --server $socket \
    --remote-send ':<cmd>AutoSession restore<cr><esc>'"
  set cmd $extra
  set orphan "sh -c { $cmd & } >/dev/null 2>&1 &"
  eval $orphan

end


