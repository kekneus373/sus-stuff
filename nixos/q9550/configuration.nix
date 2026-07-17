# ------------------------------------------------------------------------
# ---       NixOS-AMD configuration file from 17.07.2026 18:58.        ---
# ------------------------------------------------------------------------
# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    kernelModules = [ "zram" "it87" ];
    # kernelParams = [ "nohz=off" "clocksource=hpet" ]; # From Foxconn 8657MF - buggy Pentium D PC.
    kernel.sysctl."vm.swappiness" = 15;
  };

  # Enable zram swap.
  zramSwap.enable = true;

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
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ terminus_font ];
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    xkb.layout = "us";
  };
  services.displayManager.defaultSession = "xfce";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    #jack.enable = true;
  };

  # Set up Bluetooth.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wynz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "camera" "media" "audio" "video" "render" "lp" "lpadmin" "wireshark" ];
    packages = with pkgs; [
      aria2
      openssl
      brasero
      ventoy-full
      gnome-disk-utility
      remmina
      gucharmap
      shotcut
      ffmpeg-full
      simplescreenrecorder
      transmission_4-gtk
      gtkhash
      uget
      brave
      bleachbit
      baobab
      doublecmd
      peazip
      meld
      czkawka
      libreoffice-fresh
      qalculate-gtk
      vlc
      filezilla
      nextcloud-client
      angryipscanner
      putty
      rustdesk-flutter
      audacity
      lmms
      easyeffects
      gimp3
      pinta
      krita
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    xfce4-clipman-plugin
    xfce4-genmon-plugin
    wget
    mc
    file
    unrar-wrapper
    p7zip
    bc
    links2
    htop
    fastfetch
    psmisc
    xkill
    screen
    imsprog
    flashrom
    nmap
    wol
    ethtool
    cifs-utils
    lm_sensors
    smartmontools
    mesa-demos
    inxi
    appimage-run # + .AppImage path 
    libmtp
    gphoto2
    gphoto2fs
  ];

  # Anti-Anti-Ventoy overlay.
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
      "ventoy"
  ];

  # Useful utilities.
  environment.localBinInPath = true;
  programs = {
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
    seahorse.enable = true; # Required by Nextcloud.
  };
  services.gnome.gnome-keyring.enable = true; # Required by Nextcloud.
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  
  # Better power management.
  powerManagement.enable = true;
  
  # OOM killer.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Something required for rebuilding NixOS from Rescue DVD.
  # services.logrotate.enable = false;

  # Network settings.
  networking = {
    hostName = "nixos-amd";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 21115 21116 21117 53317 ];
      allowedUDPPorts = [ 9 21116 53317 ];
    };
    interfaces = {
      enp0s10 = {
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
