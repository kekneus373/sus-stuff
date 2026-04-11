Cross-platform curated software list
====================================

## Table of Contents

- [Debian KDE / Kubuntu](#debian-kde-kubuntu)
  - [Base OS](#base-os)
  - [Userspace](#userspace)
- [Fedora LXQt](#fedora-lxqt)
  - [Base OS](#base-os-1)
  - [Userspace](#userspace-1)
- [NixOS KDE ❄️](#nixos-kde-)
  - [Base OS](#base-os-2)
  - [Userspace](#userspace-2)
- [Arch Linux LXQt](#arch-linux-lxqt)
  - [Base OS](#base-os-3)
  - [Userspace](#userspace-3)
- [AppImages for "missing-out" distros](#appimages-for-missing-out-distros)
- [Windows - Chocolatey](#windows-chocolatey)
  - [Fujitsu Lifebook A574](#fujitsu-lifebook-a574)
  - [Lenovo V570](#lenovo-v570)

## Debian KDE / Kubuntu

### Base OS

* [Fonts](https://www.linuxcapable.com/how-to-install-microsoft-fonts-on-debian-linux)

### Userspace

* [Brave](https://brave.com/linux/#debian-ubuntu-mint)
* [OnlyOffice](https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-ubuntu.aspx)
* [TeamViewer](https://www.teamviewer.com/en/download/linux/)
* [AnyDesk](https://deb.anydesk.com/howto.html)
* [Angry IP Scanner](https://angryip.org/download/#linux)

<code>
sudo apt install chromium falkon bleachbit gimp mesa-utils mc bc vim w3m kate htop putty setserial screen nmap cifs-utils libsmbclient gvfs gvfs-backends libglib2.0-bin libmtp* qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm-sensors cpu-x synapse ffmpeg vlc handbrake simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw nomacs qalculate-qt calibre transmission teamviewer uget inxi # doublecmd-gtk qalculate-gtk xfce4-clipman-plugin parcellite brasero krita bottles obs-studio
</code>
<p></p>

*Last updated on 07.03.2026 at 21:30*

---

## Fedora LXQt

### Base OS

* [Codecs](https://rpmfusion.org/Howto/Multimedia)
* [Fonts](https://www.linuxcapable.com/install-microsoft-fonts-on-fedora-linux)

### Userspace

* [Brave](https://brave.com/linux/#fedora-41-dnf5)
* [OnlyOffice](https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-rhel.aspx)
* [TeamViewer](https://www.teamviewer.com/en/download/portal/linux/)
* [AnyDesk](https://rpm.anydesk.com/howto.html)
* [Angry IP Scanner](https://angryip.org/download/#linux)

<code>
sudo dnf install brave falkon bleachbit gimp mesa-demos mc bc vim vim-default-editor w3m featherpad htop putty setserial screen putty nmap cifs-utils libsmbclient gvfs-smb qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm_sensors cpu-x synapse ffmpeg vlc simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw  nomacs qalculate-qt calibre transmission-qt uget inxi hplip gvfs-gphoto2 gphoto2 borgbackup pipx # doublecmd-gtk qalculate-gtk brasero krita bottles obs-studio
</code>
<p></p>

* Use AppImages of `localsend` and `handbrake`. `curtail` and `freefilesync` get from Flatpak or build from source.

*Last updated on 07.03.2026 at 21:30*

---

## NixOS KDE ❄️

NixOS packages are defined in the `configuration.nix` file located at `sus-stuff/nixos/hp840g2` under `user` and `environment`.

* To enable AppImages: https://wiki.nixos.org/wiki/Appimage

---

## Arch Linux LXQt

### Base OS

<code>
sudo pacman -S networkmanager nm-connection-editor network-manager-applet blueman bluez bluez-obex unzip gvfs-smb gvfs-mtp gvfs-gphoto2 glib2 earlyoom systembus-notify terminus-font less fuse kwallet5 kwalletmanager hplip xorg-xset
</code>
<p></p>

### Userspace

<code>
sudo pacman -S ark arj lrzip unrar unarchiver 7zip lzop chromium w3m uget thunderbird doublecmd-qt6 transmission-qt obs-studio kdenlive handbrake audacity bleachbit calibre easyeffects calf lsp-plugins-lv2 zam-plugins-lv2 mda.lv2 filezilla gimp mc bc putty copyq redshift vlc vlc-plugin-ffmpeg remmina nmap gnome-disk-utility elisa htop libreoffice-fresh qalculate-qt krita meld luanti vim mesa-demos fastfetch kcharselect noto-fonts-emoji qrca w3m freerdp spice-gtk libvncserver
</code>
<p></p>

*Last updated on 11.04.2026 at 14:50*

---

## AppImages for "missing-out" distros

* [Pinta](https://github.com/pkgforge-dev/Pinta-AppImage)
* [Ventoy](https://github.com/ryuuzaki42/Ventoy_AppImage)
* [WPS Office](https://github.com/ivan-hc/WPS-Office-appimage)
* [OnlyOffice](https://appimage.github.io/ONLYOFFICE/)
* [HandBrake](https://github.com/ivan-hc/Handbrake-appimage)
* [LocalSend](https://localsend.org/download)

*Find more: https://pkgforge-dev.github.io/Anylinux-AppImages/*
*Last updated on 07.03.2026 at 21:30*

---

## Windows - Chocolatey

### Fujitsu Lifebook A574

<code>
choco install angryip cdburnerxp filezilla gimp libreoffice-fresh openhashtab peazip qbittorrent teamviewer vim vlc git brave nmap tigervnc rufus choco-cleaner localsend.install dvdstyler brave obs-studio thunderbird angryip cdburnerxp crystaldiskinfo.install doublecmd filezilla gimp libreoffice-fresh peazip qbittorrent openhashtab teamviewer anydesk.install choco-cleaner teraterm putty.install vim vlc rufus onlyoffice krita
</code>
<p></p>

*Last updated in May 2025*

### Lenovo V570

<code>
choco install anydesk.install angryip calibre cdburnerxp doublecmd crystaldiskinfo.install far googlechrome malwarebytes openhashtab vim peazip qbittorrent vlc rufus tor-browser victoria nmap hwinfo thunderbird gimp ffmpeg-full localsend.install
</code>
<p></p>

*Last updated in May 2025*
