#!/usr/bin/env sh
# set -x

# Remove unused certificates in /letsencrypt
# Inspired by disko: https://github.com/nix-community/disko.git

LETSENCRYPT_DIR="/etc/letsencrypt"

showUsage() {
  cat <<EOF
Usage: $0 [OPTIONS]
  -h, --help              Display this help message.
  clean  DOMAIN_NAME      Clean unused cert for a domain. (ex: clean \"example.com\")
EOF
}

parseArgs() {
  [[ $# -eq 0 ]] && {
    showUsage
    exit 1
  }
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      showUsage
      exit 0
      ;;
    --dry-run)
      dry_run=y
      ;;
    clean)
      if [[ $# -lt 2 ]]; then
        echo "Provide a domain name. (ex: \"example.com\")" >&2
        exit 1
      fi
      remove_unused_certs $2
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      showUsage
      exit 1
      ;;
    esac
    shift
  done
}

maybeRun () {
  if [[ -z ${dry_run-} ]]; then
    "$@"
  else
    echo "Would run: $*"
  fi
}

# Get cert names in required directories
get_cert_list(){
  #Args
  domain=$1
  directory=$2

  declare -a files=("")
  symlinks=$(eval "ls -d $LETSENCRYPT_DIR/$directory/$domain/*.pem")
  for symlink in ${symlinks[@]}; do
    files+=" "$(basename $(readlink -f $symlink))
  done
  echo ${files[@]}
}

# Compare certificate names between /archive and /live directorise.
# Gather every certificate that is not live (unused)
get_unused_list(){
  #Args
  domain=$1

  archive=$(get_cert_list $domain "archive")
  # echo ${archive[@]}
  live=$(get_cert_list $domain "live")
  # echo ${live[@]}
  unused=$(echo ${archive[@]} ${live[@]} | tr ' ' '\n' | sort | uniq -u)
  for filename in ${unused[@]}; do
    path="$LETSENCRYPT_DIR/archive/$domain/$filename"
    echo $path
  done

}

remove_unused_certs(){
  #Args
  domain=$1
  unused=$(get_unused_list $domain)
  for filepath in ${unused[@]}; do
    maybeRun rm $filepath
  done
}

main(){
  parseArgs "$@"
}

main "$@"
