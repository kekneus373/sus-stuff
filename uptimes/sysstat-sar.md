**On a standard Ubuntu Server, there is no built-in persistent history of load average across boots** unless you have monitoring tools like `sysstat` (which provides `sar`) installed and enabled.

### Current load average (since last boot)
These show the load average **for the current uptime**:

```bash
uptime

# Or just the load averages:
cat /proc/loadavg

# Or:
top -bn1 | head -n1
```

### Historical load average from previous boots / days

The most common and effective tool is **`sar`** from the `sysstat` package.

1. **Install and enable sysstat** (if not already done):

```bash
sudo apt update
sudo apt install sysstat

# Enable data collection (edit the config)
sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat

# Restart the service
sudo systemctl restart sysstat
```

2. **View load average history**:

```bash
# Load average for today
sar -q

# Load average for yesterday (previous day)
sar -q -f /var/log/sysstat/sa$(date -d yesterday +%d)

# Or specify a specific day (e.g., the 15th)
sar -q -f /var/log/sysstat/sa15
```

**Example output** (key columns: `ldavg-1`, `ldavg-5`, `ldavg-15`):

```
Linux ...  (CPU count)
HH:MM:SS   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15
...
Average:         X       XXX     0.45      0.67      0.82
```

- `ldavg-1/5/15` = load averages over 1, 5, and 15 minutes at each sampling point.

### Other options

- **Check boot times** first (to know when the previous boot ended):

```bash
last reboot
journalctl --list-boots
```

- **If sysstat is not available**, you might find some info in logs, but it's not reliable for load averages:

```bash
sudo journalctl -b -1 | grep -i load   # previous boot logs
```

For ongoing monitoring, `sysstat` + `sar` is the recommended solution on Ubuntu servers. Once enabled, it collects data automatically every 10 minutes by default.
