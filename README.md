# dotfiles
some <a href="https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/">dotfiles</a> of all my systems.

## DMS UI patches

`quickshell/dms.patch` holds my tweaks to the DankMaterialShell UI (bar text shadow and semibold, glassier panels and dock, light-mode transparency, Spotlight opacity and icons). DMS runs them from `~/.config/quickshell/dms`, which `systemd/user/dms.service.d/shell-override.conf` points it at.

After a DMS update, run `bin/dms-apply-patches` and then `systemctl --user restart dms`.
