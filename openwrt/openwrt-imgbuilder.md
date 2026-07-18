Yes, you can define `make` environment variables in a file instead of passing them directly on the command line. This is a common practice, especially for complex builds like OpenWrt, to keep your commands clean and reusable.

### How to do it

You have a few standard options:

**1. Using a `.config` file (OpenWrt Specific)**
OpenWrt's build system relies heavily on the `.config` file in your build root. While this is primarily for `menuconfig` selections, many configuration options (including some that act like environment variables) are stored here.
*   Run `make menuconfig` to set options.
*   These settings are saved to `./.config`.
*   When you run `make`, it automatically reads this file.

**2. Using a Makefile or `include` file**
You can create a custom file (e.g., `my_vars` or `build_env`) to store your variables and include it in your main `Makefile` or source it in your shell before running the command.

*   **Create a file** (e.g., `build_env`):
    ```bash
    # build_env
    PROFILE=tl-wr941nd-v6
    CONFIG_IPV6=n
    EXTRA_CFLAGS=-Os
    ```

*   **Option A: Source it in your shell (Bash/Zsh)**
    This sets them as environment variables for the current session.
    ```bash
    source build_env
    make image
    ```

*   **Option B: Pass them explicitly to `make`**
    You can tell `make` to read a specific file if you structure it correctly, but the most robust way with OpenWrt is often to pass variables directly or rely on the `.config`. However, standard `make` supports reading variables from a file if you use the `include` directive inside a Makefile.

**3. Using `make`'s `include` directive (inside a Makefile)**
If you are creating a custom Makefile to wrap the build:
```makefile
include build_env

all:
	$(MAKE) image
```
*Note: Variables defined in an included Makefile are Make variables, not necessarily shell environment variables, unless you export them.*

**4. The `export` keyword**
If you put these in a script or Makefile, ensure they are exported if the sub-process needs them:
```bash
export PROFILE=tl-wr941nd-v6
export CONFIG_IPV6=n
make image
```

### Important Note on `CONFIG_` Variables
In OpenWrt, variables starting with `CONFIG_` (like `CONFIG_IPV6=n`) are technically **build configuration options** handled by the `.config` file and `menuconfig`, not simple environment variables.

If you pass `CONFIG_IPV6=n` directly on the command line:
`make image CONFIG_IPV6=n`

It works for that specific run. To make it permanent without command-line arguments:
1.  Run `make menuconfig`.
2.  Navigate to **Network** -> **IPv6** and disable it.
3.  Save and exit.
4.  This updates your `.config` file, and the next `make image` will automatically have IPv6 disabled without extra arguments.

### Summary Table

| Method | Best For | Persistence |
| :--- | :--- | :--- |
| **`.config` file** | OpenWrt build options (e.g., `CONFIG_IPV6`) | Permanent (until `menuconfig` changes it) |
| **Shell script** | Setting `PROFILE` or custom paths | Session-based (or permanent if added to `.bashrc`) |
| **`make` include** | Custom build logic | Permanent (in the Makefile) |
| **Command line** | One-off tests | None (temporary) |

If you are specifically trying to avoid typing `PROFILE=...` or `CONFIG_...=n` every time, **modifying the `.config` file via `menuconfig`** is the intended "file-based" method for OpenWrt. For `PROFILE`, you can often set a default in your local `Makefile` or simply create a shell alias:

```bash
alias openwrt-build='make image PROFILE=tl-wr941nd-v6 CONFIG_IPV6=n'
```

---

asix ax88772 linux
================

The **ASIX AX88772** USB Ethernet adapter is **natively supported** in the Linux kernel via the built-in **`asix`** driver module, requiring no manual installation on modern distributions. The driver supports multiple variants including the **AX88772**, **AX88772A**, **AX88772B**, and **AX88772C**, and is included in the mainline kernel source under `drivers/net/usb/asix_devices.c`.

For most users, the device functions as **Plug & Play** immediately upon connection. If manual compilation is necessary for older kernels, the driver source can be built using standard kernel module tools, though this is rarely required today. The driver handles USB 2.0 Fast Ethernet speeds (up to 100Mbps) and supports features such as **autoselect media**, **full/half-duplex** modes, and **promiscuous mode**.
> Written with [StackEdit](https://stackedit.io/).
