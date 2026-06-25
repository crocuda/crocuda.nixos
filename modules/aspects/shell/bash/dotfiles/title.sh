#!/usr/bin/env bash

## From molly-guard

# Walk up the process tree until PID 1 is reached or a process with 'sshd' in
# its /proc/<pid>/cmdline is met. Return success if such a process is found.
is_child_of_sshd(){
  pid=$$
  ppid=$PPID
  # Be a bit paranoid with the guard, should some horribly broken system
  # provide a strange process hierarchy. '[ $pid -ne 1 ]' should be enough for
  # sane systems.
  [ -z "$pid" ] || [ -z "$ppid" ] && return 2
  while [ $pid -gt 1 ] && [ $pid -ne $ppid ]; do
    if egrep -q 'sshd' /proc/$ppid/cmdline; then
      return 0
    fi
    pid=$ppid
    ppid=$(grep ^PPid: /proc/$pid/status | tr -dc 0-9)
  done
  return 1
}

bash_title(){
    user=$USER
    ssh=""
    if [[ -n "$SSH_TTY" ]] || is_child_of_sshd; then
      ssh="["$user@$(hostname -s)"]"
    fi
    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    command=$0
    if [ -z "$command" ]; then
      echo "$ssh $command $(pwd)"
    else
      # Don't print "bash" because it's redundant
      if [ $command = "bash" ]; then
        command=""
      fi
      echo "$ssh $command $(pwd)"
    fi
}

set_title(){
    trap 'echo -ne "\033]0;$(bash_title)\007"' DEBUG
}

set_title



