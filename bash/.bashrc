#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#Aliases
alias u="sudo pacman -Syyyuuuu"
alias i="sudo pacman -S"
alias nuke="sudo pacman -Runs"
alias n="neofetch"
alias p="poweroff"
alias r="reboot"
