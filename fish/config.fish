set -g fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Aliases
function u; sudo dnf update; end
function i; sudo dnf install $argv; end
function nuke; sudo dnf remove $argv; end
function n; fastfetch; end
function p; poweroff; end
function r; reboot; end
function c; sudo dnf clean all; end
function m; mkdir $argv; end
function fu; flatpak update; end
