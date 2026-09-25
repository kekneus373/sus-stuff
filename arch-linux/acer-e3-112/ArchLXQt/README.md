# ArchLXQt

<mark><b>🚧 WIP, fellows! Still a lot to unpack.</b></mark>

A pile of bash scripts and dotfiles that turn wacky / misbehaving computers into
something you can (kind of) use daily.

Built for people whose hardware can't "afford" a mentally sane DE like GNOME or
KDE — low on RAM, low on storage, or both. The payoff: a lean LXQt session on
Arch that stays out of your way.

## Repo structure (exported 15/06/2026)

- `01-restore-sessionconf.bash` — restore the saved session config
- `01-session.conf` — the session configuration to restore
- `02-xprinter-arch/` — XPrinter 58/80/76 driver bits for Arch
  - `02-xprinter-arch-install.bash` — unpacks and installs the driver by hand
  - `data.tar.xz` — extracted payload from the vendor `.deb`
  - `xprinter-58_80_76-Linux-3.13.48_all(1).deb` — **not included**, see below
- `03-stop-redshift.bash` — kill redshift so it stops fighting you
- `config/` — user config files (drop into `~/.config`)
- `etc/` — misc system-level settings
  - `etcarc.log` — Access denied files, thus never included
- `fonts.txt` — fonts worth installing (not included)
- `local-share` — profile tweaks
  - `kdenlive/` — good video editor starting point, optimized for 1366x768 screens
- `Templates/` — (empty) file templates for the file manager

## Requirements

- Arch Linux (or derivative) with enough disk for `pacman` to complain about
- Linux LTS recommended
- LXQt
- Bash

## Proprietary driver note

The XPrinter `.deb` is proprietary vendor software, so it is **not** shipped in
this repo. Download it yourself from the XPrinter support site, drop it into
`02-xprinter-arch/`, then run the install script. Skip the whole folder if you
don't own one of these printers.

## Usage

Scripts are numbered in the order they were created - no specific dependencies:
  ```bash
    chmod +x *.bash
    ./01-restore-sessionconf.bash
    sudo ./02-xprinter-arch/02-xprinter-arch-install.bash   # only if you have this printer
    ./03-stop-redshift.bash
  ```
Copy `config/`, `Templates/` and friends into place as needed (`~/.config`,
`~/Templates`, ...). Read the scripts before running them; they were written for
one specific cursed machine and may be rude to yours. 💻

## Lore

- `02-xprinter-arch` unpacks a `.deb` payload by hand — that's the point, since
  there's no proper Arch package for this printer.
- Nothing here is polished. It works, which is a higher bar than the hardware.

