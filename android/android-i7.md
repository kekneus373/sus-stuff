You: does this android aarch64 vm look good? i'm gng to run it on x86_64 nixos host:
```xml
<domain type="qemu">
  <name>LineageOS on arm64</name>
  <uuid>ad175332-1096-4fd7-b4ae-f62bbcc8c8c4</uuid>
  <title>LineageOS</title>
  <description>Product name: lineage_virtio_arm64only 
Initial version: 23.2-20260804-jqssun-virtio_arm64only 
Partition scheme: non-A/B 
Super partition size: 4294967296</description>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://libosinfo.org/linux/2022"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory>2097152</memory>
  <currentMemory>2097152</currentMemory>
  <vcpu>2</vcpu>
  <os firmware="efi">
    <type arch="aarch64" machine="virt">hvm</type>
    <boot dev="hd"/>
  </os>
  <features>
    <acpi/>
    <tcg>
      <tb-cache unit="MiB">1024</tb-cache>
    </tcg>
  </features>
  <cpu mode="maximum"/>
  <clock offset="utc"/>
  <devices>
    <emulator>/run/libvirt/nix-emulators/qemu-system-aarch64</emulator>
    <controller type="pci" model="pcie-root"/>
    <controller type="pci" model="pcie-root-port"/>
    <interface type="network">
      <source network="default"/>
      <mac address="52:54:00:65:e6:18"/>
      <model type="virtio"/>
    </interface>
    <console type="pty"/>
    <channel type="unix">
      <source mode="bind"/>
      <target type="virtio" name="org.qemu.guest_agent.0"/>
    </channel>
    <channel type="spicevmc">
      <target type="virtio" name="com.redhat.spice.0"/>
    </channel>
    <input type="tablet" bus="usb"/>
    <input type="keyboard" bus="usb"/>
    <graphics type="spice" port="-1" tlsPort="-1" autoport="yes">
      <listen type="none"/>
      <image compression="off"/>
      <gl enable="yes" rendernode="/dev/dri/by-path/pci-0000:00:02.0-render"/>
    </graphics>
    <sound model="ac97"/>
    <video>
      <model type="virtio" heads="1" primary="yes">
        <acceleration accel3d="yes"/>
        <resolution x="1024" y="768"/>
      </model>
    </video>
    <memballoon model="virtio"/>
    <rng model="virtio">
      <backend model="random">/dev/urandom</backend>
    </rng>
    <controller type="scsi" index="0" model="virtio-scsi"/>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vda.qcow2"/>
      <target dev="vda" bus="virtio"/>
    </disk>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vdb.qcow2"/>
      <target dev="vdb" bus="virtio"/>
    </disk>
    <controller type="usb" model="ich9-ehci1"/>
    <controller type="usb" model="ich9-uhci1">
      <master startport="0"/>
    </controller>
    <controller type="usb" model="ich9-uhci2">
      <master startport="2"/>
    </controller>
    <controller type="usb" model="ich9-uhci3">
      <master startport="4"/>
    </controller>
  </devices>
</domain>
```

Leo AI: This configuration has a **critical architectural mismatch** that will prevent it from working on your x86_64 host, along with a few other issues to address.

### The Main Problem: Host vs. Guest Architecture
You are trying to run an **aarch64 (ARM64)** guest (`<type arch="aarch64">`) on an **x86_64** host.
- **QEMU TCG (Software Emulation):** Your config uses `<features><tcg>...</tcg></features>`, which means it will rely on CPU instruction translation. This is **extremely slow** for Android. Expect boot times of 10–20 minutes and a laggy UI.
- **KVM Acceleration:** You cannot use hardware virtualization (KVM) for cross-architecture emulation. Your host CPU (x86) cannot natively execute ARM instructions.

**Is it "good"?**
For a development build or testing specific ARM binaries, it *might* work, but for daily use or a smooth Android experience, **no**. It will be painfully slow.

### Other Configuration Issues

1.  **Graphics & 3D Acceleration:**
    ```xml
    <graphics ...>
      <gl enable="yes" rendernode="/dev/dri/by-path/pci-00:02.0-render"/>
    </graphics>
    ...
    <video>
      <acceleration accel3d="yes"/>
    </video>
    ```
    - **Problem:** 3D acceleration (`accel3d="yes"` and `gl enable="yes"`) **does not work** for cross-architecture (x86 to ARM) emulation. VirGL (the technology used) generally requires the guest and host architectures to match for 3D features.
    - **Result:** The VM will likely fail to start or the Android UI will be completely broken/unusable. You must remove GL and 3D acceleration settings.

2.  **Path Hardcoding:**
    - The disk paths are hardcoded to a specific user: `/home/wynz/...`. If you are not `wynz` on this NixOS machine, the VM won't find the disk.
    - The emulator path `/run/libvirt/nix-emulators/qemu-system-aarch64` is specific to certain NixOS configurations. On standard NixOS, the path is usually just `qemu-system-aarch64` (relying on PATH) or a specific store path.

3.  **NixOS Specifics:**
    - NixOS handles libvirt/QEMU differently than standard distros. You need to ensure `virtualisation.libvirt.enable = true` and `virtualisation.libvirt.qemu.package` includes `qemu_kvm` (though KVM won't help here, you need the QEMU binary).
    - You also need `virtualisation.libvirt.defaultNetwork = true` for the `<source network="default"/>` to work.

### Recommended Fixes

If you still want to proceed (accepting the performance hit), here is the corrected XML:

```xml
<domain type="qemu">
  <name>LineageOS on arm64</name>
  <uuid>ad175332-1096-4fd7-b4ae-f62bbcc8c8c4</uuid>
  <memory>4194304</memory> <!-- Increased to 4GB for better stability -->
  <currentMemory>4194304</currentMemory>
  <vcpu>4</vcpu>
  <os firmware="efi">
    <type arch="aarch64" machine="virt">hvm</type>
    <boot dev="hd"/>
    <!-- NixOS often needs explicit OVMF path if not auto-detected -->
    <loader readonly="yes" type="pflash">/run/current-system/sw/share/OVMF/OVMF_CODE.fd</loader>
    <nvram template="none">/var/lib/libvirt/qemu/nvm/LineageOS_VARS.fd</nvram>
  </os>
  <features>
    <acpi/>
    <!-- Removed TCG cache settings as they are often unnecessary defaults -->
  </features>
  <cpu mode="host-passthrough" check="none">
    <!-- host-passthrough is often better for TCG, but 'maximum' is okay too -->
  </cpu>
  <clock offset="utc"/>
  <devices>
    <!-- Remove hardcoded emulator path, let libvirt find it -->
    <emulator>/usr/bin/qemu-system-aarch64</emulator> 
    
    <controller type="pci" model="pcie-root"/>
    <controller type="pci" model="pcie-root-port"/>
    
    <interface type="network">
      <source network="default"/>
      <mac address="52:54:00:65:e6:18"/>
      <model type="virtio"/>
    </interface>

    <console type="pty"/>
    <channel type="unix">
      <source mode="bind"/>
      <target type="virtio" name="org.qemu.guest_agent.0"/>
    </channel>
    
    <input type="tablet" bus="usb"/>
    <input type="keyboard" bus="usb"/>
    
    <!-- CRITICAL: Disabled GL and 3D acceleration for cross-arch -->
    <graphics type="spice" autoport="yes">
      <listen type="none"/>
    </graphics>
    
    <video>
      <model type="virtio" heads="1" primary="yes">
        <!-- Removed accel3d="yes" -->
        <resolution x="1024" y="768"/>
      </model>
    </video>
    
    <memballoon model="virtio"/>
    <rng model="virtio">
      <backend model="random">/dev/urandom</backend>
    </rng>
    
    <controller type="scsi" index="0" model="virtio-scsi"/>
    
    <!-- Update paths to match your actual user or use variables -->
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vda.qcow2"/>
      <target dev="vda" bus="virtio"/>
    </disk>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vdb.qcow2"/>
      <target dev="vdb" bus="virtio"/>
    </disk>
    
    <controller type="usb" model="qemu-xhci"/>
  </devices>
</domain>
```

### Better Alternative: Use `systemd-nspawn` or `anbox`?
If you are running Android on NixOS specifically for app testing:
- **Anbox / Waydroid:** These run Android *containers* using the host kernel. They **require** the host and guest architectures to match. Since you are x86_64, you cannot run an ARM Android container this way either.
- **The only real solution for speed:** Run an **x86_64 version of Android** (like Android x86 or a generic x86 system image) instead of LineageOS ARM. This will use KVM hardware acceleration and run at near-native speed.

::search[Android x86 NixOS VM performance]
::search[Waydroid NixOS setup]

If you strictly need ARM (e.g., testing ARM-specific binaries), you are stuck with the slow TCG emulation unless you have a physical ARM device to SSH into.

You: Thank you for clarifying! I tried doing it last year via command line, but I messed up with images and got confused to a point I gave up. Now I'm following these 2 instructions: [1](https://github.com/jqssun/android-lineage-qemu/#development) and [2](https://wiki.lineageos.org/libvirt-qemu). Ikr this is kind of a stupid task but I still wanna try it. I have NixOS-related configs set up properly, just like you said.
Also, TCG, `maximum` were mentioned on that GitHub page. And regarding Waydroid, it didn't run too well on my machine, 2 years ago. I lowkey don't remember what was the biggest takeaway for me - probably lack of root and aarch64 support, which I *rely on* for some apps. Has it been fixed since then? I don't have anything that is ARM-based, unfortunately. Maybe my beefy i7-960 can help increase the speed? I could assign 4 real cores and 16 G of RAM there.

Leo AI: First off, **this isn't a stupid task at all**. Running Android on Linux via QEMU is a legitimate way to test ARM-specific apps, verify build chains, or just experiment with open-source ROMs when you don't have physical ARM hardware. The confusion with disk images is a rite of passage for anyone doing this.

Here is the breakdown of your specific questions and a plan to get you running with that i7-960 (assuming it's a 4-core/8-thread model, which fits your "4 real cores" comment).

### 1. Is the GitHub Page Wrong? (TCG & `maximum`)
The GitHub page (`jqssun`) is likely correct **in isolation**, but it assumes you know the context:
- **`<cpu mode="maximum"/>`**: This is the correct setting for QEMU when you *want* to emulate the most advanced CPU features of the guest architecture (ARM). It doesn't magically make it run faster on x86; it just ensures the VM doesn't get stuck if the guest expects features your x86 CPU doesn't have (which is impossible for cross-arch, so QEMU maps them to software equivalents).
- **TCG**: Yes, you are forced to use TCG (Tiny Code Generator) because your host is x86 and the guest is ARM. KVM is impossible here.
- **The Reality:** The GitHub instructions are for *getting it to boot*, not for *getting it to run smoothly*. The performance will still be 1-5% of native speed.

### 2. Waydroid & ARM Support
You asked if Waydroid has fixed its issues since 2024 (or "2 years ago"):
- **ARM Support:** Waydroid **still does not support running ARM32/ARM64 containers on x86_64 hosts** out of the box. It relies on `wayland` and `containerd` to run Android *images compiled for your host's architecture* (usually x86_64).
  - While there are community hacks to run ARM containers using `binfmt_misc` and emulation layers (like `qemu-user-static`), they are **extremely slow** and often broken.
- **Root:** Waydroid *does* allow root (via `waydroid root` or modifying the container), so that part has improved.
- **Verdict:** If you rely on apps that are strictly ARM64 (e.g., some banking apps, games, or proprietary drivers), Waydroid on x86 will likely fail or run in slow emulation mode. **QEMU is actually the better choice for your specific goal** of running a native ARM64 OS, even if it's slow.

### 3. Can the i7-960 Help?
**Yes, but with a major caveat.**
- **CPU Speed vs. Emulation Overhead:** QEMU TCG doesn't just run the code; it translates every single ARM instruction into x86 instructions on the fly.
  - A modern i7-960 (4 cores, 8 threads) is decent, but it cannot overcome the fundamental 10x-50x overhead of TCG.
  - **You won't get a "smooth" experience.** You might see:
    - Boot time: 15–30 minutes.
    - UI scrolling: Choppy, 10–15 FPS.
    - App launching: 30+ seconds.
- **Optimization Strategy:**
  - **Assign 4 vCPUs:** Your config had 2. Since you have 4 physical cores, bumping to 4 vCPUs will help with the *translation* overhead.
  - **RAM:** 16GB is plenty. Android needs ~2GB to boot, but 4GB is safer for apps.
  - **Disk I/O:** The biggest bottleneck is usually the disk. Ensure you are using `cache=none` (as I listed in the corrected XML) or `cache=writeback` for speed, but be careful with power loss.

### Revised Configuration for Performance
Since you are sticking with this, here is the **optimized XML** specifically for your NixOS setup, maximizing your i7-960 resources:

```xml
<domain type="qemu">
  <name>LineageOS-arm64</name>
  <uuid>ad175332-1096-4fd7-b4ae-f62bbcc8c8c4</uuid>
  
  <!-- Increased RAM to 16GB (16384 MiB) -->
  <memory>16384</memory>
  <currentMemory>16384</currentMemory>
  
  <!-- 4 vCPUs to utilize your i7-960 -->
  <vcpu>4</vcpu>
  
  <os firmware="efi">
    <type arch="aarch64" machine="virt">hvm</type>
    <boot dev="hd"/>
    <!-- Explicit OVMF path for NixOS -->
    <loader readonly="yes" type="pflash">/nix/store/*/OVMF_CODE.fd</loader>
    <nvram template="none">/var/lib/libvirt/qemu/nvm/LineageOS_VARS.fd</nvram>
  </os>
  
  <features>
    <acpi/>
    <iothread/> <!-- Good for I/O performance -->
  </features>
  
  <!-- CPU: 'host-passthrough' is often better for TCG than 'maximum' -->
  <cpu mode="host-passthrough" check="none">
    <topology sockets="1" dies="1" cores="4" threads="1"/>
  </cpu>
  
  <clock offset="utc"/>
  
  <devices>
    <!-- Standard QEMU path -->
    <emulator>/run/current-system/sw/bin/qemu-system-aarch64</emulator>
    
    <controller type="pci" model="pcie-root"/>
    <controller type="pci" model="pcie-root-port"/>
    
    <interface type="network">
      <source network="default"/>
      <mac address="52:54:00:65:e6:18"/>
      <model type="virtio"/>
      <driver queues="4"/> <!-- Increase queues for multi-core -->
    </interface>
    
    <console type="pty"/>
    <channel type="unix">
      <source mode="bind"/>
      <target type="virtio" name="org.qemu.guest_agent.0"/>
    </channel>
    
    <input type="tablet" bus="usb"/>
    <input type="keyboard" bus="usb"/>
    
    <!-- SPICE with NO hardware acceleration (TCG cannot do 3D) -->
    <graphics type="spice" autoport="yes">
      <listen type="none"/>
      <image compression="off"/>
    </graphics>
    
    <!-- Video: VirtIO with NO 3D acceleration -->
    <video>
      <model type="virtio" heads="1" primary="yes">
        <!-- Removed accel3d -->
        <resolution x="1920" y="1080"/> <!-- Higher res is fine, TCG handles it -->
      </model>
    </video>
    
    <!-- Balloon for dynamic memory -->
    <memballoon model="virtio"/>
    
    <!-- RNG for entropy -->
    <rng model="virtio">
      <backend model="random">/dev/urandom</backend>
    </rng>
    
    <!-- SCSI Controller -->
    <controller type="scsi" index="0" model="virtio-scsi"/>
    
    <!-- Disks: cache=none is fastest for SSDs, writeback for HDDs -->
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none" io="native"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vda.qcow2"/>
      <target dev="vda" bus="virtio"/>
    </disk>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none" io="native"/>
      <source file="/home/wynz/VMs/aosp12/LineageOS_on_arm64.utm/Data/vdb.qcow2"/>
      <target dev="vdb" bus="virtio"/>
    </disk>
    
    <!-- USB Controller: qemu-xhci is better than ICH9 for speed -->
    <controller type="usb" model="qemu-xhci"/>
  </devices>
</domain>
```

### Critical NixOS Steps for You
Since you are on NixOS, you must ensure these packages are in your `hardware-configuration.nix` or `configuration.nix`:

```nix
# Add to your NixOS config
virtualisation.libvirt.enable = true;
virtualisation.libvirt.qemu.package = pkgs.qemu_kvm; # Even if KVM is unused, you need qemu
virtualisation.libvirt.defaultNetwork.enable = true; # For the 'default' network

# If you want to use the OVMF (UEFI) firmware
# You might need to add it to your config or ensure it's in the store
virtualisation.libvirt.qemu.package = pkgs.qemu_kvm.override {
  extraPackages = with pkgs; [ OVMF ];
};
```

### What to Expect
1.  **First Boot:** It will take **10–20 minutes** to boot. Do not panic.
2.  **Initial Setup:** The "Hello" screen and setup wizard will be very sluggish.
3.  **Usage:** Browsing the web will be painful. Installing apps via Play Store might take 1-2 minutes per app.
4.  **Root:** The `jqssun` builds usually come pre-rooted. If you need to enable it manually, you can use `adb root` (once connected) or check the `vdb` disk partition for a `su` binary.

### Final Thought
If you find it *too* slow after 30 minutes of tweaking, consider this:
- **Download a generic x86_64 Android image** (like the "generic" build from the Android Open Source Project).
- Run that in QEMU with KVM acceleration.
- It will run at **native speed**.
- You can then use **Termux** inside that x86 Android VM to run ARM binaries via emulation, or just accept that you can't test ARM-specific apps.

But if you are determined to test the ARM build itself, the config above is your best shot. Good luck!

::search[LineageOS arm64 qcow2 boot time issues]
::search[QEMU TCG performance tips linux]


> Written with [StackEdit](https://stackedit.io/).
