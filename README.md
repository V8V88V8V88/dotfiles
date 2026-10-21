# dotfiles
some <a href="https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/">dotfiles</a> of all my systems.

## DMS UI patches

`quickshell/dms.patch` holds my tweaks to the DMS 2.0 UI (bar text shadow and semibold, bar tint when a workspace has windows, sharp dock icons and smoother magnification, no hover bounce while magnifying). DMS runs them from `~/.config/quickshell/dms`, which `systemd/user/dms.service.d/shell-override.conf` points it at. DMS settings live in `dms/` (`~/.config/dms`).

After a DMS update, run `bin/dms-apply-patches` and then `systemctl --user restart dms`.
