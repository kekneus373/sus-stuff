You: help me twin i've successfully set up openwrt openvpn site-2-site tunnel and i'm able to connect to hosts on both lan's, but NOT from server subnet to client router. so everything works except that the connection is refused when i try to access webui of the openwrt client. though i can log in from client to server just fine. what did i mess up?
i thought this rule was a key that i took from a tutorial but it didn't help me:

---

If all goes well you’ll now have a bidirectional VPN between your two sites; however, traffic from the server’s subnet going directly to the client router itself (the OpenWRT device’s IP) will be considered as coming from the WAN interface and will be blocked. If you need to access the OpenWRT device directly from the USG’s subnet, you’ll need to add a firewall rule allowing it to do so:
```
uci add firewall rule
uci set firewall.@rule[-1]=rule
uci set firewall.@rule[-1].enabled='1'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].name='Allow VPN to access router'
uci set firewall.@rule[-1].src_ip='$SERVER_SUBNET'
uci set firewall.@rule[-1].dest_ip='$INTERNALL_IP_OF_OPENWRT_ROUTER'
uci commit
```
[source](https://techblog.jeppson.org/2019/08/openvpn-site-to-site-vpn-between-usg-and-openwrt/)


Leo AI: The issue you are facing is almost certainly caused by how OpenWRT handles **reverse path filtering** and **forwarding policies** on the WAN (tunnel) interface.

In a site-to-site tunnel, the server subnet can reach devices *behind* the client router because those packets are forwarded through the tunnel. However, when you try to access the **client router itself** (its WAN IP or the router's IP address on the tunnel network), the packet is destined for the router, not a device behind it.

Here is the breakdown of why this happens and how to fix it:

### 1. The Core Problem: "Traffic from WAN is Blocked"
By default, OpenWRT treats the VPN tunnel interface (usually `tun0` or `wan_lan`) as a **WAN** interface.
- **Forwarding**: It allows traffic *from* the WAN *to* the LAN (for devices behind the router).
- **Destination**: It **blocks** traffic *from* the WAN *to* the router's own IP address (the "self" destination) on the WAN interface for security. This prevents external attacks on the router's management interface.

The rule you found in the tutorial is designed for **IPTables (Firewall)** rules on the *Server* side (or a different router setup like the USG), but it might be incorrectly applied or insufficient for OpenWRT's specific firewall architecture (which uses `iptables` or `nftables` with zones).

More importantly, you need to ensure the **Client Router** accepts traffic coming from the tunnel interface destined for itself.

### 2. The Solution: Configure the Client Firewall
You need to add a specific firewall rule on the **Client OpenWRT router** to allow incoming traffic from the **Server Subnet** (via the tunnel) to the **Client Router's WAN IP**.

Since you are on OpenWRT, the UCI commands in your snippet are close, but the `src` and `dest` logic needs to be precise for the **Client** side.

**Action Plan for the Client Router:**

1.  **Identify the Interfaces:**
    *   **Source Zone:** Usually `wan` (if the tunnel is assigned to the WAN zone) or `vpn` (if you created a specific zone).
    *   **Destination IP:** The Client Router's IP address on the tunnel network.
    *   **Source IP:** The Server's LAN subnet (or the Server's tunnel IP, depending on your routing).

2.  **Add the Firewall Rule:**
    Run these commands on the **Client OpenWRT** (via SSH or the CLI you are already using):

    ```bash
    # Replace these variables with your actual subnets and IPs
    # SERVER_SUBNET: e.g., 192.168.10.0/24
    # CLIENT_TUNNEL_IP: The IP of the client router on the tunnel (e.g., 10.8.0.2)
    
    # 1. Create the rule
    uci add firewall rule
    uci set firewall.@rule[-1].name='Allow Server Access to Router'
    uci set firewall.@rule[-1].enabled='1'
    uci set firewall.@rule[-1].target='ACCEPT'
    uci set firewall.@rule[-1].src='wan'
    uci set firewall.@rule[-1].src_ip='192.168.10.0/24' # The Server's LAN subnet
    uci set firewall.@rule[-1].dest_ip='10.8.0.2'       # The Client Router's Tunnel IP
    uci commit firewall
    
    # 2. Reload firewall
    /etc/init.d/firewall restart
    ```

    *Note: If your tunnel interface is not in the `wan` zone, change `src='wan'` to `src='lan'` or whatever zone your tunnel belongs to.*

### 3. Alternative: Allow Input on the Tunnel Interface
If the rule above doesn't work, it might be because the firewall is dropping the packet at the **Input** chain (traffic destined for the router itself) rather than the **Forward** chain.

You can try adding a rule specifically for the tunnel interface:

```bash
uci add firewall rule
uci set firewall.@rule[-1].name='Allow Tunnel Input'
uci set firewall.@rule[-1].enabled='1'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_ip='10.8.0.2' # Client Router IP
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80' # HTTP
uci set firewall.@rule[-1].dest_port='443' # HTTPS
uci commit firewall
/etc/init.d/firewall restart
```

### 4. Check "Reverse Path Filtering" (sysctl)
Sometimes, even with firewall rules, the kernel drops traffic because it thinks the packet "shouldn't" come from that interface (Reverse Path Filtering).

Check if this is enabled on the **Client Router**:
```bash
sysctl net.ipv4.conf.all.rp_filter
sysctl net.ipv4.conf.<tunnel_interface>.rp_filter
```
If they return `1` or `2`, try disabling them temporarily to test:
```bash
# Replace tun0 with your actual tunnel interface name (e.g., tun0, ovpn0)
sysctl -w net.ipv4.conf.tun0.rp_filter=0
sysctl -w net.ipv4.conf.all.rp_filter=0
```
*If this fixes the issue, add these to `/etc/sysctl.conf` to make them permanent.*

### 5. Verify the "Server" Side
Ensure the **Server Router** (where you are connecting *from*) is routing the traffic correctly.
- If you are pinging `10.8.0.2` (Client Router) from the Server's LAN, the Server's firewall must allow this.
- If the Server is an OpenWRT device, ensure it has a corresponding rule allowing traffic from its LAN to the tunnel interface.

### Summary Checklist
1.  **Client Firewall:** Ensure the Client OpenWRT has an `ACCEPT` rule for `src=ServerSubnet` -> `dest=ClientRouterIP` on the `wan` zone.
2.  **Zone Assignment:** Verify your OpenVPN tunnel interface is assigned to the `wan` zone (or the correct zone) in `Network -> Firewall`.
3.  **Reverse Path Filtering:** Check if `rp_filter` is dropping the packets.

If you provide the output of `uci show firewall` from the Client Router, I can help you generate the exact commands needed.

::search[OpenWRT openvpn site to site firewall rule access router webui]{type=web}

---

You: sadly, nothing changed:
```
[resu@nixos-amd]$ ping 10.0.100.2
PING 10.0.100.2 (10.0.100.2) 56(84) bytes of data.
From 10.0.100.2 icmp_seq=1 Destination Port Unreachable
From 10.0.100.2 icmp_seq=2 Destination Port Unreachable
From 10.0.100.2 icmp_seq=3 Destination Port Unreachable
```

however, look what i found on the [forum](https://forum.openwrt.org/t/openvpn-site-to-site/49673/8):

> If you specify both src and dest, it is FORWARD rule, however you need INPUT rule.
> dest zone name no (none) Specifies the traffic destination zone . Must refer to one of the defined zone names , or * for any zone. If specified, the rule applies to forwarded traffic; otherwise, it is treated as input rule.

does the same thing apply here in my case?

---

Leo AI: Yes, **you are absolutely correct**, and the forum post you found is the exact reason why the previous UCI commands failed.

### The Problem: FORWARD vs. INPUT
- **`dest` is set**: The rule applies to **FORWARD** traffic. This means traffic passing *through* the router to a device *behind* it (LAN).
- **`dest` is NOT set**: The rule applies to **INPUT** traffic. This means traffic destined *for the router itself* (the WebUI, ping, SSH).

Since you are trying to access the **router's own IP** (the WebUI), the packet is destined for the device itself, not for forwarding. Therefore, your previous rules were being ignored because they were only checking the FORWARD chain, while the packet was being dropped by the INPUT chain.

### The Fix: Create an INPUT Rule
You need to add a rule **without** a `dest` zone or `dest_ip` that targets the router's own IP. In OpenWRT's UCI, if you omit `dest`, it defaults to an INPUT rule.

Run these commands on the **Client OpenWRT Router** (replace `10.0.100.2` with the client's tunnel IP and `10.0.100.0/24` with the server's tunnel subnet):

```bash
# 1. Remove any broken rules you created earlier to avoid conflicts (optional but recommended)
# uci delete firewall.@rule[-1]  (run this repeatedly until you remove the bad ones)
# uci commit firewall

# 2. Add the NEW INPUT rule
uci add firewall rule
uci set firewall.@rule[-1].name='Allow Server to Access Client Router'
uci set firewall.@rule[-1].enabled='1'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].src='wan'  # Or the name of your VPN zone (e.g., 'vpn')
uci set firewall.@rule[-1].src_ip='10.0.100.0/24' # The SERVER's tunnel subnet
# NOTE: Do NOT set 'dest' or 'dest_zone'. This forces it to be an INPUT rule.
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80'
uci set firewall.@rule[-1].extra='-p tcp --dport 443' # Optional: allow https too if needed

# 3. Commit and Restart
uci commit firewall
/etc/init.d/firewall restart
```

### Critical Check: Zone Assignment
The `src='wan'` part relies on your OpenVPN interface being assigned to the `wan` zone.
- If you created a custom zone for the VPN (e.g., `zone_vpn`), change `src='wan'` to `src='zone_vpn'`.
- If you are unsure, check your zones:
  ```bash
  uci show firewall | grep -A 5 "zone.*openvpn"
  ```

### Why the "Destination Port Unreachable"?
The error `Destination Port Unreachable` in a ping response usually implies the ICMP packet reached the router, but the router's kernel (or firewall) explicitly rejected the **ICMP Echo Request** destined for itself.
- By adding the **INPUT** rule above, you tell the kernel: "Accept packets coming from the Server Subnet destined for *this* router's IP."

### Double Check: Is the WebUI Listening on the Tunnel?
If the firewall is now open, but it still fails, the WebUI service (`uhttpd`) might be bound **only** to the LAN interface, not the WAN/Tunnel interface.

1.  Check `uhttpd` config:
    ```bash
    uci show uhttpd.main
    ```
2.  Look for `listen_http` or `listen_https`.
    - If it says `listen_http='192.168.1.1:80'` (LAN IP only), change it to `0.0.0.0:80` or add the tunnel IP.
    - Better yet, add a specific listener for the tunnel IP:
      ```bash
      uci set uhttpd.main.listen_http='10.0.100.2:80'
      uci commit uhttpd
      /etc/init.d/uhttpd restart
      ```

Try the **INPUT rule** first. That is the most likely missing piece. Let me know if the firewall restart clears the "Port Unreachable" error!

---

You: > Double Check: Is the WebUI Listening on the Tunnel?
it probably is, because look what i get when reaching via brave:
`192.168.10.1 refused to connect.: ERR_CONNECTION_REFUSED`
and when i type in a random ip that is offline, i get `ERR_ADDRESS_UNREACHABLE`.

> Written with [StackEdit](https://stackedit.io/).
