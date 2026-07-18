Here is a step-by-step guide to compiling your own firmware with OpenWrt using the Image Builder:

---

# Guide: Compiling Custom Firmware with OpenWrt Image Builder

## What is the Image Builder? The Image Builder (formerly known as Image Generator) is a pre-compiled tool that allows you to create custom firmware images without having to compile from source code. Download the packages directly from the official OpenWrt repositories.

---

## Prerequisites

### Operating System - Linux (recommended: Ubuntu, Debian, or similar) - Also works on WSL2 on Windows

### Required dependencies Install the dependencies on your system:

```bash sudo apt update sudo apt install -y build-essential libncurses5-dev libncursesw5-dev \ zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python3 ```

---

## Step 1: Download the Image Builder

1. Go to the official OpenWrt download page:

 👉 https://downloads.openwrt.org
2. Navigate to the version and architecture of your router, for example:

 ```
 releases/23.05.0/targets/ath79/generic/
 ```
3. Download the `openwrt-imagebuilder-*.tar.xz` file:

```bash wget https://downloads.openwrt.org/releases/23.05.0/targets/ath79/generic/openwrt-imagebuilder-23.05.0-ath79-generic.Linux-x86_64.tar.xz ```

---

## Step 2: Extract the Image Builder

```bash tar -xf openwrt-imagebuilder-*.tar.xz cd openwrt-imagebuilder-*/ ```

## Step 3: Identify your router's profile

Each router has a specific profile. To view the available profiles, run:

```bash make info ```

Look for your device's name in the list. For example: ``` tplink_tl-wr841n-v13 ```

---

## Step 4: Compile the firmware

Use the `make image` command with the corresponding parameters:

```bash make image \

PROFILE="tplink_tl-wr841n-v13" \
PACKAGES="luci luci-ssl nano htop wget curl"
```

### Main parameters

Parameter    Description
---    ---
`PROFILE`	Name of your device's profile
`PACKAGES`    Packages to include (separated by spaces)
`FILES`    Folder containing custom configuration files

### Exclude default packages Add a `-` before the package name to exclude it:

```bash PACKAGES="luci -ppp -kmod-ppp" ```

---

## Step 5: Add custom configurations (optional)

You can include your own configuration files:

```bash mkdir -p files/etc/config

# Example: copy your network configuration cp /path/to/your/config/network files/etc/config/network ```

Then include the folder in the command:

```bash make image \

PROFILE="tplink_tl-wr841n-v13" \
PACKAGES="luci nano" \
FILES="files/"
```

---

## Step 6: Locate the generated firmware

Once the build is complete, the firmware will be located at:

```bash bin/targets/<architecture>/<platform>/ ```

Look for the file with the `.bin` or `.img` extension corresponding to your device: 

``` openwrt-23.05.0-ath79-generic-tplink_tl-wr841n-v13-squashfs-factory.bin ← new installation openwrt-23.05.0-ath79-generic-tplink_tl-wr841n-v13-squashfs-sysupgrade.bin ← upgrade ```

---

## Step 7: Flash the firmware

- New installation: use the `factory.bin` file from the original router firmware’s web interface. - Upgrade from OpenWrt: use the `sysupgrade.bin` file from LuCI or with the command:

```bash sysupgrade -v /tmp/openwrt-*-sysupgrade.bin ```

---

## Important tips

- ⚠️ Verify that the profile exactly matches your hardware model and version. - 💾 Back up your current configuration before flashing. - 🔁 If the process fails due to insufficient space in the firmware, remove non-essential packages. - 🌐 You need an internet connection during the build to download the packages.

---

Have you already identified your router model, or do you need help finding the correct profile?

Translated with DeepL.com (free version)
Translated with DeepL.com (free version)
Translated with DeepL.com (free version)