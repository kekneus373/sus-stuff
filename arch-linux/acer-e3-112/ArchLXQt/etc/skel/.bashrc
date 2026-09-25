#
# ~/.bashrc
#

# set PATH so it includes ~/Applications if it exists
if [ -d "$HOME/Applications" ] ; then
    PATH="$HOME/Applications:$PATH"
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
