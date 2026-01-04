# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mem_sleep_default=deep" "zswap.enabled=1" "zswap.max_pool_percent=40" ];
  # boot.kernelModules = [ "lz4" "z3fold" ];
  boot.kernel.sysctl."vm.swappiness" = 1;
  swapDevices = [
    { device = "/dev/disk/by-uuid/0a6fb3d2-8e12-4b7c-88ba-0d441ba8daa7"; }
  ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
#  fileSystems."/mnt/smb0" = {
#      device = "//10.138.72.12/backup";
#      fsType = "cifs";
#      options = [ "username=bogdan" "vers=1.0" "users" "noauto" "soft" "echo_interval=10" "retrans=2" ];
#  };
  fileSystems."/mnt/smb0" = {
      device = "//10.138.72.31/borg";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/smb1" = {
      device = "//192.168.0.91/data0";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/smb2" = {
      device = "//192.168.0.91/data1";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/smb3" = {
      device = "//192.168.0.8/Common";
      fsType = "cifs";
      options = [ "username=KabzukSP" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/sc" = {
      device = "//10.138.72.31/TrueNAS-SC";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };
  fileSystems."/mnt/sus" = {
      device = "//10.138.72.31/sus";
      fsType = "cifs";
      options = [ "username=bogdan" "users" "noauto" "soft" "echo_interval=10" "retrans=2" "closetimeo=3" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };
  fonts.enableDefaultPackages = true;

  hardware = {
    graphics.extraPackages = with pkgs; [ intel-vaapi-driver ]; # intel-media-driver
    graphics.enable32Bit = true;
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };
  services = {
    xserver.enable = true; # Enable the X11 windowing system.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";
  };
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents, Avahi Bonjour to discover network printers.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip ];
  };
  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wynz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "camera" "kvm" ];
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
      # webcam
      kdePackages.kamoso
      # webcamoid
      borgbackup
      doublecmd
      meld
      kdePackages.kompare
      czkawka
      curtail
      libreoffice-qt6-fresh
      onlyoffice-bin_latest
      vlc
      handbrake
      mediainfo-gui
      audacity
      easyeffects # downmix to mono when needed
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
      # games
      minetestclient
      # e-reader support; prs-600 fix
      calibre
      ghostscript # $ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -o output.pdf input.pdf
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages =  let
    legacy = import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/78add7b7abb61689e34fc23070a8f55e1d26185b.tar.gz";
      sha256 = "07gxwsywvlsnqj87g9r60j8hrvydcy0sa60825pzkdilrwwhnwjx";
    }) {}; # take revision ID from Hydra -> Input tab -> Revision column
  in
    (with pkgs; [
      wget
      mc
      unrar-wrapper
      p7zip
      bc
      w3m
      htop
      killall
      microcodeIntel
      intel-gpu-tools
      putty
      screen
      cifs-utils
      samba
      glib
      lm_sensors
      nmap
      smartmontools
      glxinfo
      inxi
      ventoy-full
      brasero
      gnome-disk-utility
      remmina
      angryipscanner
      appimage-run # + .AppImage path
      # camera support
      libmtp
      gphoto2fs
      kdePackages.kamera
      # xxx BROKEN xxx
      # setserial
      anydesk
      # games
      bottles
      # lutris-free # UA-GTA
      # winetricks  # UA-GTA
    ]) ++
    (with legacy; [
      setserial
    ]);

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
      "microcodeIntel"
      "anydesk"
      "ventoy"
     # "teamviewer"
     # "nomachine-client"
  ];
 environment.localBinInPath = true;
  virtualisation.libvirtd= {
    enable = true;
    qemu.ovmf.packages = with pkgs; [
      pkgsCross.aarch64-multiplatform.OVMF.fd # AAVMF
      OVMF.fd
    ];
  };
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
  programs.vim = {
    enable = true;
    package = pkgs.vim-full;
    defaultEditor = true;
  };
  programs.gphoto2.enable = true;
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        security = "user";
        "client min protocol" = "CORE";
      };
    };
  };
  #services.teamviewer.enable = true;
  #systemd.services.teamviewerd.enable = false;
#  systemd.services.tvd = {
#    description = "Alternative TeamViewer remote control daemon";
#    preStart = "mkdir -pv /var/lib/teamviewer /var/log/teamviewer";
#    startLimitIntervalSec = 60;
#    startLimitBurst = 10;
#    serviceConfig = {
#      Type = "simple";
#      ExecStart = "${pkgs.teamviewer}/bin/teamviewerd -f";
#      PIDFile = "/run/teamviewerd.pid";
#      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
#      Restart = "on-abort";
#    };
#  };
  services.gvfs.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  security.wrappers."mount.cifs" = {
    program = "mount.cifs";
    source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
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
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
    services.logind = {
      lidSwitch = "suspend-then-hibernate"; # Suspend first then hibernate when closing the lid
      powerKey = "hibernate"; # Hibernate on power button pressed
      suspendKey = "suspend";
      powerKeyLongPress = "hybrid-sleep";
      extraConfig = ''
        [Login]
        IdleAction=suspend-then-hibernate
        IdleActionSec=1h
      '';
    };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
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
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking = {
    hostName = "nixos-hp"; # Define your hostname.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    firewall = {
      enable = true;
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 5353 53317 ];
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

