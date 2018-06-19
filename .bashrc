# .bashrc: executed for interactive non-login shells

# Checks if a given command is avaiable
function is_installed() {
  command -v $1 >/dev/null 2>&1

  return $?
}

# Sources global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Sources user aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Sources environment-specific definitions
if [ -d ~/.bashrc.d/ ]; then
    for script in ~/.bashrc.d/*; do
        . "${script}"
    done
fi

# Appends a slash to symlinked directories on tab completion
bind 'set mark-symlinked-directories on'

# Updates PS1 to include the current branch if working in a git repository
for script in /usr/share/git-core/contrib/completion/git-prompt.sh \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion
do
    if [[ -f "${script}" ]]; then
        . "${script}"
        export GIT_PS1_SHOWDIRTYSTATE=1

        break
    fi
done

# Customizes PS1
bold='\[\033[1m\]'
fg_default='\[\033[39m\]'
fg_blue='\[\033[34m\]'
fg_green='\[\033[32m\]'
fg_magenta='\[\033[35m\]'
fg_red='\[\033[01;38;5;1m\]'
reset='\[\033[00m\]'

[[ -z ${user_color+x} ]] && user_color=$([ ${EUID} == 0 ] && echo "${fg_red}" || echo "${fg_green}")
[[ -z ${prompt+x} ]] && prompt='\$'

_PS1='${debian_chroot:+($debian_chroot)}'
_PS1+="${bold}${user_color}\u@\h"
_PS1+="${fg_blue} \w"

if [[ ${GIT_PS1_SHOWDIRTYSTATE} == 1 ]]; then
  _PS1+="${fg_magenta}\$(__git_ps1)"
fi

_PS1+="${reset} [\$(date +%H:%M:%S)]\n"
_PS1+="${bold}${user_color}${prompt}${reset} "

export PS1="${_PS1}"
