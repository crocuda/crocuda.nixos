# Abbreviations
# Force certain commands usage.

set -U ABBR_TIPS_PROMPT "\n💡 \e[1m{{ .abbr }}\e[0m => {{ .cmd }}"
set -U ABBR_TIPS_ALIAS_WHITELIST # Not set

set -U ABBR_TIPS_REGEXES '(^(\w+\s+)+(-{1,2})\w+)(\s\S+)' '(^( ?\w+){3}).*' '(^( ?\w+){2}).*' '(^( ?\w+){1}).*'

# 1 : Test command with arguments removed
# 2 : Test the firsts three words
# 3 : Test the firsts two words
# 4 : Test the first word


## Filesystem
abbr -a dufl duf --only local

## Jujutsu
abbr -a jjdiffedit NVIM_APPNAME=nvchad jj diffedit
abbr -a jjsplit NVIM_APPNAME=nvchad jj split
