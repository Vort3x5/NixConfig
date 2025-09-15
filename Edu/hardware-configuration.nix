{ config, lib, pkgs, modulesPath, ... }:
{
	imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

	boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-amd" ];
	boot.extraModulePackages = [ ];

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

	networking.useDHCP = lib.mkDefault true;
	networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

	swapDevices = [ ];
}
