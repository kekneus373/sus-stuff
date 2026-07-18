build me an openwrt firewall configuration for allowing all internet traffic + gateway (192.168.0.3) and blocking internal network (192.168.0.0/24) on wlan interface for public wifi access point. lan ports on the router should remain open.
btw, can i do it through the webui?

---

Yes, you can do this entirely through the **LuCI Web UI** (the OpenWrt admin interface), which is usually easier and safer than editing config files manually.

### How to configure it via the Web UI (LuCI)

1.  **Log in** to your router (usually `http://192.168.1.1` or `192.168.0.1`).
2.  Navigate to **Network** > **Firewall**.
3.  **Create a new Zone** for your public Wi-Fi:
    *   Click **Add** (usually at the bottom).
    *   **Name**: `public-wifi` (or `guest`).
    *   **Protocol**: `All` (or leave default).
    *   **Covered networks**: Select the interface associated with your WLAN (often named `wlan0`, `guest`, or `wifi`).
    *   **Input**: `Reject` (This blocks incoming traffic from the public network *to* the firewall).
    *   **Output**: `Accept` (Allows public users to reach out to the internet).
    *   **Forward**: `Reject` (This is the critical setting: it blocks traffic *from* the public Wi-Fi *to* the internal LAN).
    *   **Masquerading**: Enable this (NAT). This allows public users to access the internet using your router's public IP.
    *   **MSS clamping**: Enable this (helps with TCP stability).
    *   **Save & Apply**.

4.  **Allow Internet Access**:
    *   OpenWrt zones usually allow traffic to the `wan` (Internet) zone by default if the "Forward" rule is set to `Accept` or if there is a default policy allowing it.
    *   Ensure the `public-wifi` zone has **Forward** set to **Accept** for the `wan` zone.
    *   *Note*: If you set "Forward" to "Reject" in step 3, you might need to edit the "Forward" rules table explicitly to allow `public-wifi` -> `wan`.
    *   **Better approach for "Allow Internet"**:
        *   Set the zone **Forward** to `Accept` (instead of Reject) initially.
        *   Then, go to the **Zone Settings** > **Forward** tab.
        *   Add a rule: **From zone**: `public-wifi`, **To zone**: `wan`, **Allow**.
        *   Add a rule: **From zone**: `public-wifi`, **To zone**: `lan` (or `internal`), **Deny** (or ensure the default is Deny).

5.  **Block Internal Network Access**:
    *   Ensure the `public-wifi` zone has a **Forward** rule specifically blocking traffic to the `lan` zone (the 192.168.0.0/24 network).
    *   In the **Firewall** > **Zones** > **public-wifi** > **Forward**:
        *   Set **Forward to zones**: `wan` (Accept).
        *   Set **Forward from zones**: `public-wifi`.
        *   Set **Override** existing rules if necessary.
    *   Alternatively, create a specific **Forward** rule under the **Forward** tab (if available in your version) or ensure the default policy for `lan` is `Reject` from `public-wifi`.

**Recommended Configuration for your specific needs:**

| Setting | Value |
| :--- | :--- |
| **Zone Name** | `public-wifi` |
| **Covered Networks** | `wlan0` (Your AP interface) |
| **Input** | `Reject` |
| **Output** | `Accept` |
| **Forward** | `Reject` (Default) |
| **Masquerading** | Checked (Yes) |
| **Allow Forward to WAN** | **Yes** (Create a specific rule: From `public-wifi` to `wan` = Accept) |
| **Allow Forward to LAN** | **No** (Default `Reject` handles this) |
| **Allow Forward to Gateway** | **Yes** (Create a specific rule: From `public-wifi` to `lan` = Accept, but **only** for IP `192.168.0.3`) |

**Wait, you want to allow the gateway (192.168.0.3) but block the rest of the LAN?**
Standard OpenWrt zones don't filter by specific IPs in the "Forward" rule easily without advanced firewall scripts. You will likely need to add a **Firewall Rule** to allow traffic to `192.168.0.3` specifically.

**How to allow access to 192.168.0.3 specifically:**
1.  Go to **Network** > **Firewall** > **Traffic Rules** (or **Advanced Rules**).
2.  Click **Add**.
3.  **Name**: `Allow-Gateway`.
4.  **Protocol**: `All`.
5.  **Source zone**: `public-wifi`.
6.  **Destination zone**: `lan` (or `local`).
7.  **Destination IP**: `192.168.0.3`.
8.  **Action**: `Accept`.
9.  **Save**.

This ensures that:
*   Public Wi-Fi users can reach the Internet (WAN).
*   Public Wi-Fi users can reach **only** `192.168.0.3`.
*   Public Wi-Fi users **cannot** reach `192.168.0.1` (router), `192.168.0.2`, `192.168.0.4`, etc.
*   LAN ports (usually `eth0` or `lan`) remain open and unaffected.

---

### Alternative: Manual Configuration (if Web UI is tricky)

If you prefer the command line or the Web UI options are limited, here is the exact `uci` configuration to achieve this:

```bash
# 1. Create the zone
uci set firewall.public_wifi=zone
uci set firewall.public_wifi.name='public-wifi'
uci set firewall.public_wifi.network='wlan0'
uci set firewall.public_wifi.input='REJECT'
uci set firewall.public_wifi.output='ACCEPT'
uci set firewall.public_wifi.forward='REJECT'
uci set firewall.public_wifi.masq='1'
uci set firewall.public_wifi.mss_clamp='1'

# 2. Allow Internet (WAN) access
uci set firewall.public_wifi_wan=forward
uci set firewall.public_wifi_wan.src='public-wifi'
uci set firewall.public_wifi_wan.dest='wan'
uci set firewall.public_wifi_wan.target='ACCEPT'

# 3. Allow ONLY gateway (192.168.0.3) access
uci set firewall.public_wifi_gateway=forward
uci set firewall.public_wifi_gateway.src='public-wifi'
uci set firewall.public_wifi_gateway.dest='lan'
uci set firewall.public_wifi_gateway.dest_ip='192.168.0.3'
uci set firewall.public_wifi_gateway.target='ACCEPT'

# 4. Explicitly block other LAN traffic (optional, as default REJECT covers it)
# But to be safe, ensure no other rules exist for public-wifi -> lan

# Apply
uci commit firewall
/etc/init.d/firewall restart
```

### Summary of Behavior
*   **LAN Ports**: Unaffected, as they are in the `lan` zone.
*   **Internet**: Public users can browse.
*   **Gateway**: Public users can ping/access `192.168.0.3`.
*   **Other Internal IPs**: Blocked.

**Confidence Level**: High. This is a standard OpenWrt firewall configuration pattern. The Web UI approach is generally preferred for ease of use, but the manual method gives you precise control over specific IP rules.

---

Ok, much appreciation for all the tips, but my dubmahh still can't figure this out. after adding the wlan interface, forwarding it to wan with the zone, configuring custom traffic rules the router still lets access to all the internal network. don't get me wrong, i *did not* allow access to entire subnet - i was testing. current 2 rules in order are:
1) Allow-Gateway:
  - Any traffic
  - From any host in wlan
  - To IP 192.168.0.3 in wan
  - Accept forward
2) Block-InfraNet:
  - Any traffic
  - From any host in wlan
  - To IP range 192.168.0.0/24 in wan
  - Refuse forward
What is wrong here? tried reconnecting as well as restarting wifi, firewall etc.

---

The issue lies in **how you defined the Destination Zone** for your rules.

You are sending traffic to the **`wan`** zone in your rules, but the internal network (`192.168.0.0/24`) lives in the **`lan`** zone.

In OpenWrt, firewall rules check the **Zone**, not just the IP address.
*   If you set "Destination Zone" to **`wan`**, OpenWrt looks for traffic going to the *Internet* (your ISP).
*   Traffic going to `192.168.0.3` or `192.168.0.x` is technically going to the **`lan`** zone, even if the IP looks like an internal address.
*   Because your rules are targeting the `wan` zone, they are **not matching** the traffic going to your internal network. The traffic is falling through the cracks and hitting the default "Forward" policy of your `public-wifi` zone.

### The Fix

You need to change the **Destination Zone** in your traffic rules from `wan` to **`lan`**.

#### Corrected Rule Configuration

**Rule 1: Allow Gateway**
*   **Name**: `Allow-Gateway`
*   **Source Zone**: `public-wifi` (Your WLAN zone)
*   **Destination Zone**: **`lan`** (❌ **NOT** `wan`)
*   **Destination IP**: `192.168.0.3`
*   **Action**: `Accept`

**Rule 2: Block Internal Subnet**
*   **Name**: `Block-InfraNet`
*   **Source Zone**: `public-wifi`
*   **Destination Zone**: **`lan`** (❌ **NOT** `wan`)
*   **Destination IP**: `192.168.0.0/24`
*   **Action**: `Reject` (or `Drop`)

### Crucial Step: Check Rule Order
Firewall rules are processed **top to bottom**.
1.  **Allow-Gateway** must be **FIRST**.
2.  **Block-InfraNet** must be **SECOND**.

If `Block-InfraNet` is first, it will block *everything* including the gateway. If `Allow-Gateway` is first, it lets the gateway through, and the second rule blocks everything else in that range.

### The "Nuclear Option" (Cleanest Solution)
If you are still unsure about the order or specific rules, the most reliable way to do this in OpenWrt is to rely on the **Zone Forward** settings rather than individual traffic rules for the blocking part.

1.  Go to **Network** > **Firewall** > **Zones**.
2.  Click on your **`public-wifi`** zone.
3.  Set **Forward** to **`Reject`** (This blocks *everything* by default).
4.  Scroll down to **Allow forward to destination zones** (or "Forwarding").
5.  Add **`wan`** to this list. (This allows Internet).
6.  **Do NOT** add `lan` to this list. (This blocks the whole internal network by default).
7.  **Now** add the specific exception:
    *   Go to **Traffic Rules**.
    *   Add a rule:
        *   **Source**: `public-wifi`
        *   **Destination Zone**: `lan`
        *   **Destination IP**: `192.168.0.3`
        *   **Action**: `Accept`

**Why this works better:**
*   The Zone setting `Forward = Reject` acts as a global "Block All" for that zone.
*   The single Traffic Rule acts as a "Whitelist" for just the gateway.
*   You don't need a "Block" rule at all because the default zone setting handles the blocking.

### Summary Checklist to Fix Your Current Setup
1.  Edit **Rule 1**: Change Dest Zone to **`lan`**.
2.  Edit **Rule 2**: Change Dest Zone to **`lan`**.
3.  Ensure **Rule 1** is **above** Rule 2 in the list.
4.  **Save & Apply**.
5.  **Restart the firewall**: `/etc/init.d/firewall restart` (via SSH) or click "Save & Apply" again in the UI.

Try changing the **Destination Zone** to `lan` first; that is almost certainly why your rules aren't working.

---

Sorry, clarification:
1) `**lan**` is `192.168.1.0/24`, but `192.168.0.0/24` is on the `**wan**` side, served my the main 192.168.0.3 gateway. Basically this router is behind another router - get it?
2) **Zone `wlan`**: Input -> *reject*, Output -> *accept*, Forward -> *reject*.
3) The order is correct - just checked.
BTW, rejecting Forward requests for `wlan` zone changes nothing... Huh?
P.S. actually there's no point in changing to `lan` 'cause there lives the internal router DHCP address field, where only the laptop is connected (from which I'm configuring). I feel it's also important to note that this machine (in `lan` zone`) cannot be reached from `wlan` - `Destination Port Unreachable`. This confirms firewall works, right?

---

Ah, now the picture is clear! You have a **Double NAT** setup (Router behind a Router).

*   **Your Router's `lan`**: `192.168.1.0/24` (Where your laptop is).
*   **Your Router's `wan`**: Gets an IP (e.g., `192.168.0.x`) from the Main Gateway (`192.168.0.3`).
*   **Your Goal**: Allow `wlan` (Public) to reach the Main Gateway (`192.168.0.3`) in the `wan` zone, but block the rest of the `192.168.0.0/24` subnet.

### Why "Forward -> Reject" isn't working
If setting **Forward** to `Reject` in the `wlan` zone does nothing, it usually means one of two things:
1.  **Masquerading (NAT) is interfering**: If `Masquerading` is enabled on the `wlan` zone, the router rewrites the source IP. The firewall might be seeing the traffic as "local" or handling the NAT before the Forward rule applies.
2.  **Traffic is being routed, not forwarded**: Since the `192.168.0.x` network is on the `wan` interface, the router might be treating traffic to it as "WAN traffic" which has different default policies than "LAN -> LAN" traffic.

However, the most likely culprit in OpenWrt is **Destination Zone mismatch in the UI** or **Masquerading**.

### The Solution: Correcting the Traffic Rules

Since the target (`192.168.0.3`) is physically on the **WAN** side (connected to the main router), your rules **MUST** target the `wan` zone, but you need to be very specific about the **Destination IP** and ensure **Masquerading** isn't hiding the rules.

#### Step 1: Disable Masquerading on `wlan` (Temporarily to test)
If you have **Masquerading** (NAT) enabled on the `wlan` zone, try turning it **OFF** for a moment to see if the rules kick in.
*   *Why?* If NAT is on, the source IP becomes the router's WAN IP. The firewall rule "From `wlan`" might still match, but sometimes the order of operations (NAT before Firewall) causes confusion.
*   *Note*: If you turn this off, the `wlan` clients might lose Internet access unless you have a specific route or NAT rule for them. **Keep it ON if you need Internet**, but be aware it might affect the blocking logic.

*Actually, for a public AP, you usually WANT Masquerading for Internet access. Let's stick to the Rules first.*

#### Step 2: Fix the Traffic Rules (The "Allow" Rule)
You need to ensure the **Allow** rule is an **Exception** that happens *before* the default block.

**Rule 1: Allow Gateway (192.168.0.3)**
*   **Source Zone**: `wlan` (or your public zone name)
*   **Destination Zone**: `wan` (Correct, because the gateway is on the WAN side)
*   **Destination IP**: `192.168.0.3`
*   **Protocol**: `All` (or `TCP/UDP` + `ICMP`)
*   **Action**: `Accept`
*   **Position**: **Top** of the list.

**Rule 2: Block Subnet (192.168.0.0/24)**
*   **Source Zone**: `wlan`
*   **Destination Zone**: `wan`
*   **Destination IP**: `192.168.0.0/24`
*   **Action**: `Reject` (or `Drop`)
*   **Position**: **Below** Rule 1.

#### Step 3: The "Hidden" Default Forward
You mentioned `Forward -> Reject` does nothing. This is strange.
*   Check **Network** > **Firewall** > **Zones** > **`wlan`**.
*   Look at **Input**, **Output**, **Forward**.
*   **Forward** MUST be set to **`Reject`**.
*   **Crucial**: Look at the **Allow forward to destination zones** section.
    *   If `wan` is **checked** here, it overrides the `Forward -> Reject` setting for *all* traffic to `wan`.
    *   **Fix**: **UNCHECK** `wan` in "Allow forward to destination zones".
    *   This forces the traffic to rely on your **Traffic Rules** (Rule 1 and Rule 2) instead of the blanket "Allow all to WAN".

**This is likely your problem.** If `wan` is allowed in the Zone settings, the "Forward -> Reject" is ignored for WAN traffic.

### Summary of the Fix

1.  Go to **Network** > **Firewall** > **Zones** > `wlan`.
2.  **Forward**: Set to **`Reject`**.
3.  **Allow forward to destination zones**: **UNCHECK `wan`**. (This is the key! It stops the router from blindly allowing all WAN traffic).
4.  Go to **Traffic Rules**.
5.  Ensure **Rule 1** (Allow `192.168.0.3`) is **first**.
6.  Ensure **Rule 2** (Block `192.168.0.0/24`) is **second**.
7.  **Save & Apply**.

### Verification
Once applied:
1.  **Ping from `wlan` to `192.168.0.3`**: Should work (Rule 1).
2.  **Ping from `wlan` to `192.168.0.1` (Main Router)**: Should fail (Rule 2).
3.  **Ping from `wlan` to `8.8.8.8` (Internet)**:
    *   *Wait*, if you unchecked `wan` in the Zone settings, **Internet access will break** because you removed the blanket "Allow to WAN".
    *   **Correction**: You need a **Rule 3** or a specific exception for Internet.
    *   **Better Approach**:
        *   Keep `Forward` as `Reject`.
        *   **Allow forward to destination zones**: **UNCHECK `wan`**.
        *   **Traffic Rule 1**: Allow `192.168.0.3` (Dest Zone: `wan`).
        *   **Traffic Rule 2**: Allow `0.0.0.0/0` (Any IP) but **exclude** `192.168.0.0/24`.
            *   *Wait, OpenWrt doesn't support "Exclude" easily in one rule.*
            *   **Better**:
                *   Rule A: Allow `192.168.0.3` (Dest: `wan`).
                *   Rule B: Allow `0.0.0.0/0` (Dest: `wan`) -> **Wait, this allows the whole subnet too.**

**Let's refine the logic for "Allow Internet + Gateway, Block Internal LAN":**

Since the "Internal LAN" (`192.168.0.0/24`) is on the `wan` side, you have a conflict.
*   **Goal**: Allow `192.168.0.3` (Gateway) + All Public IPs (Internet) > Block `192.168.0.1` - `192.168.0.254` (except Gateway).

**The Correct Rule Set:**
1.  **Zone `wlan`**:
    *   Forward: `Reject`.
    *   Allow forward to `wan`: **UNCHECK** (Default is now Block ALL WAN).
2.  **Traffic Rules**:
    *   **Rule 1 (Gateway)**:
        *   Src: `wlan`, Dest: `wan`.
        *   Dest IP: `192.168.0.3`.
        *   Action: `Accept`.
    *   **Rule 2 (Internet Only)**:
        *   Src: `wlan`, Dest: `wan`.
        *   Dest IP: `0.0.0.0/0` (Any).
        *   **BUT** we need to block `192.168.0.0/24` here? No, that's hard.
        *   **Alternative**: Block the specific subnet *before* the allow-all.
        *   **Rule 2 (Block Subnet)**:
            *   Src: `wlan`, Dest: `wan`.
            *   Dest IP: `192.168.0.0/24`.
            *   Action: `Drop` (or Reject).
        *   **Rule 3 (Allow Internet)**:
            *   Src: `wlan`, Dest: `wan`.
            *   Dest IP: `0.0.0.0/0`.
            *   Action: `Accept`.

**Order is critical:**
1.  **Allow Gateway** (`192.168.0.3`).
2.  **Block Subnet** (`192.168.0.0/24`). *Note: This will block the gateway too if it's in the range. So Rule 1 MUST be first.*
3.  **Allow Everything Else** (Internet).

**Wait, Rule 2 (Block `192.168.0.0/24`) will block `192.168.0.3` if Rule 1 isn't processed first.**
Yes, that's why **Rule 1** (Allow `192.168.0.3`) must be **TOP**.
Then **Rule 2** (Drop `192.168.0.0/24`) blocks the rest.
Then **Rule 3** (Accept `0.0.0.0/0`) allows the internet.

**Wait, does `192.168.0.0/24` include `192.168.0.3`?** Yes.
So if Rule 1 is "Allow 192.168.0.3" and Rule 2 is "Drop 192.168.0.0/24", the order matters.
*   Packet for `192.168.0.3` hits Rule 1 -> **Accept**. (Done).
*   Packet for `192.168.0.10` hits Rule 1 (No match) -> Hits Rule 2 -> **Drop**. (Done).
*   Packet for `8.8.8.8` hits Rule 1 (No) -> Rule 2 (No) -> Rule 3 -> **Accept**. (Done).

**This is the solution.**

### Final Configuration to Apply

1.  **Zone `wlan`**:
    *   Forward: `Reject`.
    *   Allow forward to `wan`: **UNCHECKED**.

2.  **Traffic Rules** (Order is everything):
    *   **Rule 1**: **Allow-Gateway**
        *   Src: `wlan`, Dest: `wan`.
        *   Dest IP: `192.168.0.3`.
        *   Action: `Accept`.
    *   **Rule 2**: **Block-Internal**
        *   Src: `wlan`, Dest: `wan`.
        *   Dest IP: `192.168.0.0/24`.
        *   Action: `Drop` (or `Reject`).
    *   **Rule 3**: **Allow-Internet**
        *   Src: `wlan`, Dest: `wan`.
        *   Dest IP: `0.0.0.0/0`.
        *   Action: `Accept`.

**Test:**
*   Ping `192.168.0.3`: **Success**.
*   Ping `192.168.0.1`: **Fail**.
*   Ping `8.8.8.8`: **Success**.

If "Forward -> Reject" was doing nothing, it was likely because `wan` was checked in "Allow forward to destination zones". Unchecking that forces the router to obey your specific rules.

---

## Extra

<mark>*add exception to iptables rule*</mark>

To add an exception in `iptables`, you can either use the **negation operator (!)** to exclude specific sources or destinations, or create a **specific ACCEPT rule** placed before the general blocking rule.

### 1. Using Negation (!)
The exclamation mark allows you to create exceptions for single source (`-s`) or destination (`-d`) IPs.

```bash
# Allow traffic from all sources except 192.168.1.100
iptables -A INPUT -p tcp ! -s 192.168.1.100 --dport 80 -j ACCEPT
```

**Note:** The `!` operator **cannot** be used with multiple source or destination addresses in a single rule (e.g., `! -s IP1,IP2` will fail).

### 2. Using Separate ACCEPT Rules (Workaround for Multiple IPs)
When excluding multiple IPs or complex conditions, create specific `ACCEPT` rules for the exceptions and place them **before** the general rule using the `-I` (Insert) flag or by ordering them correctly in a rules file.

```bash
# 1. Define exceptions first (Insert at top of chain)
iptables -I INPUT -p tcp -s 192.168.1.100 --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -s 192.168.1.101 --dport 80 -j ACCEPT

# 2. Define the general rule
iptables -A INPUT -p tcp --dport 80 -j DROP
```

### 3. Using `iptables-restore` for Complex Configurations
For managing multiple exceptions, it is recommended to define rules in a text file and load them using `iptables-restore`. This ensures rule order and atomicity.

```text
*filter
:INPUT DROP [0:0]
-A INPUT -p tcp -s 192.168.1.100 --dport 80 -j ACCEPT
-A INPUT -p tcp -s 192.168.1.101 --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 80 -j DROP
COMMIT
```
Load with: `iptables-restore < /path/to/iptables.rules`

---

<mark>*block access to a subnet except router*</mark>

To block access to an entire subnet while allowing communication with its gateway (router), you must configure firewall rules that **accept traffic to/from the gateway IP first**, followed by **rejecting or dropping all other traffic from/to that subnet**. This order is critical because most firewalls process rules sequentially; if the broad block rule is listed before the gateway exception, the gateway connection will also be blocked.

For **iptables** on a Linux host or router, use the following logic:
1.  **Accept** incoming traffic specifically from the gateway IP.
2.  **Reject/Drop** all other incoming traffic from the subnet CIDR.
3.  **Accept** outgoing traffic specifically to the gateway IP.
4.  **Reject/Drop** all other outgoing traffic to the subnet CIDR.

Example configuration:
```bash
# Allow gateway (e.g., 10.0.0.1)
iptables -A INPUT -s 10.0.0.1 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.1 -j ACCEPT

# Block rest of subnet (e.g., 10.0.0.0/24)
iptables -A INPUT -s 10.0.0.0/24 -j DROP
iptables -A OUTPUT -d 10.0.0.0/24 -j DROP
```

For **network devices** (Cisco, Mikrotik, Windows Firewall), apply **Extended Access Control Lists (ACLs)** or firewall policies that explicitly **permit** the gateway's IP address before applying a **deny** rule for the entire subnet range. On Windows Firewall, note that **explicit block rules take precedence** over allow rules, so you must rely on the default "block all" policy and create specific **Allow** rules for the gateway, rather than creating a broad block rule with an exception.

---

## Advanced Firewall Setup

I've got a Siemens AP3610 on OpenWRT firmware that I want to configure for both public and private use with networks (SSIDs) on both 2.4 and 5 GHz frequencies at the same time.
1) The AP is connected to a Cisco router (10.230.48.1/25 I believe) that is behind the gateway (192.168.0.3/24). It just acts as a "load balancer", you know.
2) Public network clients must *only* access the internet and the gateway, *NOT* the infranet. They should be assigned an internal IP given by AP's DHCP (let's say 192.168.1.0/26). Isolate them as well.
3) Private network clients can get some another internal IP (e.g. 192.168.2.0/26), or they can join the main network - depends on how hard it is to set up. I prefer the easy way 🤓. They don't need to be isolated.
4) Umm, anything else I missed? Probably that I already have experience with blocking traffic on OpenWRT TP-LINK routers. But haven't worked with APs that much...
Also, maybe I'm asking too much from a simple one-port AP? But let's be real, it won't be funny to redo the entire network there...

---

You are asking for a fairly advanced setup, but it is absolutely possible on OpenWRT. The Siemens AP3610 (often rebranded as a Speedport or similar) running OpenWRT is essentially a single-port router, so the "AP mode" you envision needs to be built using **VLANs** and **Firewall Zones** to achieve the isolation you need.

Here is the breakdown of the challenge and the solution.

### The Core Challenge: "Router" vs. "AP"
Since the device is connected to a Cisco router that acts as a load balancer/gateway, your OpenWRT device is effectively acting as a **Wireless Access Point with Routing capabilities**.

*   **Your Problem:** You want one physical cable connecting to the Cisco router to carry traffic for three different networks (Main, Public, Private).
*   **The Solution:** You must use **802.1q VLAN tagging**. The Cisco router must be configured to allow these VLANs, or you must configure the OpenWRT side to handle the routing *before* sending traffic to the Cisco router.

Given your preference for the "easy way" and the constraint that the Cisco router is likely not easily reconfigurable for complex VLAN tagging, **the most robust and "easy" method is to let the OpenWRT device act as the Gateway for the new networks.**

Here is the recommended architecture:

### Recommended Architecture
1.  **WAN (Physical Port):** Connected to the Cisco Router (10.230.48.x). OpenWRT gets an IP here.
2.  **LAN (Logical):**
    *   **Zone `lan` (Private):** 192.168.2.0/26. Clients here can access the internet (via OpenWRT -> Cisco) and the Gateway (192.168.0.3).
    *   **Zone `guest` (Public):** 192.168.1.0/26. Clients here can access the internet (via OpenWRT -> Cisco) and the Gateway (192.168.0.3). **Blocked** from accessing the `lan` zone.
3.  **SSIDs:**
    *   `Private_WiFi` -> Bridge to `lan` interface.
    *   `Public_WiFi` -> Bridge to `guest` interface.

### Step-by-Step Configuration Guide

#### 1. Network Interface Setup (LuCI or CLI)
You need to create two distinct LAN interfaces on the OpenWRT device.

*   **Interface `lan` (Private):**
    *   Protocol: Static Address
    *   IPv4 Address: `192.168.2.1`
    *   Netmask: `255.255.255.192` (This gives you 62 usable IPs, fitting your /26 requirement).
    *   DHCP Server: Enabled (Range: 192.168.2.10 - 192.168.2.62).

*   **Interface `guest` (Public):**
    *   Protocol: Static Address
    *   IPv4 Address: `192.168.1.1`
    *   Netmask: `255.255.255.192`
    *   DHCP Server: Enabled (Range: 192.168.1.10 - 192.168.1.62).

*   **Interface `wan`:**
    *   Keep your existing setup pointing to the Cisco Router (`10.230.48.x`).

#### 2. Wireless Configuration
Create two SSIDs on both 2.4GHz and 5GHz (or just one band if you prefer, but you asked for both).

*   **SSID "PrivateNet":**
    *   Security: WPA2/WPA3
    *   Network: Select **lan** (or create a new bridge `br-lan` if not auto-created).
*   **SSID "PublicNet":**
    *   Security: WPA2 (or Open if you want total openness, but WPA2 is safer).
    *   Network: Select **guest**.

*Note: In OpenWRT, you can assign multiple networks to a single Wi-Fi interface by creating separate virtual interfaces (VAPs).*

#### 3. Firewall Configuration (The Critical Step)
This is where you enforce the isolation. In OpenWRT (LuCI), go to **Network -> Firewall**.

*   **Zone `lan`:**
    *   Input: Reject
    *   Output: Accept
    *   Forward: Reject
    *   **Masquerading:** Enabled (Allows clients to reach the internet via the WAN).
    *   **Allowed Forwarding:** Allow traffic to `wan` and `guest`? **NO.**
    *   *Correction:* We want Private clients to reach the Gateway (192.168.0.3). Since the Gateway is on the WAN side (10.x network) or a separate subnet, we need to allow forwarding to WAN.

*   **Zone `guest` (Public):**
    *   Input: Reject
    *   Output: Accept
    *   Forward: Reject
    *   **Masquerading:** Enabled.
    *   **Allowed Forwarding:** Allow traffic to `wan` ONLY.
    *   **Forbidden:** Do **NOT** allow forwarding to `lan`.

*   **Traffic Rules (Specific Exceptions):**
    You need to ensure the "Public" clients can reach the specific Gateway IP `192.168.0.3`.
    *   *Scenario A:* If `192.168.0.3` is on the **WAN** subnet (10.230.48.x), the default "Allow Forwarding to WAN" in the `guest` zone is sufficient.
    *   *Scenario B:* If `192.168.0.3` is on a **different** subnet reachable via the WAN, you might need a specific Traffic Rule:
        *   Source Zone: `guest`
        *   Destination IP: `192.168.0.3`
        *   Action: Accept

    **Crucially:** Ensure there is **no** rule allowing `guest` -> `lan` forwarding. By default, OpenWRT zones do not talk to each other unless explicitly allowed.

#### 4. What did you miss?
You missed a few important details that often trip people up:

1.  **The Gateway IP Confusion:** You mentioned the Cisco router is at `10.230.48.1` and the main gateway is `192.168.0.3`.
    *   If your OpenWRT WAN is in the `10.230.48.x` network, how does it reach `192.168.0.3`?
    *   *If `192.168.0.3` is the actual internet gateway for the whole building:* The Cisco router (`10.x`) might be just a pass-through. You need to verify if `192.168.0.3` is reachable from the `10.x` network. If the Cisco router is doing NAT, `192.168.0.3` might be the *source* of the NAT, or a device on the *other* side.
    *   *Action:* From the OpenWRT shell, run `ping 192.168.0.3`. If it fails, your Public clients will never reach it, regardless of firewall rules.

2.  **DHCP Relay vs. DHCP Server:** You correctly identified that the AP should handle DHCP for the new subnets. This is good. Do not try to have the Cisco router hand out IPs for 192.168.1.x and 192.168.2.x unless you configure DHCP Relay (ip helper) on the Cisco, which is harder. Let OpenWRT handle it.

3.  **Client Isolation (Wireless):** In the Wireless Advanced settings, ensure "Client Isolation" is **OFF** for the Private network (they might need to talk to each other, e.g., printers). For the Public network, turn **ON** "Client Isolation" (AP Isolation) as an extra layer of security so Public users can't talk to each other, only the router.

4.  **DNS:** Ensure the DHCP settings on the `guest` and `lan` interfaces point the DNS servers to either the OpenWRT device (192.168.1.1 / 192.168.2.1) or directly to a public DNS (8.8.8.8). If you point to `192.168.0.3` and the DNS server there blocks unknown subnets, internet access will fail.

### Summary of the "Easy Way" Plan
1.  **WAN:** Connects to Cisco (10.x).
2.  **LAN 1 (Private):** 192.168.2.1/26. SSID "Private". Can access WAN and Gateway.
3.  **LAN 2 (Public):** 192.168.1.1/26. SSID "Public". Can access WAN and Gateway. **Cannot** access LAN 1.
4.  **Firewall:** Default "Reject" between zones. Explicitly Allow `guest` -> `wan`.
5.  **Test:**
    *   Connect Public client.
    *   `ping 192.168.0.3` (Should work).
    *   `ping 192.168.2.1` (Should fail - Isolation).
    *   `ping 8.8.8.8` (Should work).

Does this align with your network topology, or is the relationship between the Cisco router (10.x) and the Gateway (192.168.0.3) more complex (e.g., is 192.168.0.3 behind the Cisco)?

> Written with [StackEdit](https://stackedit.io/).
