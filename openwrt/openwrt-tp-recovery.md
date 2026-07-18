Here are the quick  `atftp`  setup instructions for NixOS, tailored for flashing OpenWrt via TFTP (often used for  `tp_recovery.bin`).

### 1. Without Installing (Temporary/Ad-hoc)

If you have the NixOS shell or a Nix-enabled terminal, you can run the server without installing it globally into your system configuration. This is great for quick, one-off flashes.

**Step A:**  Open a terminal.
**Step B:**  Enter the Nix shell for  `atftpd`:

```bash
nix-shell -p atftp
```

**Step C:**  Place your  `tp_recovery.bin`  in the current directory (or a subdirectory).
**Step D:**  Start the server:

```bash
sudo atftpd --daemon --port 69 /tmp/tftpboot
```

_<mark>Note:</mark>  Make sure to disable firewall temporarily:_

```bash
sudo systemctl stop firewall.service
```

----------

### 2. With Installing (Persistent System Service)

If you need this frequently, add it to your  `configuration.nix`.

**Step A:**  Edit your  `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # Enable the TFTP server service
  services.atftpd = {
    enable = true;
    # Directory to serve files from (e.g., /var/lib/atftp)
    root = "/var/lib/atftp";
    # Additional arguments (optional)
    extraOptions = [ "-m 10" ];
  };

  # Ensure the directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/atftp 0755 root root -"
  ];

  # Open the firewall for TFTP (UDP 69)
  networking.firewall.allowedUDPPorts = [ 69 ];
}
```

**Step B:**  Rebuild your system:

```bash
sudo nixos-rebuild switch
```

**Step C:**  Place your  `tp_recovery.bin`:

```bash
sudo cp tp_recovery.bin /var/lib/atftp/
# Ensure the router can reach this IP
```

----------

### 3. Quick Router Flashing Checklist

Since you are flashing OpenWrt:

1.  **Static IP:**  Set your computer's Ethernet port to a static IP (e.g.,  `192.168.0.66`  or  `192.168.1.66`) matching the router's expected recovery subnet.
2.  **File Naming:**  Some routers require the file to be named exactly  `tp_recovery.bin`  or  `factory.bin`.
3.  **Timing:**  Power on the router and hold the reset button (or trigger the specific recovery mode)  _after_  the server is running but  _before_  the router times out its DHCP/TFTP request (usually within 30 seconds).
4. **When done, kill the daemon:**:
```bash
sudo killall atftpd
```

*To allow uploads in **atftpd**, make sure the served directory is writable for the user running the server, and note that atftpd can return “Access violation” when the service is restricted from writing. Also ensure the target file/directory permissions let uploads succeed (one setup requires the file to already exist, created with `touch`, and to be world-writable).*

> Written with [StackEdit](https://stackedit.io/).
