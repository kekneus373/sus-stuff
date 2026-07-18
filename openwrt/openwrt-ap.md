access point setup openwrt
=========================

To set up OpenWrt as a wired Access Point (AP), **flash the OpenWrt firmware** to a compatible router, then configure the **LAN interface** to use a **static IP** within your main router’s subnet (outside the DHCP range) and set the **gateway/DNS** to the main router’s IP.

**Key Configuration Steps:**

*   **Disable DHCP:** In **Network > Interfaces**, edit the LAN interface, go to the **DHCP Server** tab, and check **Ignore interface** to prevent IP conflicts with the main router.
*   **Configure Wireless:** In **Network > Wireless**, edit the radio interface, set **Mode** to **Access Point**, assign a unique **SSID**, and select **WPA2-PSK** or **WPA3** encryption with a strong password.
*   **Bridge Network:** Ensure the wireless interface’s **Network** setting is linked to **LAN** so wireless clients are bridged to the wired network.
*   **Physical Connection:** Connect the main router to one of the OpenWrt device’s **LAN ports** (do not use the WAN port) to complete the dumb AP setup.

For wireless backhaul (connecting via Wi-Fi instead of Ethernet), enable **AP+STA** mode, which requires specific chipsets and manual configuration of `mac80211` interfaces to allow simultaneous station and access point functionality.

---

## Set Wi-Fi Schedule

<mark>*openwrt wifi timer*</mark>

To schedule Wi-Fi on/off times in OpenWrt, you can use the **luci-app-wifischedule** package for a GUI-based approach or **cron jobs** for manual configuration.

### Option 1: luci-app-wifischedule (Recommended)
This package provides a LuCI interface to manage schedules for specific SSIDs or radios.
1. Install the package: `opkg install luci-app-wifischedule`
2. Configure schedules in **Services > WiFi Schedule**.
3. The backend script (`wifi_schedule.sh`) automatically handles cron job creation and module unloading if needed.

### Option 2: Manual Cron Jobs
For simple daily schedules, add entries to the root crontab using `crontab -e`.

**To disable/enable specific SSIDs:**
```bash
# Disable SSID at 22:00, Enable at 08:00
0 22 * * * uci set wireless.wifinet2.disabled='1' && uci commit wireless && wifi reload
0 8 * * * uci set wireless.wifinet2.disabled='0' && uci commit wireless && wifi reload
```

```bash
# Turn off WiFi at 16:00, Turn on at 08:00
0 16 * * 1-5 uci set wireless.default_radio0.disabled='1' && uci commit wireless && wifi reload > /dev/null 2>&1
0 8 * * 1-5 uci set wireless.default_radio0.disabled='0' && uci commit wireless && wifi reload >/dev/null 2>&1
```

**To disable/enable all WiFi interfaces:**
```bash
# Turn off all WiFi at 23:00, Turn on at 07:00
0 23 * * * wifi down >/dev/null 2>&1
0 7 * * * wifi up >/dev/null 2>&1
```

For device-specific restrictions (e.g., blocking a child's device at night), use **Firewall Rules** with time restrictions (`start_time`/`stop_time`) rather than toggling the radio.

```
_“At  16:00  on every day-of-week from Monday through Friday.”_

0 16 * * 1-5

_“At  08:00  on every day-of-week from Monday through Friday.”_

0 8 * * 1-5
```

<mark>`sudo screen /dev/ttyUSB0 115200`</mark>

<mark>iana org reserved ips</mark>

The **IANA** (Internet Assigned Numbers Authority) and **IETF** reserve specific IPv4 address blocks for special purposes, defined in the **IPv4 Special-Purpose Address Space** registry. These addresses are generally **not globally routable** on the public internet and are designated for private, local, or documentation use.

Key reserved IPv4 blocks include:

*   **0.0.0.0/8**: "This network" – used for self-identification on the local network.
*   **10.0.0.0/8**: **Private-Use** – for local communications within private networks (RFC 1918).
*   **100.64.0.0/10**: **Shared Address Space** – for carrier-grade NAT communications between service providers and subscribers (RFC 6598).
*   **127.0.0.0/8**: **Loopback** – for local host communication (localhost).
*   **169.254.0.0/16**: **Link Local** – for automatic IP assignment when no DHCP server is available.
*   **172.16.0.0/12**: **Private-Use** – for local communications within private networks (RFC 1918).
*   **192.0.0.0/24**: **IETF Protocol Assignments** – for protocol assignments and DS-Lite.
*   **192.0.2.0/24**: **TEST-NET-1** – reserved for documentation and examples.
*   **192.168.0.0/16**: **Private-Use** – for local communications within private networks (RFC 1918).
*   **198.18.0.0/15**: **Benchmarking** – for testing inter-network communications.
*   **198.51.100.0/24**: **TEST-NET-2** – reserved for documentation and examples.
*   **203.0.113.0/24**: **TEST-NET-3** – reserved for documentation and examples.
*   **240.0.0.0/4**: **Reserved** – formerly Class E, reserved for future use.
*   **255.255.255.255/32**: **Limited Broadcast** – for local subnet broadcast.

For the most authoritative and up-to-date registry details, IANA provides the **IANA IPv4 Special-Purpose Address Registry** and the **IPv4 Address Space** allocation tables.


> Written with [StackEdit](https://stackedit.io/).
