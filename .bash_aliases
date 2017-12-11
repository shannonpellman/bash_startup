# .bash_aliases: user aliases

# Changes sorting of dotfiles
export LC_COLLATE="C"

# alias fuck='thefuck'
if command -v thefuck >/dev/null 2>&1; then
  eval $(thefuck --alias)
fi

# Enables color support
is_color_enabled=false

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  is_color_enabled=true
fi

# grep aliases
alias egrep="egrep -n $(${is_color_enabled} && echo --color=auto)"
alias fgrep="fgrep -n $(${is_color_enabled} && echo --color=auto)"
alias grep="grep -n $(${is_color_enabled} && echo --color=auto)"

# ls aliases
alias ls="ls -F $(${is_color_enabled} && echo --color=auto) --group-directories-first"
alias ll='ls -Al'
alias la='ls -al'
alias l='ls -C'

# alert alias for long-running commands, e.g.,
#   sleep 10; alert
alias alert='notify-send \
    --urgency=low \
    -i "$([ $? = 0 ] && echo terminal || echo error)" \
    "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
