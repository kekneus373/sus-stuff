openwrt ralink rt3070 (rt2800usb) which packages to add to make it work

Based on top community answers, with AI-enhanced clarity

1  Source  under  [CC BY-SA 4.0 or earlier](https://creativecommons.org/licenses/by-sa/4.0/)

![Stack Exchange](https://stackoverflow.com/Content/Sites/stackexchange/Img/icon-16.png)Stack Exchange9 years ago

[1](https://elementaryos.stackexchange.com/questions/11815/ralink-rt3070-driver-problem)[Ralink RT3070 driver problem](https://elementaryos.stackexchange.com/questions/11815/ralink-rt3070-driver-problem)

I'm trying to get my Alfa Networks WIFI dongle (based on RT3070) to work, but it seems that the necessary package (firmware-ralink) is not availabe in elementary os. It is in the non-free debian repo…
](https://elementaryos.stackexchange.com/users/2818/nodflindors)

[nodFlindors](https://elementaryos.stackexchange.com/users/2818/nodflindors)

-   23

1

### Recommended packages for Ralink RT3070 (rt2800usb) on OpenWrt

> the output of iwlist scan
> 
> bash
> 
> `...
> configuration: broadcast=yes driver=rt2800usb driverversion=4.4.0-77-generic firmware=0.29 link=no multicast=yes wireless=IEEE 802.11bgn
> ...` 
> 
> This shows the USB device using the  **rt2800usb**  driver and that it requires firmware (the kernel reports a firmware version).

[[1]](https://unix.stackexchange.com/questions/11815/ralink-rt3070-driver-problem)

> The quote above demonstrates the device mapping to the rt2800usb driver and that a Ralink firmware package (commonly named  **firmware-ralink**) is used on Debian/Ubuntu systems. On OpenWrt the kernel module and firmware are split into packages you must install.

One-sentence summary: install the rt2800 USB kernel module packages plus the Ralink firmware and the user-space Wi‑Fi tools.

----------

### Packages to install (OpenWrt)

-   **kmod-rt2800-usb**  — USB frontend kernel module for rt2800-based devices (this is the main module for RT3070).
-   **kmod-rt2800-lib**  — support library used by rt2800 modules (sometimes included as dependency).
-   **kmod-rt2x00-usb**  /  **kmod-rt2x00-lib**  — lower-level rt2x00 stack helpers (may be pulled in automatically).
-   **firmware-ralink**  — firmware blobs required by RT3070/RT2870 family (if available for your OpenWrt target).
-   **wpad**  or  **wpad-mini**  — WPA supplicant for connecting as client / hosting AP with WPA/WPA2.
-   **wireless-tools**  (optional) — legacy tools like ifconfig/iwconfig; mostly you’ll use  `iw`  / UCI/iwinfo on OpenWrt.
-   **luci**  /  **luci-proto-wireless**  (optional) — web UI support if you want to configure via LuCI.

----------

### Example commands

-   Update package lists and install the driver + firmware:

sh

`opkg update
opkg install kmod-rt2800-usb firmware-ralink wpad luci` 

-   Reboot or reload modules:

sh

`reboot
# or remove/load module
rmmod rt2800usb && modprobe rt2800usb` 

-   Check kernel log / device:

sh

`logread | grep -i rt2800
dmesg | grep -i firmware
iw dev
ip link` 

----------

### Tips & Alternatives

-   If  `firmware-ralink`  is not in your OpenWrt feeds for that target, check the official snapshots or the package repository matching your OpenWrt release. Installing mismatched firmware can fail — use the package built for your architecture.
-   On older OpenWrt releases the package names may vary slightly (look for  `rt2800`  or  `rt2x00`  in opkg search).
-   If you only need AP mode and limited features,  `wpad-mini`  saves space; for full WPA2/enterprise support use  `wpad`.

----------

If you tell me your OpenWrt release (e.g., 21.02, 22.03, or snapshot) and device architecture (e.g., mipsel_24kc, armvirt), I can give the exact opkg package names/URLs and verify whether  `firmware-ralink`  is available for your target.

More from the community

-   ![](https://stackoverflow.com/Content/Sites/stackexchange/Img/icon-16.png)[Ralink RT3070 driver problem](https://elementaryos.stackexchange.com/questions/11815/ralink-rt3070-driver-problem/11826#11826)


> Written with [StackEdit](https://stackedit.io/).
