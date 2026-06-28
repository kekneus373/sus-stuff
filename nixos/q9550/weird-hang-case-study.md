why did my linux pc hang after `May 30 15:43:25 nixos-p4 kernel: hrtimer: interrupt took 2120226 ns` (checked with `journalctl -xb -1`? Specs are:
```
OS: NixOS 25.11 (Xantusia) x86_64
Kernel: Linux 6.12.90
CPU: Intel(R) Pentium(R) D 3.40GHz (2) @ 3.40 GHz
GPU: AMD Radeon 9600
Memory: 1.14 GiB / 1.92 GiB (59%)
```

---

The log entry `hrtimer: interrupt took 2120226 ns` indicates that your system's high-resolution timer interrupt took over **2.1 milliseconds** to complete. While this sounds fast, in the context of a real-time kernel or a system with low latency requirements, this is a massive delay (often called "jitter" or "latency spike"). When the kernel gets stuck waiting for this interrupt, the entire system can freeze or "hang" momentarily.

Given your specific hardware, **this is almost certainly a hardware resource exhaustion issue**, specifically related to your **CPU** and **Memory**.

Here is the breakdown of why this happened:

### 1. The CPU Bottleneck (Most Likely Cause)
Your CPU is an **Intel Pentium D 3.40GHz**.
*   **Architecture:** This is a very old "NetBurst" architecture dual-core CPU (released ~2005). It is notoriously inefficient and runs very hot.
*   **The Problem:** The Pentium D lacks modern power management features and has poor single-thread performance. If the system was under *any* load (compiling a package, indexing files, or even a background NixOS garbage collection), the CPU likely hit 100% usage.
*   **The Result:** The kernel timer interrupt couldn't run immediately because the CPU was busy processing other instructions. The 2.1ms delay is a symptom of the CPU being overwhelmed. On modern CPUs, this interrupt usually takes microseconds; on a Pentium D under load, it can easily spike to milliseconds.

### 2. Memory Pressure
*   **Specs:** You have **1.92 GiB** of RAM, and you were using **59%** (1.14 GiB) at the time of the crash.
*   **The Problem:** NixOS is a modern, heavy distribution. Running a desktop environment, a browser, or even the Nix daemon with only ~1 GiB of free RAM is extremely tight.
*   **The Result:** If the system started swapping (using the hard drive as RAM) because the physical RAM was full, the disk I/O latency would cause the CPU to stall while waiting for data. This "I/O wait" keeps the CPU busy (in a waiting state) and prevents the timer interrupt from running on time.

### 3. Kernel Version Mismatch
*   **Kernel:** You are running **6.12.90**.
*   **The Problem:** This is a very recent (likely bleeding-edge or future) kernel version for such ancient hardware. Modern kernels are optimized for modern instruction sets (AVX2, etc.) and power states that your Pentium D does not support efficiently.
*   **Driver Issues:** Your GPU is an **AMD Radeon 9600**. This card is from the early 2000s. Modern Linux kernels (6.x) have largely dropped support for this hardware or rely on the `radeon` driver which might be struggling with modern kernel internals, potentially causing an interrupt storm or a driver hang that triggered the timer delay.

### How to Confirm and Fix

**1. Check for Swap Activity**
Check if you were swapping right before the hang:
```bash
journalctl -xb -1 | grep -i "swap"
# Or check dmesg for "Out of memory"
journalctl -xb -1 | grep -i "oom"
```

**2. Thermal Throttling**
The Pentium D is famous for overheating. If the CPU hit its thermal limit, it would throttle down drastically, causing the system to hang.
*   Check `sensors` (from `lm_sensors`) logs if available, or physically check if the CPU fan is spinning and the heatsink is dusty.

**3. Reduce Load**
With 2GB of RAM and a Pentium D, running a full NixOS desktop is likely too heavy.
*   **Disable Nix Garbage Collection during use:** NixOS runs periodic GC which spikes CPU/Disk usage.
*   **Use a lighter Window Manager:** Avoid heavy desktop environments like GNOME or KDE. Use **i3**, **Openbox**, or **Sway** (if it compiles for your kernel).

**4. Kernel Parameters**
Try adding kernel parameters to reduce timer frequency (at the cost of responsiveness) which might help on old hardware:
In your NixOS configuration (`configuration.nix`):
```nix
boot.kernelParams = [ "nohz=off" "highres=off" ];
```
*Note: `nohz=off` forces the timer to tick constantly, which can sometimes prevent the "interrupt took X ns" error by keeping the scheduler more predictable, though it increases CPU usage.*

### Conclusion
Your PC hung because the **Pentium D CPU was too slow to handle the interrupt latency** required by the modern 6.12 kernel, likely exacerbated by **memory pressure** and **outdated GPU drivers**. The 2.1ms delay was the "straw that broke the camel's back," causing the kernel to freeze completely.

::search[NixOS Pentium D performance issues]
::search[AMD Radeon 9600 Linux kernel 6.x support]

---

my recently-built, fully repaired pentium d computer based on intel 865 motherboard likes hanging up while idling. literally, it stops serving i/o entirely. this happens to most modern linux's, and while it never occured in windows xp or 7, i can't confirm this behavior on 6.6 on antix with runit - it ran over night w/o glitching out. specs are:
```
OS: NixOS 25.11 (Xantusia) x86_64
Kernel: Linux 6.12.90
CPU: Intel(R) Pentium(R) D 3.40GHz (2) @ 3.40 GHz
GPU: AMD Radeon 9600
Memory: 1.14 GiB / 1.92 GiB (59%)
```
the machine does *not* thermal throttle nor it's dusty or whatever - again, it's fresh. also, no ram issues apparently - have been running the test for around 30 minutes and, apart from the mentioned freeze, nothing else's happened...

---

The fact that the machine hangs while **idling** and serves **no I/O** points directly to a specific hardware quirk of the **Intel 865 chipset** and the **Pentium D** when paired with a modern Linux kernel (6.12+).

Since you ruled out heat, RAM, and heavy load, the culprit is almost certainly the **APIC/Local Timer interrupt storm** combined with the **`nohz` (tickless kernel)** subsystem failing to wake the CPU correctly on legacy hardware.

### The Root Cause: The "Tickless" Kernel vs. Legacy APIC
Modern kernels (like your 6.12.90) use a "tickless" mode (`NO_HZ`) to save power. When the CPU is idle, it tells the hardware timer to stop firing interrupts until an event (like a mouse click) occurs.

The **Intel 865 chipset** and early Pentium D CPUs have a known, nasty bug where:
1.  The CPU enters a low-power C-state (idle).
2.  The kernel tells the APIC timer to stop.
3.  Due to a race condition in the legacy APIC implementation, the timer either **never wakes up** or fires a "storm" of spurious interrupts that the CPU can't process.
4.  The kernel scheduler freezes. The system looks "hung" because the CPU is waiting for a timer interrupt that never arrives or is stuck in an interrupt loop.

This explains why:
*   **It happens while idling:** The kernel is trying to put the CPU to sleep.
*   **Windows XP/7 worked:** They used different power management logic (ACPI S-states) and often didn't use the aggressive "tickless" mode in the same way, or the drivers handled the legacy APIC differently.
*   **antiX (Kernel 6.6) works:** Kernel 6.6 is older and likely uses a less aggressive idle strategy or has not yet introduced the specific regression affecting the 865 chipset in the 6.12+ series.

### Why the `hrtimer: interrupt took 2120226 ns` message appears
That log entry is the **symptom**, not the cause. The kernel tried to process the timer interrupt, but the CPU was either stuck in a low-power state it couldn't exit, or the interrupt handler itself was looping infinitely due to the hardware bug. The "2.1ms" delay is the kernel timing out while waiting for the hardware to respond.

---

### Solutions for NixOS on Intel 865/Pentium D

Since you are on NixOS, you can patch this easily in `configuration.nix`. You need to force the kernel to **stop using the tickless mode** and **disable the high-resolution timer** on this specific hardware.

#### 1. Disable `NO_HZ` and High-Res Timer (The Primary Fix)
Add these parameters to your kernel boot line. This forces the system to run a constant timer tick, preventing the "sleep" state that triggers the freeze.

```nix
boot.kernelParams = [
  "nohz=off"
  "highres=off"
  "clocksource=hpet"
];
```
*   **`nohz=off`**: Disables tickless idle mode. The CPU will stay "awake" and tick constantly, but it will be stable.
*   **`highres=off`**: Disables high-resolution timers which can cause issues on old APICs.
*   **`clocksource=hpet`**: Forces the use of the High Precision Event Timer, which is often more stable on the 865 chipset than the TSC (Time Stamp Counter).

#### 2. Disable C-States (Power Management)
If the above doesn't work, force the CPU to stay in C0 (active) state. The Pentium D's C-states are notoriously buggy on Linux.

```nix
boot.kernelParams = [
  "intel_idle.max_cstate=0"
  "processor.max_cstate=1"
  "idle=poll"
];
```
*   **`idle=poll`**: This is the nuclear option. It prevents the CPU from entering *any* sleep state. It will run hotter and use slightly more power, but it guarantees the timer interrupts keep firing.

#### 3. Check the APIC Mode
Sometimes forcing the use of the legacy PIC instead of the APIC helps, though this is less common on 64-bit kernels.
```nix
boot.kernelParams = [ "apic=nomsi" "pci=nomsi" ];
```

### Recommended Configuration Snippet
Here is the most likely fix for your specific setup. Add this to your `configuration.nix`:

```nix
{
  # ... your other config
  
  boot.kernelParams = [
    "nohz=off"
    "highres=off"
    "clocksource=hpet"
    "intel_idle.max_cstate=0"
    "processor.max_cstate=1"
  ];
  
  # Optional: If you have a dedicated swap file/partition, ensure it's active
  # to prevent any OOM (Out of Memory) stutters, though less likely the cause here.
}
```

### Why antiX worked with 6.6
antiX is designed for legacy hardware and often defaults to `nohz=off` or uses a kernel patchset specifically tuned for old chipsets. The 6.12 kernel likely introduced a regression in the `tick-sched` code that assumes modern interrupt controllers, which the 865 lacks.

**Next Step:** Apply the `nohz=off` and `clocksource=hpet` parameters. If that works, you can try removing `clocksource=hpet` one by one to find the minimal set, but on an 865, keeping `nohz=off` is usually mandatory for stability.

::search[Intel 865 chipset Linux kernel hang idle]
::search[Pentium D nohz=off kernel parameter stability]
