# ------------------------------------------------------------------------
# ---        NixOS-HP configuration file from 24.08.2026 20:04.        ---
# ------------------------------------------------------------------------
# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

# Include Xprinter XP-80TS driver.

let
  xprinter-driver = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "fnltochka";
      repo = "xprinter-cups-nix";
      rev = "main";
      sha256 = "sha256-tt6m/dzDBBp5cLfj9wWiQE2oCnj0d8UpYEQY/dhOkVM=";
    }
  ) {};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "mem_sleep_default=deep" "i915.enable_psr=0" "i915.enable_fbc=0" "i915.enable_dc=0" "intel_iommu=igfx_off" ]; # Some iHD 5500 quirks for less freezes.
    kernelModules = [ "zram" ];
    kernel.sysctl."vm.swappiness" = 15;
  };

  # Enable zram swap.
  zramSwap.enable = true;

  # Network storage.
  fileSystems."/mnt/smb0" = {
      device = "//hsvuldo-server/borg";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/sc" = {
      device = "//hsvuldo-server/TrueNAS-SC";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };
  fileSystems."/mnt/sus" = {
      device = "//hsvuldo-server/sus";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Font choice.
  console = {
    font = "${lib.getBin pkgs.terminus_font}/share/consolefonts/ter-v20n.psf.gz";
    useXkbConfig = true; # Use xkb.options in tty.
  };
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ pkgs.terminus_font ]; # Bigger TTY fonts.
  };

  # Hardware setup.
  hardware = {
    graphics = {
      extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver intel-compute-runtime-legacy1 ]; # Include legacy drivers in case the newer one breaks.
      #enable32Bit = true; # For Windows games.
    };
    bluetooth = {
      enable = true; # Bluetooth support.
      powerOnBoot = true; # Power up the default BT controller on boot.
    };
    cpu.intel.updateMicrocode = true;
    intel-gpu-tools.enable = true;
    enableRedistributableFirmware = true;
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME="iHD"; }; # Choose preferred GPU driver.

  # Enable the X11 windowing system. 
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
    };
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasma";
    };
    desktopManager.plasma6.enable = true;
  };

  # Enable CUPS to print documents, Avahi Bonjour to discover network printers.
  services = {
    #avahi = {
     # enable = true;
     # nssmdns4 = true;
     # openFirewall = true;
    #}; 
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip xprinter-driver ];
    };
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wynz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "camera" "media" "audio" "video" "render" "kvm" "lp" "lpadmin" "wireshark" ];
    packages = with pkgs; [
      aria2
      apktool
      android-tools
      uget
      yt-dlp
      brave
      thunderbird
      bleachbit
      brasero
      gnome-disk-utility
      kdePackages.kamoso
      kdePackages.qrca
      borgbackup
      nextcloud-client
      doublecmd
      meld
      kdePackages.kompare
      czkawka
      curtail
      libreoffice-qt6-fresh
      onlyoffice-desktopeditors
      vlc
      handbrake
      mediainfo-gui
      audacity
      easyeffects
      ffmpeg-full
      obs-studio
      pdfarranger
      localsend
      filezilla
      rustdesk-flutter
      remmina
      angryipscanner
      gimp3
      pinta
      krita
      luanti-client
      calibre
      kdePackages.kdenlive
      kdePackages.falkon
      kdePackages.filelight
      kdePackages.ktorrent
      kdePackages.kalk
      kdePackages.kclock
      kdePackages.kcolorchooser
      kdePackages.kcharselect
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
      wget
      mc
      unrar-wrapper
      p7zip
      zip
      bc
      file
      links2
      htop
      psmisc
      microcode-intel
      intel-gpu-tools
      inteltool
      intelmetool
      mesa-demos
      libva-utils
      putty
      screen
      cifs-utils
      glib
      lm_sensors
      nmap
      host
      ethtool
      net-tools
      wol
      smartmontools
      inxi
      fastfetch
      ventoy-full
      ntfs3g
      exfatprogs
      dosfstools
      appimage-run
      libmtp
      libgphoto2
      gphoto2fs
      kdePackages.kamera
      anydesk
      bottles
    ];

  # Allow Unfree packages + Anti-Anti-Ventoy overlay.
  nixpkgs.overlays = [
    (self: super: {
      ventoy = super.ventoy.overrideAttrs (old: {
        meta = old.meta // {
          knownVulnerabilities = [];
          insecure = false;
        };
      });
    })
  ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "microcode-intel"
      "anydesk"
      "ventoy"
      "printer-driver-xprinter"
   ];

  # Virtualization support.
  environment.localBinInPath = true;
  virtualisation.libvirtd= {
    enable = true;
  };

  # Useful utilites.
  programs = {
    virt-manager.enable = true;
    dconf.enable = true;
    vim = {
      enable = true;
      package = pkgs.vim-full;
      defaultEditor = true;
    };
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
      dumpcap.enable = true;
    };
    tmux.enable = true;
    gphoto2.enable = true;
  };
  services.geoclue2.enable = true;

  # Remote filesystems support.
  services.gvfs.enable = true;
  security.wrappers."mount.cifs" = {
    program = "mount.cifs";
    source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Unlock KWallet on login.
  security.pam.services."wynz".kwallet.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Fix touchpad hang after waking up
  systemd.services.rtouchpad = {
    description = "Unload touchpad module before sleeping";
    enable = true;
    wantedBy = [ "suspend.target" "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    before = [ "suspend.target" "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    unitConfig = {
      # Tells systemd that this service is related to sleep events
      StopWhenUnneeded = true;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.util-linux}/bin/logger rtouchpad: suspending, unloading psmouse && ${pkgs.kmod}/bin/modprobe -r psmouse'";
    };
  };
  systemd.services.atouchpad = {
    description = "Inject touchpad module after resuming";
    enable = true;
    wantedBy = [ "suspend.target" "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    after = [ "suspend.target" "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    unitConfig = {
      # Tells systemd that this service is related to sleep events
      StopWhenUnneeded = true;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.util-linux}/bin/logger atouchpad: resuming, loading psmouse && ${pkgs.kmod}/bin/modprobe psmouse'";
    };
  };

  # In case units above break.
  environment.etc."systemd/system-sleep/retouchpad" = {
    enable = false;
    text = ''
      #!/bin/sh
      case "$1" in
        pre)
          ${pkgs.util-linux}/bin/logger "retouchpad: suspending, unloading psmouse"
          ${pkgs.kmod}/bin/modprobe -r psmouse
          ;;
        post)
          ${pkgs.util-linux}/bin/logger "retouchpad: resuming, reloading psmouse"
          ${pkgs.kmod}/bin/modprobe psmouse
          ;;
      esac
    '';
  };
 
  # Better power management.
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
    services.logind = {
      settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate"; # Suspend first then hibernate when closing the lid.
        HandlePowerKey = "hibernate"; # Hibernate on power button pressed.
        HandleSuspendKey = "suspend";
        IdleAction = "suspend-then-hibernate"; # To invoke suspend action at login screen.
        IdleActionSec = "1h"; # Time to suspend @ SDDM.
      };
    };
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
    SuspendState = "mem";
  };

  # OOM killer.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Network settings.
  networking = {
    hostName = "nixos-hp";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 21115 21116 21117 53317 ];
      allowedUDPPorts = [ 9 21116 53317 ];
    };
    interfaces = {
      enp0s25 = {
        wakeOnLan.enable = true; # Turn on WOL at systemd level.
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

