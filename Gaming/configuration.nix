{ config, pkgs, ... }:
{
	imports = [
	  ./hardware-configuration.nix
	];

    # Root storage
	fileSystems."/" = {
		device = "/dev/disk/by-uuid/0b37b873-339c-4603-91bb-bede66755562";
		fsType = "ext4";
	};
	swapDevices = [{ 
		device = "/swapfile"; 
		size = 8192;
	}];
	boot.kernel.sysctl = {
		"vm.swappiness" = 1;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_ratio" = 15;
	};
        
	# Enable NVIDIA drivers
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.nvidia = {
		open = false;
		modesetting.enable = true;
		powerManagement.enable = false;
		nvidiaSettings = true;
		forceFullCompositionPipeline = true;
	    prime = {
			reverseSync.enable = true;
			amdgpuBusId = "PCI:16:0:0";
			nvidiaBusId = "PCI:1:0:0";
		};
	};

	environment.sessionVariables = {
		DRI_PRIME = "1";
		__NV_PRIME_RENDER_OFFLOAD = "1";
		__GLX_VENDOR_LIBRARY_NAME = "nvidia";
	};
        
	# Host-machine specific packages
	environment.systemPackages = with pkgs; [
	];
}
