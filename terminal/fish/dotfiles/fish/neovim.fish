## INFO: Works.
function make_local_socket;
  ## Set the socket name to pwd or first arg on command line ($1)
  set -l socket_dir $PWD
  if set -q "$argv[1]"
    set socket_dir $( path dirname "$argv[1]")
  end

  set socket_file 'socket'
  echo $socket_file
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
  set socket_file 'socket'

  ## Escape the socket name
  set socket_dir $(echo $socket_dir | sed 's/\//%2F/g')
  # Encode slash
  set socket $working_dir/$socket_dir/$socket_file

  ## Failed attempt to circumvent sun_len
  # Symlink for sun_len complience
  set link "$socket_name/nvim.socket"
  ln $socket $link

  echo $link
end

# Usage: 
#  - nvid
#  - nvid <directory>
function nvid;
  set socket make_local_socket

  ## Run server and GUI
  mkdir -p  $working_dir/$socket_dir
  set server "nvim --headless --listen $socket"
  eval { $server & } &

  set gui "neovide --server $link"
  eval $gui
end


