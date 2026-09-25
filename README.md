Everything collection 📚
========================

This repository contains modular configurations for various platforms and applications. Each folder includes platform-specific settings, logs, and scripts tailored to target environments.

## License & Contributions
- **Unlicense** unless explicitly stated otherwise
- **Contributions:** Fork, contribute via PRs or GitHub Issues. Test thoroughly!

<mark>⚠️ Most guides were moved to my Gists:</mark> **https://gist.github.com/kekneus373**

## **Contents**

### Root folder

| Path                             | Description                                                                                 |
|----------------------------------|---------------------------------------------------------------------------------------------|
| `Templates.zip`                  | Shared templates of empty LibreOffice documents.                                            |
| **`applications-list.md`**       | List of my most-used applications with brief descriptions. Prolly the most useful one here. |
| `avahi-investigation.md`         | Correct Avahi mDNS Daemon setup.                                                            |
| `dd.txt`                         | Simple DiskDestroyer one-liner 💀🥀.                                                        |
| `default-cifs.conf`              | Default CIFS mount options on NixOS 25.11.                                                  |
| `docker-ubuntu.md`               | How to install Docker CLI on Ubuntu Server.                                                 |
| `emoji.txt`                      | Most-used emojis so I don't need an external picker.                                        |
| `mount-netgear.txt`              | 2 commands for mounting NetGear ReadyNAS Duo drives under NixOS in 2 minutes.              |
| `murmur.ini`                     | Last used Mumble server config (2024).                                                      |
| `pbs-calendar.md`                | Good backup retention setup for Proxmox Backup Server.                                |
| `pcspkr-chat.md`                 | ChatGPT about enabling PC speaker/buzzer in Debian.                                         |
| `prs-plus-advice.txt`            | Should you flash your Sony E-Book Reader to PRS+ custom ROM?                            |
| `remmina-snap.txt`               | Standard message from Remmina snap about giving it access to I/O devices (2024).          |
| `remove-xfce-install-lxqt.odt`   | ChatGPT guide on how to switch to LXQt w/o reinstalling.                          |
| `truenas-experiments.txt`        | Steps I've taken while setting up TrueNAS SCALE in 2025 while migrating from NAS4Free.    |
| `zswap-case-study.txt`           | Finding out why my main machine is slow as hell 🗿.                                         |

### 📂 Platform-Specific Folders

#### 📱 Android
- 🛠️ Ongoing hobbyist project of reflashing smartphones and tablets. Started in 🕒 Mid 2025
- 📚 Includes discovered guides, links to ROMs and recovery sources (soon)
- 🔐 Details on maintaining older Android version yourself (like refreshing certificates)

#### 💻 `acer-e3-112` Linux Environment
- 🐞 Core development/debugging scripts for my buggy Acer Aspire E3-112 notebook.
- ❄️ Intel Bay Trail hangs and freezes checklist (`chat-baytrail-git.md`)
- 📜 Logs capture raw system events (e.g., `suspend-wakeup-in-loop-git.log`, `firstfreeze-or-oomd.log`).
- 🐧 Arch Linux *LXQt*
	- 📂 Entire `/etc` dir + dotfiles to help others get started
	- ⚡ Scripts for optimizing workflow for those who are low on RAM and can't "afford" a sane DE 😅
 
#### 📂 Archive
- 📜 Old (debug) log entries from different hardware
- 🛠️ All files are for reference

#### 📡 OpenWrt - Wireless Freedom
- 🏗️ Getting Started & Build
- 🏠 Core OpenWrt Setup
- 🔑 P2P OpenVPN Tunnel
- 🛠️ Troubleshooting & Recovery

### 🖥️ Desktop/Server Applications

#### 🎙️ Audacity
- 📜 Scripts (e.g., `DeleteClipGaps.ny`)
- 🖼️ Preferred Layout screenshot

#### 🎨 GIMP
- 🖼️ Layout + app settings

#### 🎬 Kdenlive
- 🎭 Theme/effect presets (e.g., `bonkers-chromakey.xml`, `720p-fast-forward.xml`)
- 📽️ Sample project files
- 🏷️ Title samples
- 🎨 Layouts in all formats

#### 🐳 LXC
- 📖 Some configurations guides
- 🤖 AI explanations

#### 📡 vsftpd
- ⚡ Super quick and easy config
- 🛑 Command to temporarily disable SELinux intervention (sucks a lot)

### 🖥️ Operating System Configurations

#### 🍎 Fedora VM
- 📂 Shared folder mount for VM (`9p.bash`)
- 🔧 Shared folder host permissions fix (`fix-permissions-public0.sh`)
- 🕵️ Tor proxy startup (`tor.bash`)
- 🌐 Falkon separate profile startup (`falkonschool.bash`)
- 📦 Installation of the Nix package manager (`df -h` used space comparison, `fedora-nix.md` guide)

#### 🌿 Linux Mint
- 🍂 Didn't use it much, so there are mostly logs from the above mentioned device.

#### 🐺 Fedora
- 📦 Package manager (DNF) settings
- ⚙️ UX configurations (`mpris-proxy.service`, `dconf-editor-flathub-button-layout.md`)
- 🎨 GUI customizations
- ⌨️ Desktop shortcuts w/workarounds (`brave-browser.desktop`)

#### 🐧 NixOS
- 🚀 Deployment configurations
- 🔌 Hardware quirks
- 🖥️ QEMU setup

### 🛠️ Utilities & Monitoring

#### ⏱️ Uptimes
- 📊 Historical metrics for performance tracking of servers (e.g., `410/2026.txt`).
- 🤖 Tips on automation (`sysstat-sar.md`).

## 🚀 How to Use

1. 🎯 **Target a Platform**: Navigate to the corresponding folder (e.g., `/arch` for Arch Linux).
2. 📂 **Access Logs, Scripts and Configurations**: Check relevant files for debugging and so on.

> Written with [StackEdit](https://stackedit.io/).
