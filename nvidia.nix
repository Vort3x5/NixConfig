{ config, ... }:
{
	# Shared NVIDIA baseline. Host configs only set PRIME bus IDs / sync mode.
	services.xserver.videoDrivers = [ "nvidia" ];

	boot.kernelParams = [
		"nvidia-drm.modeset=1"
		"nvidia.NVreg_EnableGpuFirmware=1"
		"nvidia.NVreg_UsePageAttributeTable=1"
		"nvidia.NVreg_InitializeSystemMemoryAllocations=0"
	];

	hardware.nvidia = {
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		open = false;
		modesetting.enable = true;
		powerManagement.enable = false;
		nvidiaSettings = true;
	};
}
