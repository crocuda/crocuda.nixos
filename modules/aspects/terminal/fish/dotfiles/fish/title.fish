#!/usr/bin/env fish

## From molly-guard

# Walk up the process tree until PID 1 is reached or a process with 'sshd' in
# its /proc/<pid>/cmdline is met. Return success if such a process is found.
function is_child_of_sshd
  set pid $fish_pid
  set ppid $PPID
  # Be a bit paranoid with the guard, should some horribly broken system
  # provide a strange process hierarchy. '[ $pid -ne 1 ]' should be enough for
  # sane systems.
  [ -z "$pid" ] || [ -z "$ppid" ] && return 2
  while [ $pid -gt 1 ] && [ $pid -ne $ppid ];
    if egrep -q 'sshd' /proc/$ppid/cmdline;
      return 0
    end
    set pid $ppid
    set ppid $(grep ^PPid: /proc/$pid/status | tr -dc 0-9)
  end
  return 1
end
set -g is_child_of_sshd

function fish_title
    # If we're connected via ssh, we print the hostname.
    set user $USER
    set -l ssh
    if [ -n "$SSH_TTY" ] || is_child_of_sshd
      set ssh "["$user@(prompt_hostname | string sub -l 10 | string collect)"]"
    end

    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
      echo -- $ssh (string sub -l 20 -- $argv[1]) (prompt_pwd -d 1 -D 1)
    else
      # Don't print "fish" because it's redundant
      set -l command (status current-command)
      if test "$command" = fish
        set command
      end
      echo -- $ssh (string sub -l 20 -- $command) (prompt_pwd -d 1 -D 1)
    end
end
set -g fish_title
