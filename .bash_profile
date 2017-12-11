# .bash_profile: executed for login shells

# Sources runtime config for interactive non-login shells
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Adds user bin directory to PATH
PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
