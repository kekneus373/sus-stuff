It is completely understandable to stick with **OpenVPN**; if you have a proven 3-year stable client-2-client setup, the learning curve and risk factor of switching to WireGuard are unnecessary. OpenVPN remains a rock-solid choice for site-to-site tunnels, especially when you need complex routing or are dealing with legacy infrastructure.

Below are the production-ready configuration profiles for a **site-to-site (hub-and-spoke or peer-to-peer)** setup. I have designed these for **OpenWrt** on both ends, using the `luci-app-openvpn` interface or direct `/etc/config/openvpn` file editing.

### Architecture Overview
*   **Site A (Headquarters/Hub):** Static Public IP, acts as the main server.
*   **Site B (Branch/Spoke):** Dynamic or Static Public IP, acts as the client connecting to Site A.
*   **Tunnel Network:** `10.10.10.0/24` (Private subnet for the tunnel only).
*   **Routing:** Traffic from Site B LAN will be routed through the tunnel to Site A LAN (and vice versa).

---

### 1. Server Configuration (Site A)
*Create this on the router acting as the server.*

**File:** `/etc/config/openvpn` (or via LuCI: Network → OpenVPN)

```text
config openvpn 'sitea_server'
    option interface 'wan'
    option mode 'server'
    option dev 'tun'
    option proto 'udp'
    option port '1194'
    option persist_tun '1'
    option persist_key '1'
    option tls_server '1'
    option ca '/etc/openvpn/ca.crt'
    option cert '/etc/openvpn/server.crt'
    option key '/etc/openvpn/server.key'
    option dh '/etc/openvpn/dh.pem'
    option ca_crl '/etc/openvpn/ca-crl.pem'
    option cipher 'AES-256-CBC'
    option auth 'SHA256'
    option comp_lzo 'no'
    option push 'route 10.10.10.1 255.255.255.0'
    option push 'push "redirect-gateway def1"'
    option push 'dhcp_option 6 8.8.8.8 8.8.4.4'
    option push 'route 192.168.10.0 255.255.255.0'
    option route_metric '0'
    option keepalive '10 120'
    option nobind '1'
    option reneg '3600'
    option user 'nobody'
    option group 'nogroup'
    option log '/var/log/openvpn/sitea.log'
    option log_append '1'
    option verb '3'
    option script_security '2'
    option client_to_client '0'
    option client_cert_not_required '0'
    option duplicate_cn '0'
```

**Key Production Settings Explained:**
*   **`mode 'server'`**: Tells OpenWrt to listen for incoming connections.
*   **`push 'route ...'`**: Crucial for site-to-site. It tells the client (Site B) that it should send traffic for Site B's LAN (`192.168.10.0`) through this tunnel.
*   **`client_to_client '0'`**: Prevents clients from talking to each other directly on the tunnel, enhancing security in a hub-and-spoke model.
*   **`comp_lzo 'no'`**: Disables LZO compression. Modern CPUs handle encryption better than compression, and LZO can sometimes cause issues with packet fragmentation.
*   **`reneg '3600'`**: Forces key renegotiation every hour for forward secrecy.

---

### 2. Client Configuration (Site B)
*Create this on the router acting as the client.*

**File:** `/etc/config/openvpn`

```text
config openvpn 'siteb_client'
    option interface 'wan'
    option mode 'client'
    option dev 'tun'
    option proto 'udp'
    option remote '203.0.113.50'
    option remote_port '1194'
    option persist_tun '1'
    option persist_key '1'
    option resolv_retry 'infinite'
    option tls_client '1'
    option ca '/etc/openvpn/ca.crt'
    option cert '/etc/openvpn/client.crt'
    option key '/etc/openvpn/client.key'
    option cipher 'AES-256-CBC'
    option auth 'SHA256'
    option comp_lzo 'no'
    option float '1'
    option nobind '1'
    option ping '10'
    option ping_restart '60'
    option ping_tun '1'
    option route_delay '2'
    option route_delay_queue '30'
    option script_security '2'
    option pull '1'
    option route '192.168.10.0 255.255.255.0 10.10.10.1'
    option up 'ifconfig-up.sh'
    option down 'ifconfig-down.sh'
```

**Key Production Settings Explained:**
*   **`remote`**: Replace `203.0.113.50` with Site A's public IP or DDNS hostname.
*   **`resolv_retry 'infinite'`**: Critical for dynamic IPs. The client will keep retrying indefinitely if the server is unreachable.
*   **`route '192.168.10.0 ...'`**: This is the **most important line**. It tells the client: "If you see traffic for Site A's LAN (`192.168.10.0`), send it to the tunnel gateway (`10.10.10.1`)."
*   **`pull '1'`**: Accepts routes pushed by the server (like the server's LAN route).
*   **`route_delay`**: Waits a few seconds for the tunnel to come up before adding routes, preventing "route not found" errors during boot.

---

### 3. Critical Firewall Rules (Both Ends)
OpenWrt's firewall (`firewall4` or `firewall3`) blocks all tunnel traffic by default. You **must** add these rules to allow the tunnel to function.

**File:** `/etc/config/firewall` (Add to the `zone` or `forward` section)

```text
config zone
    option name 'tunnel'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '0'
    option mtu_fix '1'
    option network 'tun0'
```

**Forwarding Rules (Site A & Site B):**

```text
config forwarding
    option src 'tunnel'
    option dest 'lan'
    option name 'tunnel-to-lan'
    option enabled '1'

config forwarding
    option src 'lan'
    option dest 'tunnel'
    option name 'lan-to-tunnel'
    option enabled '1'
```

**Traffic Control (Optional but Recommended):**
If you want to ensure the tunnel traffic doesn't get blocked by QoS or rate limiters, ensure `tun0` is excluded from WAN rate limiting rules.

---

### 4. Dynamic DNS & Connectivity Maintenance
Since Site B likely has a dynamic IP, you need to ensure the tunnel stays up even if the WAN interface resets.

1.  **DDNS on Site B:** Install `ddns-scripts` and `ddns-scripts-cloudflare` (or your provider) to update a hostname if Site B's IP changes. Update the `remote` line in Site A's config if Site B initiates (unlikely for site-to-site) or if Site B needs to be reachable (not needed if it's just a client).
2.  **Keepalive:** The `keepalive '10 120'` setting in the server config ensures the tunnel detects dead peers quickly.
3.  **Routing Table:** Ensure the routing table on the client router knows to send traffic to the `tun0` interface. The `route` directive in the client config handles this.

---

### 5. Testing & Troubleshooting
Once configured, verify connectivity step-by-step:

1.  **Check Service Status:**
    ```bash
    /etc/init.d/openvpn status
    ```
    Look for "running" on both ends.

2.  **Check Tunnel Interface:**
    ```bash
    ip addr show tun0
    ```
    You should see an IP like `10.10.10.1` on Site A and `10.10.10.2` on Site B.

3.  **Ping Test:**
    From Site B, ping Site A's tunnel IP:
    ```bash
    ping -c 4 10.10.10.1
    ```
    Then ping a device on Site A's LAN:
    ```bash
    ping -c 4 192.168.10.50  # (Assuming 192.168.10.50 is a PC on Site A)
    ```

4.  **Firewall Logs:**
    If pings fail, check `/var/log/messages` or LuCI's "Logs" tab for firewall drops on the `tunnel` zone.

### Security Checklist for Production
*   **Strong Ciphers:** Stick to `AES-256-CBC` (or `AES-256-GCM` if your hardware supports it natively). Avoid `RC4` or `DES`.
*   **Key Rotation:** The `reneg '3600'` setting ensures keys are rotated periodically.
*   **No LZO:** Disabling LZO prevents potential compression-based attacks and reduces CPU load on modern hardware.
*   **Firewall Zones:** Ensure the `tunnel` zone is not allowed to initiate connections to the WAN zone (`input 'REJECT'`).

If you are running this 24/7 for years, you likely have a solid understanding of persistence. The key difference in production is ensuring **MTU handling** is correct to avoid fragmentation. If you see "Time to Live exceeded" or slow speeds, try lowering the MTU on the tunnel interface (e.g., `set mtu 1280`).

---

## Learning resources

<mark>scp transfer directory</mark>

To transfer a directory recursively using the **scp** command, you must use the **`-r`** flag, which tells the tool to copy the directory and all its contents, including subdirectories and files. The syntax depends on the direction of the transfer:

*   **Local to Remote**: `scp -r /path/to/local/directory username@remote_host:/path/to/remote/directory`
*   **Remote to Local**: `scp -r username@remote_host:/path/to/remote/directory /path/to/local/directory`

If the remote server uses a non-standard SSH port, add the uppercase **`-P`** flag (e.g., `scp -r -P 2222 ...`). Note that while **scp** is widely used, it is considered legacy by OpenSSH developers due to security vulnerabilities; for large directories or repeated transfers, **rsync** is often recommended for its delta transfer capabilities and ability to resume interrupted uploads.

<mark>openwrt ash: /usr/libexec/sftp-server: not found</mark>

The error **`ash: /usr/libexec/sftp-server: not found`** occurs because modern OpenSSH clients (version 9.0+) default to using the **SFTP protocol** for `scp` transfers, while vanilla OpenWrt installations typically use **Dropbear**, which does not support SFTP and lacks the required helper binary.

To resolve this, you have two primary options:

*   **Use Legacy SCP (Client-Side Fix):** Add the `-O` flag to your `scp` command to force the use of the older, compatible protocol.
    ```bash
    scp -O file root@192.168.1.1:/tmp/
    ```
*   **Install SFTP Server (Server-Side Fix):** Install the OpenSSH SFTP helper package on the OpenWrt device via SSH.
    ```bash
    opkg update && opkg install openssh-sftp-server
    ```

<mark>openvpn --genkey secret ta.key</mark>
<mark>openvpn --show-ciphers</mark>
<mark>vim /etc/openvpn/ccd</mark>
```ini
ifconfig-push "10.9.0.1 10.9.0.2"
```

<mark>openvpn client static ip address</mark>

To assign a **static IP address** to an OpenVPN client, you must configure the server to push a specific IP based on the client's identity, as the client-side configuration cannot override the server's assignment.

**Method 1: Using Client-Config-Dir (Standard OpenVPN)**
1. **Enable CCD**: Add `client-config-dir /etc/openvpn/ccd` to your `server.conf`.
2. **Create Client File**: In the specified directory, create a file named exactly after the client's certificate **Common Name (CN)**.
3. **Assign IP**: Inside the file, add the directive `ifconfig-push <ClientIP> <Netmask>`. For example: `ifconfig-push 10.8.0.50 255.255.255.0`.
4. **Restart Server**: Apply changes by restarting the OpenVPN service.

**Method 2: Using OpenVPN Access Server (GUI)**
1. Navigate to **Configuration > VPN Settings** and define a **Static IP Address Network** (a private subnet different from the dynamic pool).
2. Go to **User Management > User Permissions**, select the user, and click **More Settings**.
3. Under **IP Addressing**, select **Use Static** and enter the desired IP address within the defined static subnet.
4. Save settings and update the running server.

**Important Constraints**:
*   The assigned IP must fall within the **VPN address pool** defined in the server configuration (e.g., `server 10.8.0.0 255.255.255.0`).
*   Do not use the first IP address in the range (e.g., `10.8.0.0`) as it is typically reserved for the server itself.
*   For **Access Server**, static IP assignment is not supported in cluster mode.

<mark>push route?</mark>
The `push "route ..."` directive in an OpenVPN server configuration tells connected clients **which networks they should send traffic to through the tunnel**. It’s how the server directs clients to reach remote subnets (like your home LAN, office network, or another site).

### What `push "route"` Does
When a client connects to the OpenVPN server, the server can push route entries to the client’s routing table. This means:
- The client learns about networks it didn’t know before.
- Traffic destined for those networks is sent through the VPN tunnel instead of the default internet gateway.

### Example from Your Config
In your Site A (server) config:
```bash
option push 'route 192.168.10.0 255.255.255.0'
```
This line tells Site B (the client):
> “If you see traffic going to `192.168.10.0/24` (Site A’s LAN), send it through the tunnel to me (the server).”

Without this, Site B would not know how to reach devices on Site A’s LAN, even if the tunnel is up.

### Key Points
- **Only works on the server side**: `push` is ignored in client configs.
- **Requires `pull` on the client**: The client must have `option pull '1'` (default in most setups) to accept pushed routes.
- **Multiple routes**: You can push multiple networks by adding more `push 'route ...'` lines.
- **Site-to-site vs. client access**: In site-to-site (router-to-router), both ends usually need to push routes so traffic flows both ways.

### Common Pitfalls
- **Firewall rules**: Even with correct routes, firewall zones must allow traffic between LAN and the tunnel interface.
- **Duplicate subnets**: If both sites use `192.168.1.0/24`, routing will break. Use unique subnets.
- **MTU issues**: Pushed routes don’t fix MTU problems; large packets may still fragment or drop.

If you’re setting up a hub-and-spoke model, the hub (Site A) typically pushes routes to all spokes, while spokes might only push their own LAN route back to the hub.

*building openvpn lan-to-lan on openwrt. how do i push route from client subnet to server?*

### Short answer

Use a combination of  **server-side push routes**, a  **client-config-dir (CCD) with iroute**  for any client that represents a remote LAN, and ensure  **kernel IP forwarding + firewall + LAN gateway routes**  are in place so the server's LAN and the client LANs can reach each other.

----------

### What you must configure (high level)

-   **On the OpenVPN server**
    -   Add a route for the remote client-subnet(s) into OpenVPN (server config).
    -   Add client-specific iroute entries in the CCD for each client that advertises a LAN behind it.
    -   Push the route to other VPN peers (so other clients/servers know how to reach that subnet).
-   **On the client that has a LAN behind it**
    -   Ensure the client is configured to let the OpenVPN process advertise its LAN (the client simply connects; CCD/iroute on server tells OpenVPN which client owns the subnet).
    -   Enable IP forwarding on that client and allow forwarding in firewall.
-   **On each LAN router**  (or the network's default gateway)
    -   Add a static route for the remote subnet(s) pointing at the local OpenVPN endpoint if the LAN hosts use the LAN router for routing (typical for site-to-site).

----------

### Concrete example

Assume:

-   Server tun IP: 10.8.0.1
-   Client (site A) tun IP: 10.8.0.6
-   Site A LAN: 192.168.10.0/24
-   Server LAN (site B): 192.168.20.0/24

1.  Server config (/etc/openvpn/server.conf)

```bash
# network for the VPN (example)
server 10.8.0.0 255.255.255.0

# advertise the remote-subnet(s) to the server OS routing table
route 192.168.10.0 255.255.255.0

# cause other clients to learn how to reach 192.168.10.0/24
push "route 192.168.10.0 255.255.255.0"

# point to CCD directory
client-config-dir /etc/openvpn/ccd
```

2.  CCD file for that client (named by the client's common-name), e.g. /etc/openvpn/ccd/siteA

`iroute 192.168.10.0 255.255.255.0` 

Why:  `route`  tells the server kernel to send packets for that subnet into OpenVPN;  `iroute`  tells OpenVPN which client instance actually owns that subnet (so the server can forward traffic to the correct client over the tunnel).  `push "route ..."`  lets other clients learn the route (except the owning client).

3.  On the client machine at site A (the one attached to 192.168.10.0/24)

-   Enable IP forwarding:

```bash
# temporary
sysctl -w net.ipv4.ip_forward=1
# persistently (Debian/Ubuntu /etc/sysctl.conf or OpenWrt /etc/sysctl.conf)
```

-   Ensure firewall allows forwarding between the LAN interface and tun0 (or use ACCEPT forwarding policy). Example iptables (adjust for your firewall):

```bash
iptables -A FORWARD -i br-lan -o tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -o br-lan -j ACCEPT
# if NAT is desired (not recommended for full routed site-to-site):
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
```

4.  On the server-LAN router (or each host if you can't change gateway)

-   If the hosts on the server LAN use the server's LAN box as default gateway, add a route:
    -   Destination: 192.168.10.0/24
    -   Gateway: the server's LAN IP (the physical IP of the OpenVPN server in that LAN) Example (Linux gateway):

```bash
ip route add 192.168.10.0/24 via 192.168.20.2   # where 192.168.20.2 is server's LAN IP
```
If you cannot add a route on the LAN gateway, you must either add static routes on each host or perform NAT on the client side (less ideal).

----------

### OpenWrt-specific tips

-   Enable IP forwarding is usually already on. For firewall, use UCI to allow forwarding between zones (e.g. allow forwarding between lan and vpn zones), or add firewall rules in /etc/config/firewall:

```bash
# example (uci)
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpn'
uci commit firewall
/etc/init.d/firewall restart
```
-   Put your OpenVPN server.conf and client CCD as above; OpenWrt's openvpn package honors client-config-dir.

----------

### Common mistakes / gotchas

-   Forgetting iroute in CCD: packets reach the server but the OpenVPN daemon doesn't know which client to forward that subnet to.
-   Forgetting to add the kernel route (server.conf route directive) so the server OS will send packets into the tunnel.
-   Not enabling IP forwarding on the client that has the LAN behind it.
-   LAN gateway not knowing how to reach the remote subnet — traceroutes showing * * * often indicate missing reverse routes.
-   Expecting push routes to reach the owning client: OpenVPN will not push a route to the client that owns that subnet (it would be redundant). Other clients get the pushed route.

----------

### Next steps / commands to verify

-   On server, check routes:

```bash

ip route show
# should show 192.168.10.0/24 via 10.8.0.x dev tunX 

```

-   On server OpenVPN log, verify it loaded CCD/iroute for the client when it connected.
-   Use tcpdump on tun interface to see traffic flow:

`tcpdump -n -i tun0 host 192.168.10.5` 

-   From a host on server LAN, traceroute to a host behind the client and confirm packets hit the server LAN IP and then go into the tunnel.

----------


To set up multiple LANs behind an OpenVPN server on OpenWrt (or as clients connecting to a central server), you need to configure **routing**, **IP forwarding**, **Client Config Directory (CCD)** with `iroute` statements, and ensure **firewall** rules allow the traffic.

Here is how to translate the `server.conf` example you provided into OpenWrt configuration, assuming your OpenWrt device is acting as the **OpenVPN Server**.

### 1. Enable IP Forwarding
First, ensure your OpenWrt device forwards packets between interfaces.
*   **Via LuCI (Web UI):** System → Startup → Uncheck "No" for `Forwarding` or ensure `net.ipv4.ip_forward=1` is set in `/etc/sysctl.conf`.
*   **Via SSH:**
    ```bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```
    To make it permanent, add `option forward '1'` to the `config globals` in `/etc/sysctl.conf` or ensure `option ip_forward '1'` is in `/etc/config/network`.

### 2. Configure OpenVPN Server (`/etc/config/openvpn`)
OpenWrt uses UCI (Unified Configuration Interface) for OpenVPN. You cannot simply paste `server.conf` lines; you must map them to `option` and `list` entries.

**Crucial:** In OpenWrt UCI, if you specify the same option (like `push`) multiple times, you must use `list` instead of `option`.

Edit `/etc/config/openvpn`:

```bash
config openvpn 'server'
    option enabled '1'
    option dev 'tun'
    option proto 'udp'
    option port '1194'
    option ca '/etc/openvpn/easy-rsa/pki/ca.crt'
    option cert '/etc/openvpn/easy-rsa/pki/issued/server.crt'
    option key '/etc/openvpn/easy-rsa/pki/private/server.key'
    option dh '/etc/openvpn/easy-rsa/pki/dh.pem'
    option server '10.8.0.0 255.255.255.0'
    option topology 'subnet'
    option client_to_client '1'
    
    # Enable Client Config Directory for iroute
    option client_config_dir '/etc/openvpn/ccd'

    # Routes for the server's local LAN (10.10.2.0/24)
    # Note: Use 'list' to push multiple routes
    list push 'route 10.10.2.0 255.255.255.0'
    list push 'route 10.10.1.0 255.255.255.0'
    list push 'route 10.10.3.0 255.255.255.0'

    # Kernel routes to tell OpenWrt how to reach client LANs
    # These are NOT pushed to clients; they are for the server itself
    list route '10.10.1.0 255.255.255.0'
    list route '10.10.3.0 255.255.255.0'
```

*Note: If you are using the OpenWrt LuCI interface for OpenVPN, ensure you switch to "Custom Configuration" or use the "Advanced" tab if available, as the standard form often only allows one push route unless you edit the raw config.*

### 3. Create Client Config Directory (CCD) Files
The `iroute` directive tells the OpenVPN server *which client* owns a specific subnet. This must be done per client.

1.  Create the directory if it doesn't exist:
    ```bash
    mkdir -p /etc/openvpn/ccd
    ```
2.  Create a file named exactly after the **Common Name (CN)** of the client certificate.
    *   If `client1` has CN `client1`, create `/etc/openvpn/ccd/client1`.
    *   If `client2` has CN `client2`, create `/etc/openvpn/ccd/client2`.

**File: `/etc/openvpn/ccd/client1`** (For the client with LAN 10.10.1.0/24)
```text
iroute 10.10.1.0 255.255.255.0
```

**File: `/etc/openvpn/ccd/client2`** (For the client with LAN 10.10.3.0/24)
```text
iroute 10.10.3.0 255.255.255.0
```

*Without these `iroute` lines in the specific client files, the server will drop packets from those LANs with the error `MULTI: bad source address from client`.*

### 4. Configure Firewall
You must allow traffic to pass between the `lan` zone, the `wan` zone, and the new `openvpn` zone (or `tun` interface).

**Via SSH (recommended for precision):**
Edit `/etc/config/firewall`:

```bash
config zone
    option name 'openvpn'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    option network 'tun0' # Or whatever your dev name is

config forwarding
    option src 'lan'
    option dest 'openvpn'

config forwarding
    option src 'openvpn'
    option dest 'lan'
    
# If you have multiple LANs behind the OpenVPN clients, 
# you might also need forwarding between openvpn and other specific zones
```

**Via LuCI:**
1.  Go to **Network** → **Firewall** → **Zone Settings**.
2.  Add a new zone named `openvpn`.
3.  Set **Covered networks** to `tun0` (or select the specific OpenVPN interface).
4.  Set **Input**, **Output**, and **Forward** to `Accept`.
5.  Go to the **Inter-Zone Forwarding** section and add rules to allow forwarding between `lan` ↔ `openvpn`.

### 5. Client-Side Configuration
Remember that the machines on the client side (10.10.1.x and 10.10.3.x) must also have **IP Forwarding** enabled if they are acting as routers themselves.
*   If `client1` is an OpenWrt router behind the VPN, ensure it has `option ip_forward '1'` and pushes the `iroute` for its local LAN to the server (which we did in step 3).
*   The OpenWrt server will push the routes to the clients automatically via the `push "route ..."` lines in step 2.

### 6. Restart OpenVPN
Apply the changes:
```bash
/etc/init.d/openvpn restart
```
Check logs to verify routing is working:
```bash
logread | grep openvpn
```
Look for messages like `MULTI: Learn: <IP> -> <client_name>` and ensure no `bad source address` errors appear.

### Important Caveat: Common Subnets
As noted in the source text, avoid using common subnets like `192.168.1.0/24` if you have "road warrior" clients connecting from home networks that might use the same subnet. If a client connects from a home network `192.168.1.0/24` and the server pushes a route to `192.168.1.0/24`, the client will lose internet access because it tries to route its own gateway traffic through the VPN. If your LANs use common subnets, consider changing them to unique ranges (e.g., `10.10.x.0/24`) before setting up the VPN.

---

[](https://forum.openwrt.org/t/openvpn-site-to-site-troubleshooting/124423)

forum.openwrt.org  › installing and using openwrt

OpenVPN site-to-site troubleshooting - Installing and Using OpenWrt - OpenWrt Forum

Hello! Could you please help me to solve my situation... I have to LANs which I want to join via OpenVPN tunnel (site-to-site). First LAN: 192.168.1.0 255.255.255.0 Second LAN: 192.168.0.0 255.255.255.0 First LAN runs with AdvancedTomato router. Second LAN - with OpenWRT 19.0.7.2. AdvancedTomato ...

[](https://forum.openwrt.org/t/openvpn-site-to-site-issues/171031)

forum.openwrt.org  › installing and using openwrt

OpenVPN Site to Site issues - Installing and Using OpenWrt - OpenWrt Forum

Hi, I am using a Linksys E8450 (UBI) running OpenWrt 22.03.5 r20134-5f15225c1e / LuCI openwrt-22.03 branch git-23.119.80898-65ef406 with a local lan of 192.168.33.0/24 (OpenWrt is at 192.168.33.254). I have an OpenVPN server in AWS (Public IP outside, OpenVPN IP 10.8.0.1) that its (10.8.0.2) ...

<mark>[**CHECK RN!!!**](https://forum.openwrt.org/t/openvpn-site-to-site/49673/9)</mark>

forum.openwrt.org  › installing and using openwrt

OpenVPN Site-to-Site - Installing and Using OpenWrt - OpenWrt Forum

Dear openwrt community, I‘m migrating my pfSense to OpenWRT (APU2 with 2x WLE900VX and lots of openvpn servers and clients). All openvpn servers and clients (wirh vpn splitting and vlans work, except with site-to-site where I‘m stuck. Followed openvpn extras (thanks!) and used openvpn config ...

[](https://superuser.com/questions/1508102/site-to-site-tunnel-using-openvpn)

superuser.com  › questions › 1508102 › site-to-site-tunnel-using-openvpn

networking - Site to site tunnel using OpenVPN - Super User

The OpenWRT/openWRT router connects to the main site and it reaches each device in the network (via SSH on the OpenWRT router a ping on for example 10.0.254.254 successful), but no client of this site reaches the main site, no matter which static routes I set.

[](https://forum.openwrt.org/t/openvpn-site-to-site-no-traffic-incoming-to-vpn/164698)

forum.openwrt.org  › installing and using openwrt

OpenVPN site to site no traffic incoming to VPN - Installing and Using OpenWrt - OpenWrt Forum

Hi This is my second attempt to use openwrt. My 1st attempt was on virtualbox and bridged WAN, and 2nd is on a flashed TP-link Archer A7 router, on both routers I am getting stuck on the same issue. I am trying to setup a openvpn site2site VPN, having a remote opnsense router as UDP server, ...

[](https://forum.openwrt.org/t/help-troubleshooting-vpn-issues-link-initialized-but-no-traffic/212489)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

Help troubleshooting VPN Issues - link initialized but no traffic - Network and Wireless Configuration - OpenWrt Forum

I&#x27;m losing my mind tonight, I&#x27;ve been staring at a screen for 7 hours trying to get this to work and I cannot fathom what is wrong. The intent is to create a routed VPN for management of OpenWRT devices with OpenWISP. …

[](https://forum.openwrt.org/t/openvpn-site-to-site-vpn-routing-issue/45963)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

OpenVPN: Site-to-Site VPN, Routing Issue - Network and Wireless Configuration - OpenWrt Forum

Hello community, recently I&#x27;ve been trying to achieve a &quot;Site-to-Site VPN&quot;. Unfortunately I am unable to figure out, how exactly or rather why exactly it fails for me. The issue is, that the routing from the VPN clients LAN to the VPN server, works just fine, but not vice versa.

[](https://forum.openwrt.org/t/openvpn-site-to-site-vpn/37259)

forum.openwrt.org  › installing and using openwrt

OpenVPN site to site VPN - Installing and Using OpenWrt - OpenWrt Forum

I do not understand well if you look at the OpenVPN manual, so I will ask you a question. The environment is as follows. ・ OpenWRT router * 3 Base A Global IP 111.111.111.111 (Dummy) Private IP 192.168.1.0/24 OpenVPN IP 192.168.8.1/24 Base B Global IP 222.222.222.222 (Dummy) Private IP 192.168.2.0/24 OpenVPN IP 192.168.8.2/24 Base C Global IP 333.333.333.333 (Dummy) Private IP 192.168.3.0/24 OpenVPN IP 192.168.8.3/24 As a requirement I would like to access the private IPs of bases A...

[](https://forums.openvpn.net/viewtopic.php?t=30278)

forums.openvpn.net  › home › board index › openvpn inc. enterprise business solutions › the openvpn access server

Site-to-site vpn - OpenVPN Support Forum

Static ip, very fast internet connection etc. I can log in just as must: STATICIPMYACCESSERVER:934, STATICIPMYACCESSERVER:934/admin. Using Jelastic panel I can see my static ip and also &quot;internal lan ip&quot; of the Access Server. https://openwrt.org/docs/guide-user/ser ...

[](https://github.com/openwrt/packages/issues/23370)

github.com  › openwrt › packages › issues › 23370

openvpn: ovpn config doesn't come up with latest changes in master · Issue #23370 · openwrt/packages

root@2go:~# logread -e &quot;openvpn&quot; Sun Feb 11 19:00:52 2024 user.notice openvpn: DEBUG ::: NO INSTANCE Sun Feb 11 19:00:53 2024 user.notice openvpn: DEBUG ::: START_PATH_INSTANCES Sun Feb 11 19:00:53 2024 daemon.notice openvpn(mullvad)[3328]: OpenVPN 2.6.8 aarch64-openwrt-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [MH/PKTINFO] [AEAD] un Feb 11 19:35:13 2024 daemon.notice openvpn(mullvad)[3328]: /usr/libexec/openvpn-hotplug up mullvad tun0 1500 0 10.9.0.3 255.255.0.0 init Sun Feb 11 19:35:13 2024 daemon.notice openvpn(mullvad)[3328]: net_route_v4_add: 185.65.135.83/32 via 10.168.30.1 dev [NULL

[](https://www.reddit.com/r/openwrt/comments/u0cx7f/an_issue_with_openvpn_on_openwrt_2102_the/)

reddit.com  › r/openwrt › an issue with openvpn on openwrt 21.02. - the connection to the vpn server establishes, internet can be accessed, but no tunneling

r/openwrt on Reddit: An issue with OpenVPN on OpenWrt 21.02. - the connection to the VPN server establishes, Internet can be accessed, but no tunneling

You can e.g. add a line &quot;list route 0.0.0.0 0.0.0.0&quot; in your ovpn client config File or adjust it in LuCI under OpenVPN advanced config Network as an option named &quot;route&quot;. Furthermore you could also add a static route in OpenWRT. Another possibility to route all traffic through the tunnel would be to use the option &quot;redirect-gateway&quot; in your ovpn client config file. But I do not know if this option works in a site-to-site tunnel config.

[](https://www.reddit.com/r/openwrt/comments/1htbwyt/openvpn_server_not_working/)

reddit.com  › r/openwrt › openvpn server not working

r/openwrt on Reddit: openVPN server not working

Could be that your phone provider (if trying to connect via phone) or ISP is blocking it. You can try to switch to a nonstandard port on the OpenVPN setup.

[](https://forum.openwrt.org/t/openvpn-site-to-site-firewall-rules/190920)

forum.openwrt.org  › installing and using openwrt

OpenVPN - Site to Site - Firewall Rules - Installing and Using OpenWrt - OpenWrt Forum

Hello, Fundamental question: What am I missing to allow traffic from a vpn client on tun22 --&gt; br-lan? I recently updated a router from 19.X to 23.5 doing so migrates from IPtables to NFTables. I have copied over the VPN config and not changed the client end at all.

[](https://forum.openwrt.org/t/cannot-connect-to-openvpn-from-wan/192533)

forum.openwrt.org  › installing and using openwrt

Cannot connect to OpenVPN from WAN - Installing and Using OpenWrt - OpenWrt Forum

Hello, I spent so much time troubleshooting this... several days and this forum is the only hope for me. Here is the summary: Trying to setup OpenVPN on main WAN router. I have have done this numerous times in the pas…

[](https://networkantics.com/troubleshoot-openwrt-vpn-setup/)

networkantics.com  › home › blog › openwrt vpn setup not working? how to easily troubleshoot common issues

OpenWRT VPN Setup Not Working? How to Easily Troubleshoot Common Issues - Network Antics

In the third part of our VPN series, we discuss common technical issues and how to troubleshoot your OpenWRT VPN setup.

[](https://serverfault.com/questions/240651/openwrt-openvpn-client-forwarding-from-lan-to-vpn-not-working)

serverfault.com  › questions › 240651 › openwrt-openvpn-client-forwarding-from-lan-to-vpn-not-working

OpenWRT + OpenVPN client forwarding from lan to vpn not working - Server Fault

You most likely don&#x27;t have the openvpn client side routing set up.

[](https://forum.openwrt.org/t/site-to-site-vpn-options/142906)

forum.openwrt.org  › installing and using openwrt

Site to site VPN options - Installing and Using OpenWrt - OpenWrt Forum

I&#x27;ve just rented a storage/hobby room in a facility. The owner provides &quot;free&quot; WIFI access but I just found out everything is blocked except port TCP/443. Other tenants there are tinkering with cars or motorcycles so for them https access is plenty enough but I want to tinker with electronics ...

[](https://forum.openwrt.org/t/openvpn-site-to-site-connectivity-issue/72683)

forum.openwrt.org  › installing and using openwrt

OpenVPN Site-to-Site connectivity issue - Installing and Using OpenWrt - OpenWrt Forum

Hi all, I&#x27;m trying to set up a Site-to-Site (shared key) OpenVPN connection between two OpenWRT routers. The VPN is establishing successfully, but I&#x27;m unable to ping between the two &#x27;tun&#x27; interfaces that are used for OpenVPN (no response when pinging 192.168.9.2). I have a feeling that it is firewall/iptables related, as when I run /etc/init.d/firewall stop on &#x27;Router A&#x27;, I can sometimes start pinging the remote router &#x27;B&#x27; tun0 IP address after it has flushed the tables.

[](https://forum.openwrt.org/t/openvpn-not-working/156886)

forum.openwrt.org  › installing and using openwrt

OpenVPN not working - Installing and Using OpenWrt - OpenWrt Forum

I followed a tutorial exactly and in luci it says the the vpn is on and working but when I check my ip or location they never change

[](https://forum.openwrt.org/t/site-to-site-vpn/73419)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

Site-to-Site VPN - Network and Wireless Configuration - OpenWrt Forum

Hello everyone. I would like to set up a site-to-site vpn from my WRT1900ACS to another WRT1900ACS. For this I&#x27;ve read some of the Documentation in the OpenWRT Wiki. I&#x27;m not sure if this Guide fits my needs. In the vpn …

[OpenWrt site-to-site OpenVPN troubleshooting 2024](https://search.brave.com/search?q=OpenWrt%20site-to-site%20OpenVPN%20troubleshooting%202024)

[](https://forums.openvpn.net/viewtopic.php?t=25039)

forums.openvpn.net  › home › board index › community project › server administration

Setting correct MTU - OpenVPN Support Forum

OpenVPN requires that packets on the control or data channels be sent unfragmented. MTU problems often manifest themselves as connections which hang during periods of active usage. It&#x27;s best to  use the --fragment and/or --mssfix options  to deal with MTU sizing issues.

[](https://www.privateproxyguide.com/optimizing-openvpn-performance-by-adjusting-mtu-and-fragmentation/)

privateproxyguide.com  › home › optimizing openvpn performance by adjusting mtu and fragmentation

Optimizing OpenVPN Performance by Adjusting MTU and Fragmentation

If you omit a size, OpenVPN applies a safe default; but it’s best to compute and set it explicitly after tests. ... Why MSS first? Most real traffic is TCP. Clamping MSS prevents inner payloads from creating outer packets that exceed path MTU. It’s minimally invasive and usually enough. Use ICMP “do not fragment” probes to find your ceiling.

[](https://community.openvpn.net/openvpn/ticket/1407)

community.openvpn.net  › openvpn › ticket › 1407

#1407 (MTU Discovery is broken on multiple operating systems and Linux builds) – OpenVPN Community

(explanation of the problem and a response by the head dd-wrt developer to modify dd-wrt to hard code tun-mtu to 1400 in the default OpenVPN setup) ​ https://community.openvpn.net/openvpn/ticket/930 · (explanation of variation of the problem affecting windows and linux and a comment &quot;it&#x27;s known and not fixed&quot;)

[](https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=329037&sid=bc03c22b6f512e171b6f5b2ddb892f5e)

forum.dd-wrt.com  › phpBB2 › viewtopic.php

DD-WRT :: View topic - OpenVPN defect, bug, on MTU handling - you decide

DOWNLOADS · ACTIVATION CENTER · Professional · Support · Community · Contact · Forum · Bugtracker · DD-WRT

[](https://forums.openvpn.net/viewtopic.php?t=23400)

forums.openvpn.net  › home › board index › community project › server administration › configuration

MTU / MSSFix / Fragment questions and help. - OpenVPN Support Forum

TinCanTech wrote:WRT all MTU settings (Also --mssfix &amp; --fragment), unless you know what you are doing I would allow Openvpn to work this out itself. I doubt you have the sort of problem which can be effected by these settings. I see.. does OpenVPN work everything out without any extra commands like --mtu-test?

[](https://community.openvpn.net/MTU%20and%20Fragments)

community.openvpn.net  › MTU and Fragments

MTU and Fragments – community wiki

mssfix can be combined with tun-mtu, or used on its own  - and it will nicely fix all fragment/packet size problems for TCP connections inside an OpenVPN tunnel.

[](https://forum.openwrt.org/t/mtu-dropped-after-vpn-connection/45937)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

MTU Dropped after VPN Connection - Network and Wireless Configuration - OpenWrt Forum

Alright, so I have successful forwarded all the Xbox Traffic through VPN. However there is a problem regarding MTU. Without the VPN, the Xbox tests the connection and the MTU is 1480. After the OpenVPN connection the xbo…

[](https://blog.hambier.lu/post/solving-openvpn-mtu-issues)

blog.hambier.lu  › post › solving-openvpn-mtu-issues

Solving OpenVPN MTU issues - Hambier Blog

[...]  --mssfix and --fragment  can be ideally used together, where --mssfix will try to keep TCP from needing packet fragmentation in the first place, and if big packets come through anyhow (from protocols other than TCP), --fragment will internally fragment them.

[](https://forum.openwrt.org/t/openvpn-proper-mtu-setting-and-cake-settings/70090)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

OpenVPN proper MTU setting (and cake settings)? - Network and Wireless Configuration - OpenWrt Forum

Hi! I&#x27;m trying to figure out, how to properly configure OpenVPN&#x27;s MTU setting(s)... The manual states to leave the default settings alone and let OpenVPN handle everything... –link-mtu n Sets an upper bound on the size of UDP packets which are sent between OpenVPN peers.

[](https://forum.archive.openwrt.org/viewtopic.php?id=72388)

forum.archive.openwrt.org  › viewtopic.php

Topic: Netgear R8000 and OpenVPN

daemon.notice openvpn(nordvpn)[1111]: NOTE: Empirical MTU test completed [Tried,Actual] local-&gt;remote=[1557,1457] remote-&gt;local=[1554,1554] daemon.notice openvpn(nordvpn)[1111]: NOTE: This connection is unable to accommodate a UDP packet size of 1557.  Consider using --fragment or --mssfix options  ...

[](https://forum.openwrt.org/t/mtu-dropped-after-vpn-connection/45937/2)

forum.openwrt.org  › installing and using openwrt › network and wireless configuration

MTU Dropped after VPN Connection - #2 by eduperez - Network and Wireless Configuration - OpenWrt Forum

You have  set &quot;tun_mtu_extra&quot; to 32 bytes, and that is exactly the difference you are experiencing. I&#x27;m no expert and I do not know why you choosed that value, but I would try to lower it and see if everything works.

[](https://www.thegeekpub.com/271035/openvpn-mtu-finding-the-correct-settings/)

thegeekpub.com  › home › blog › openvpn mtu: finding the correct settings

OpenVPN MTU: Finding the Correct Settings - The Geek Pub

The first thing you need to do to fix your OpenVPN MTU problem is to  figure out what your largest MTU actually is. You can do this using the ping command. “ping -f” tells ping not to fragment the packet under any circumstances.

[](https://serverfault.com/questions/1161279/openvpn-accessing-devices-without-pmtud-via-vpn-how-to-allow-1-500-byte-packet)

serverfault.com  › questions › 1161279 › openvpn-accessing-devices-without-pmtud-via-vpn-how-to-allow-1-500-byte-packet

mtu - OpenVPN: Accessing devices without PMTUD via VPN: how to allow 1,500 byte packets to pass through unmodified? - Server Fault

Try changing the MTU in openvpn conf  and if it doesn’t help also try clamping the MSS. The settings are: tun-mtu 1500, mssfix 1460. The MSS should be MTU-40. If that doesn’t help, while your VPN connection still allows to reach other resources ...

[](https://github.com/openwrt/openwrt/issues/8828)

github.com  › openwrt › openwrt › issues › 8828

FS#3830 - OpenVPN Client Using TCP Connection Has MTU or TCPMSS Issue · Issue #8828 · openwrt/openwrt

weikai: OpenVPN Client connects to a TCP based OpenVPN server connects fine. However, the connections to remote network servers connect but can&#x27;t transfer data. The mangle rule with clamp-mss-to-pmtu won&#x27;t receive any data. Setting tcpms...

[](https://github.com/openwrt/packages/issues/15854)

github.com  › openwrt › packages › issues › 15854

OpenVPN is not working with servers using TCP protocol · Issue #15854 · openwrt/packages

OpenVPN client is not working with servers using TCP protocol on OpenWRT Snapshot. It connects fine without any issues but can&#x27;t transfer any data. However, it works when I reduce the tcpmss to 59 but performance is really bad. iptables -t mangle -A POSTROUTING -o tun3 -p tcp -m tcp --tcp-flags SYN,RST SYN -m comment --comment &quot;!fw3: MTU fix&quot; -j TCPMSS --set-mss 59

[](https://forum.archive.openwrt.org/viewtopic.php?id=57322)

forum.archive.openwrt.org  › viewtopic.php

Topic: How to set "MTU"

They also work badly when a link is congested as dropping any fragment in a packet means the whole packet is lost. They also take up CPU time creating the fragments and putting them back together. All in all it is better if the sending end creates the smaller packets in the first place. This means Path MTU Discovery being used and the error message not being blocked!

[](https://forums.openvpn.net/viewtopic.php?t=31893)

forums.openvpn.net  › home › board index › community project › server administration

Ball of confusion: MTU, mssfix and fragment - OpenVPN Support Forum

Is editing the client.ovpn file the right way to deal with MTU volatility? According to my research, a more “elegant” way to solve MTU issues (especially volatility) is to  use mssfix. I tried that, but when I checked the mssfix box on the server and set the fragment size to 1400, all my ...

[](https://oneuptime.com/blog/post/2026-03-20-configure-mtu-ipv4-vpn-tunnels/view)

oneuptime.com  › home › blog › how to configure mtu for ipv4 vpn tunnels to avoid fragmentation

How to Configure MTU for IPv4 VPN Tunnels to Avoid Fragmentation

With a typical Ethernet MTU of 1500 bytes,  subtract the overhead to get the tunnel MTU. # Test with progressively larger packet sizes, using the Don&#x27;t Fragment flag # Start at 1400 and increase until packets start failing ping -M do -s 1400 ...

[](https://www.reddit.com/r/HomeNetworking/comments/urpbpn/mtu_issue_with_ipsec_vpn_via_mss_clamped_router/)

reddit.com  › r/homenetworking › mtu issue with ipsec vpn via mss clamped router

r/HomeNetworking on Reddit: MTU issue with IPSec VPN via MSS clamped router

Keep incrementing packet size until fragmentation of the packets occur  (UDP packets can easily be fragmented unlike TCP). edit: Only on TCP traffic leaving your network should you clamp/adjust MTU.

[](https://github.com/openwrt/openwrt/issues/12112)

github.com  › openwrt › openwrt › issues › 12112

MSS clamping does not play nice with policy-based routing (mwan3, pbr) · Issue #12112 · openwrt/openwrt

Therefore, as the default routing table clearly says &quot;go through WAN, MTU=1500&quot;, it selects MSS=1460. The stock MSS-clamping rule is applied only on forward, but the packet is locally-originated, not forwarded, so it doesn&#x27;t apply. End result: packet with MSS=1460 (which is wrong) goes out. The POSTROUTING chain of the mangle table would still catch it. ... I am reporting an issue for OpenWrt, not an unsupported fork.

[OpenWrt OpenVPN MTU fragmentation fix](https://search.brave.com/search?q=OpenWrt%20OpenVPN%20MTU%20fragmentation%20fix)


> Written with [StackEdit](https://stackedit.io/).
