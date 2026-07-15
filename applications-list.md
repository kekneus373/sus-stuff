✨ Cross-platform curated software list
=======================================

## Table of Contents

- [Debian KDE / Kubuntu](#debian-kde-kubuntu)
  - [Base OS](#base-os)
  - [Userspace](#userspace)
- [Fedora LXQt](#fedora-lxqt)
  - [Base OS](#base-os-1)
  - [Userspace](#userspace-1)
- [NixOS KDE ❄️](#nixos-kde-)
- [Arch Linux LXQt](#arch-linux-lxqt)
  - [Base OS](#base-os-2)
  - [Userspace](#userspace-2)
- [AppImages for "missing-out" distros](#appimages-for-missing-out-distros)
- [Windows - Chocolatey](#windows-chocolatey)
  - [Fujitsu Lifebook A574](#fujitsu-lifebook-a574)
  - [Lenovo V570](#lenovo-v570)
  - [Atom D525](#atom-d525)

## Debian KDE / Kubuntu

### Base OS

* [Fonts](https://www.linuxcapable.com/how-to-install-microsoft-fonts-on-debian-linux)

<code>sudo apt install fuse3 ntfs-3g dosfstools exfatprogs</code>
<p></p>

### Userspace

* [Brave](https://brave.com/linux/#debian-ubuntu-mint)
* [OnlyOffice](https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-ubuntu.aspx)
* [TeamViewer](https://www.teamviewer.com/en/download/linux/)
* [AnyDesk](https://deb.anydesk.com/howto.html)
* [Angry IP Scanner](https://angryip.org/download/#linux)

<code>sudo apt install chromium falkon bleachbit gimp mesa-utils mc bc vim w3m kate htop psmisc putty setserial screen nmap net-tools cifs-utils libsmbclient gvfs gvfs-backends libglib2.0-bin libmtp* qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm-sensors cpu-x synapse ffmpeg vlc handbrake simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw nomacs qalculate-qt calibre transmission teamviewer uget inxi</code>
<p></p>

* Optional: `doublecmd-gtk qalculate-gtk xfce4-clipman-plugin parcellite brasero krita bottles obs-studio`

*🕒 Last updated on 10.06.2026 at 00:35*

---

## Fedora LXQt

### Base OS

* [Codecs](https://rpmfusion.org/Howto/Multimedia)
* [Fonts](https://www.linuxcapable.com/install-microsoft-fonts-on-fedora-linux)

<code>sudo dnf install fuse3 ntfs-3g dosfstools exfatprogs</code>
<p></p>

### Userspace

* [Brave](https://brave.com/linux/#fedora-41-dnf5)
* [OnlyOffice](https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-rhel.aspx)
* [TeamViewer](https://www.teamviewer.com/en/download/portal/linux/)
* [AnyDesk](https://rpm.anydesk.com/howto.html)
* [Angry IP Scanner](https://angryip.org/download/#linux)

<code>sudo dnf install brave falkon bleachbit gimp brasero krita mesa-demos obs-studio mc bc vim vim-default-editor w3m featherpad htop psmisc putty setserial screen putty nmap net-tools cifs-utils libsmbclient gvfs-smb qlipper gnome-disk-utility doublecmd-qt meld gtkhash vim-gtk3 lm_sensors cpu-x synapse ffmpeg vlc simplescreenrecorder filezilla remmina audacity pinta ark kdenlive gimp libreoffice libreoffice-draw nomacs qalculate-qt calibre transmission-qt uget inxi hplip gvfs-gphoto2 gphoto2 borgbackup pipx</code>
<p></p>

* Use AppImages of `localsend` and `handbrake`
* `curtail` - from Flatpak or source

*🕒 Last updated on 15.07.2026 at 17:44*

---

## NixOS KDE ❄️

NixOS packages are defined in the `configuration.nix` file located at `sus-stuff/nixos/hp840g2` under `user` and `environment`.

* Enable AppImages: https://wiki.nixos.org/wiki/Appimage

*🕒 Last updated on 07.03.2026 at 21:30*

---

## Arch Linux LXQt

### Base OS

<code>sudo pacman -S --needed networkmanager nm-connection-editor network-manager-applet blueman bluez bluez-obex unzip gvfs-smb gvfs-mtp gvfs-gphoto2 glib2 earlyoom systembus-notify geoclue terminus-font less fuse3 ntfs-3g dosfstools exfatprogs ntfsprogs kwallet5 kwalletmanager hplip xorg-xset</code>
<p></p>

### Userspace

<code>sudo pacman -S --needed ark arj lrzip unrar unarchiver 7zip lzop chromium w3m uget thunderbird doublecmd-qt6 transmission-qt obs-studio kdenlive handbrake audacity bleachbit easyeffects calf lsp-plugins-lv2 zam-plugins-lv2 mda.lv2 filezilla gimp mc bc putty copyq redshift vlc vlc-plugin-ffmpeg remmina nmap net-tools gnome-disk-utility elisa htop psmisc libreoffice-fresh qalculate-qt krita meld luanti vim mesa-demos fastfetch kcharselect noto-fonts-emoji qrca w3m freerdp spice-gtk libvncserver</code>
<p></p>

* Get `calibre` as an AppImage.

*🕒 Last updated on 15.07.2026 at 17:43*

---

## AppImages for "missing-out" distros

* [Calibre](https://github.com/ivan-hc/Calibre-appimage)
* [HandBrake](https://github.com/ivan-hc/Handbrake-appimage)
* [LocalSend](https://localsend.org/download)
* [OnlyOffice](https://appimage.github.io/ONLYOFFICE/)
* [Pinta](https://github.com/pkgforge-dev/Pinta-AppImage)
* [Ventoy](https://github.com/ryuuzaki42/Ventoy_AppImage)
* [WPS Office](https://github.com/ivan-hc/WPS-Office-appimage)
* [AnyDesk](https://github.com/ivan-hc/Anydesk-appimage)

*Find more:*
1. https://pkgforge-dev.github.io/Anylinux-AppImages/
2. https://github.com/ivan-hc#my-appimage-packages

*🕒 Last updated on 15.07.2026 at 17:43*

---

## Windows - Chocolatey



### Fujitsu Lifebook A574

<mark>Note:</mark> I abandoned this notebook in late 2025.

<code>choco install angryip cdburnerxp filezilla gimp libreoffice-fresh openhashtab peazip qbittorrent teamviewer vim vlc git brave nmap tigervnc rufus choco-cleaner localsend.install dvdstyler brave obs-studio thunderbird angryip cdburnerxp crystaldiskinfo.install doublecmd filezilla gimp libreoffice-fresh peazip qbittorrent openhashtab teamviewer anydesk.install choco-cleaner teraterm putty.install vim vlc rufus onlyoffice krita</code>
<p></p>

*🕒 Last updated in May 2025*

### Lenovo V570

<details><summary>48 packages installed.</summary>
<code>Chocolatey v2.7.3
KB2919355 1.0.20160915
KB2919442 1.0.20160915
KB2999226 1.0.20181019
KB3033929 1.0.5
KB3035131 1.0.3
KB4019990 1.0.2
angryip 3.9.3
anydesk 9.7.8
anydesk.portable 9.7.8
aria2 1.37.0
autohotkey 2.0.26
autohotkey.install 2.0.26
autoruns 14.11.0
calibre 9.11.0
cdburnerxp 4.5.8.712800
choco-cleaner 1.1.1
chocolatey 2.7.3
chocolatey-compatibility.extension 1.0.0
chocolatey-core.extension 1.4.0
chocolatey-os-dependency.extension 0.0.1
chocolatey-windowsupdate.extension 1.0.5
crystaldiskinfo 9.9.1
crystaldiskinfo.portable 9.9.1
doublecmd 1.1.32
*filezilla*
ffmpeg-full 8.1.2
gimp 3.2.4
hwinfo 8.28.0
hwinfo.install 8.30.0
localsend.install 1.17.0
malwarebytes 5.6.1.156
nextcloud-client 33.0.7
nmap 7.99.0
openhashtab 3.1.1
*openssl-win64*
peazip 11.1.0
peazip.install 11.1.0
procmon 4.4.0
qbittorrent 5.2.3
rufus 4.15.0
rustdesk.install 1.4.9
thunderbird 152.0.1
tor-browser 15.0.17
vcredist140 14.51.36247
ventoy 1.1.16
victoria 5.37.0
vim 9.2.782
vlc 3.0.23
vlc.install 3.0.23
wireshark 4.6.7
</code>
</details>

*🕒 Last updated on 15.07.2026 at 17:37*

### Atom D525

<details><summary>22 packages installed.</summary>
<code>Chocolatey v2.7.1
aria2 1.37.0
autohotkey 2.0.24
autohotkey.install 2.0.24
chocolatey 2.7.1
chocolatey-compatibility.extension 1.0.0
chocolatey-core.extension 1.4.0
chocolatey-windowsupdate.extension 1.0.5
crystaldiskinfo.portable 9.8.0
KB2919355 1.0.20160915
KB2919442 1.0.20160915
KB2999226 1.0.20181019
KB3033929 1.0.5
KB3035131 1.0.3
nextcloud-client 33.0.2
nextcloud-talk 2.1.1
nmap 7.99.0
qbittorrent 5.1.4
rustdesk 1.4.6.20260324
rustdesk.install 1.4.6.20260324
tor-browser 15.0.10
vcredist140 14.50.35719
vim 9.2.392
</code>
</details>

*🕒 Last updated on 26.04.2026 at 13:37*
