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


# Set the environment variable for Wayland
set -x ELECTRON_OZONE_PLATFORM_HINT auto
set -Ux SDL_VIDEODRIVER wayland
set -Ux QT_QPA_PLATFORM wayland
set -Ux QT_WAYLAND_DISABLE_WINDOWDECORATION 0
set -Ux QT_QPA_PLATFORMTHEME qt5ct
set -e QT_STYLE_OVERRIDE

# bun
set --export BUN_INSTALL "$HOME/.bun"set --export PATH $BUN_INSTALL/bin $PATH

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

function vlc
    env QT_QPA_PLATFORM=wayland vlc $argv
end

function cursor
    nohup /home/v8v88v8v88/.local/bin/Cursor $argv >/dev/null 2>&1 & disown
end
set -gx PATH $HOME/.local/bin $PATH

# graphics drivers
set -gx LIBVA_DRIVER_NAME iHD
set -gx MESA_LOADER_DRIVER_OVERRIDE iris
