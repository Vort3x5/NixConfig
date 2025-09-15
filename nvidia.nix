{ config, lib, pkgs, ... }:
{
	boot.kernelParams = [
		"nvidia-drm.modeset=1"
		"nvidia.NVreg_EnableGpuFirmware=1"
		"nvidia.NVreg_UsePageAttributeTable=1"
		"nvidia.NVreg_InitializeSystemMemoryAllocations=0"
	];

	boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
	boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

	hardware.nvidia = {
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		modesetting.enable = true;
	};

	services.xserver.videoDrivers = [ "nvidia" ];
}
