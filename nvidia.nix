{ config, lib, pkgs, ... }:
{
	boot.kernelParams = [
		"nvidia-drm.modeset=1"
		"nvidia.NVreg_EnableGpuFirmware=1"
		"nvidia.NVreg_UsePageAttributeTable=1"
		"nvidia.NVreg_InitializeSystemMemoryAllocations=0"
	];

	hardware.nvidia = {
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		modesetting.enable = true;
	};

	services.xserver.videoDrivers = [ "nvidia" ];
}
