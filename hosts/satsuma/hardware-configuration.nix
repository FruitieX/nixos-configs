# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    # /dev/sda1
    "/" = {
      device = "/dev/disk/by-uuid/18cd8f0a-864c-40a8-a6e1-697ab8e18e74";
      fsType = "ext4";
    };

    # /dev/sdb2
    #"/mnt" = {
    #  device = "/dev/disk/by-uuid/6BBE8C5E54FA7A8C";
    #  fsType = "ntfs-3g";
    #};

    # /dev/sdc1
    #"/media" = {
    #  device = "/dev/disk/by-uuid/6ec87ce4-cb35-4ed2-92ee-d1f242b382d3";
    #  fsType = "ext4";
    #};
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
