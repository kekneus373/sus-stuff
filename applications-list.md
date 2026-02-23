Cross-platform curated software list
====================================

## Debian KDE / Kubuntu (02.2026)

### Base OS

```bash
# [TODO] Install fonts
sudo apt install
```

### Userspace

```bash
# [TODO] Add OnlyOffice, TeamViewer, Angry IP Scanner, AnyDesk, TeamViewer, LocalSend repositories
# Pinta, Curtail on Launchpad; Ventoy on GitHub
sudo apt install chromium falkon bleachbit gimp mesa-utils mc bc vim w3m kate htop putty setserial screen nmap cifs-utils libsmbclient gvfs gvfs-backends libglib2.0-bin libmtp* qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm-sensors cpu-x synapse ffmpeg vlc handbrake simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw nomacs qalculate-qt calibre transmission teamviewer uget inxi # doublecmd-gtk qalculate-gtk xfce4-clipman-plugin parcellite brasero krita bottles obs-studio
```

---

## Fedora LXQt (2025)

### Base OS

```bash
# [TODO] Install codecs and fonts
sudo dnf install
```

### Userspace

```bash
# [TODO] Add RPM Fusion, OnlyOffice, # TeamViewer, # AnyDesk repositories
sudo dnf install brave falkon bleachbit gimp mesa-demos mc bc vim vim-default-editor w3m featherpad htop putty setserial screen putty nmap cifs-utils libsmbclient gvfs-smb qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm_sensors cpu-x synapse ffmpeg vlc simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw  nomacs qalculate-qt calibre transmission-qt uget inxi hplip gvfs-gphoto2 gphoto2 borgbackup pipx # doublecmd-gtk qalculate-gtk brasero krita bottles obs-studio
```
* Excluding `curtail`, `localsend`, `angryip`, `handbrake`, `freefilesync`: not in repos.

## NixOS KDE ❄️

NixOS packages are defined in the `configuration.nix` file located at `MY/Backups/nixos-hp/<DATE>/` under `user` and `environment`

## Arch Linux LXQt (02.2026)

### Base OS

```bash
sudo pacman -S networkmanager nm-connection-editor network-manager-applet blueman gvfs-smb gvfs-mtp gvfs-gphoto2 glib2 earlyoom systembus-notify terminus-font 
```

### Userspace

```bash
sudo pacman -S chromium w3m uget thunderbird doublecmd-qt6 transmission-qt obs-studio kdenlive handbrake audacity bleachbit calibre easyeffects filezilla gimp mc bc putty copyq redshift vlc vlc-plugin-ffmpeg remmina nmap gnome-disk-utility elisa htop libreoffice-fresh qalculate-qt krita meld luanti vim mesa-demos fastfetch kcharselect noto-fonts-emoji
```

---

## Windows - Chocolatey

### Fujitsu Lifebook A574 (05.2025)
```powershell
choco install angryip cdburnerxp filezilla gimp libreoffice-fresh openhashtab peazip qbittorrent teamviewer vim vlc git brave nmap tigervnc rufus choco-cleaner localsend.install dvdstyler brave obs-studio thunderbird angryip cdburnerxp crystaldiskinfo.install doublecmd filezilla gimp libreoffice-fresh peazip qbittorrent openhashtab teamviewer anydesk.install choco-cleaner teraterm putty.install vim vlc rufus onlyoffice krita
```

### Lenovo V570 (05.2025)

```
choco install anydesk.install angryip calibre cdburnerxp doublecmd crystaldiskinfo.install far googlechrome malwarebytes openhashtab vim peazip qbittorrent vlc rufus tor-browser victoria nmap hwinfo thunderbird gimp ffmpeg-full localsend.install
```
