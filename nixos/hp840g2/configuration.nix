# ------------------------------------------------------------------------
# ---        NixOS-HP configuration file from 11.04.2026 22:00.        ---
# ------------------------------------------------------------------------
# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

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
    kernelParams = [ "mem_sleep_default=deep" "i915.enable_psr=0" "i915.enable_fbc=0" "i915.enable_dc=0" "intel_iommu=igfx_off" ];
    kernelModules = [ "zram" ];
    kernel.sysctl."vm.swappiness" = 15;
  };

  # Enable zram swap.
  zramSwap.enable = true;

  # Network storage.
  fileSystems."/mnt/smb0" = {
      device = "//10.138.72.31/borg";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/smb1" = {
      device = "//192.168.0.91/data0";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };
  fileSystems."/mnt/smb2" = {
      device = "//192.168.0.91/data1";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };
  fileSystems."/mnt/smb3" = {
      device = "//192.168.0.8/Common";
      fsType = "cifs";
      options = [ "username=KabzukSP" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };
  fileSystems."/mnt/sc" = {
      device = "//10.138.72.31/TrueNAS-SC";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" "x-gvfs-show" ];
  };
  fileSystems."/mnt/sus" = {
      device = "//10.138.72.31/sus";
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
    useXkbConfig = true; # use xkb.options in tty.
  };
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ pkgs.terminus_font ];
  };

  # Hardware setup.
  hardware = {
    graphics = {
      extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver intel-compute-runtime-legacy1 ];
      #enable32Bit = true;
    };
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };
    cpu.intel.updateMicrocode = true;
    intel-gpu-tools.enable = true;
    enableRedistributableFirmware = true;
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME="iHD"; };

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
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    }; 
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
    extraGroups = [ "wheel" "camera" "media" "audio" "video" "render" "kvm" "lp" "lpadmin" ];
    packages = with pkgs; [
      kdePackages.kcolorchooser
      # --- UUPDUMP ---
      aria2
      wimlib
      cdrkit
      cabextract
      chntpw
      uget
      pipx # yt-dlp
      brave
      thunderbird
      bleachbit
      # --- Webcam apps ---
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
      gimp3
      pinta
      krita
      kdePackages.kdenlive
      kdePackages.falkon
      kdePackages.filelight
      kdePackages.ktorrent
      kdePackages.kalk
      kdePackages.kclock
      # --- Games ---
      luanti-client
      # --- E-reader suppor. SONY PRS-600 workaround ---
      calibre
      ghostscript # $ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -o output.pdf input.pdf
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
      wget
      mc
      unrar-wrapper
      p7zip
      bc
      w3m
      htop
      killall
      microcode-intel
      intel-gpu-tools
      inteltool
      intelmetool
      mesa-demos
      libva-utils
      putty
      setserial
      screen
      cifs-utils
      samba
      glib
      lm_sensors
      nmap
      ethtool
      wol
      smartmontools
      inxi
      fastfetch
      ventoy-full
      brasero
      gnome-disk-utility
      remmina
      angryipscanner
      appimage-run # + .AppImage path
      libmtp
      libgphoto2
      gphoto2fs
      kdePackages.kamera
      # xxx BROKEN xxx
      anydesk
      # --- Games ---
      bottles
      # lutris-free # UA-GTA
      # winetricks  # UA-GTA
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
     # "nomachine-client"
   ];

  # pipx and QEMU.
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
    gphoto2.enable = true;
  };

#  Connect to old SMB 1.0 servers.
#  services.samba = {
#    enable = true;
#    settings = {
#      global = {
#        workgroup = "WORKGROUP";
#        security = "user";
#        "client min protocol" = "CORE";
#      };
#    };
#  };

  # Remote filesystems support.
  services.gvfs.enable = true;
  security.wrappers."mount.cifs" = {
    program = "mount.cifs";
    source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
  };

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

  # In case units above refuse to run.
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
        HandleLidSwitch = "suspend-then-hibernate"; # Suspend first then hibernate when closing the lid
        HandlePowerKey = "hibernate"; # Hibernate on power button pressed
        HandleSuspendKey = "suspend";
        HandlePowerKeyLongPress = "hybrid-sleep";
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "1h";
      };
    };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  # OOM killer.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Network settings.
  networking = {
    hostName = "nixos-hp"; # Define your hostname.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    firewall = {
      enable = true;
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 9 5353 53317 ];
    };
    hosts = {
      "10.138.72.31" = [ "hsvuldo-server" ];
    };
    interfaces = {
      enp0s25 = {
        wakeOnLan.enable = true;
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

