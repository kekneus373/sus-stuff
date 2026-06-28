# ------------------------------------------------------------------------
# ---       NixOS-AMD configuration file from 28.06.2026 17:20.        ---
# ------------------------------------------------------------------------
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ohci_pci" "ehci_pci" "pata_amd" "ahci" "sd_mod" "sr_mod" ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e7eba578-1334-4710-90fe-ce72bf9ee4d9";
      fsType = "ext4";
    };

  swapDevices = [ { device = "/dev/disk/by-uuid/9680981d-7781-4d5c-8415-a5e5683bec62"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true; # lib.mkDefault config.hardware.enableRedistributableFirmware
}
