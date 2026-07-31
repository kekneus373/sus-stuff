# ~/.bashrc: executed by bash(1) for non-login shells.
# !! Optimized for accessing the device over COM port.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# History configuration

# └── +++ Enable

#HISTCONTROL=ignoreboth
#shopt -s histappend
#HISTSIZE=1000
#HISTFILESIZE=2000

# └── --- Disable

HISTSIZE=1000
HISTFILESIZE=0
unset HISTFILE

# Check the window size after each command
shopt -s checkwinsize

# Enable color support for ls and common commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dir='ls -alF'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias mc='mc -b'
alias vi='vim'

# Git aliases (if git is installed)
if command -v git &> /dev/null; then
    alias gs='git status'
    alias ga='git add .'
    alias gc='git commit -m'
    alias gp='git push'
fi

# Source other bashrc files if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.bash_prompt ]; then
    . ~/.bash_prompt
fi

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Serial console quirks & app preferences
export TERM=xterm
export EDITOR=vim
