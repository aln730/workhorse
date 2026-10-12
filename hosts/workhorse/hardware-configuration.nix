# VM test stub (QEMU/KVM, UEFI + virtio). For the real server, replace with:
#   nixos-generate-config --show-hardware-config > hosts/workhorse/hardware-configuration.nix
#
# Assumes filesystems labelled: nixos (root), BOOT (ESP), data (/srv).
#   mkfs.ext4 -L nixos /dev/vda2 ; mkfs.fat -F32 -n BOOT /dev/vda1 ; mkfs.ext4 -L data /dev/vdb
# If you installed with the graphical installer, prefer its generated file.
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Second virtual disk for service data (dataRoot = /srv).
  fileSystems."/srv" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
