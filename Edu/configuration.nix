{ lib, ... }:
{
	imports = [
	  ./hardware-configuration.nix
	  ./virtualbox.nix
	];

	fileSystems."/" = {
	    device = "/dev/nvme0n1p2";
	    fsType = "ext4";
	};

	fileSystems."/boot" = {
	    device = "/dev/nvme0n1p1";
	    fsType = "vfat";
	    options = [ "fmask=0022" "dmask=0022" ];
	};
	
	swapDevices = [{ 
		device = "/swapfile"; 
		size = 4096;
	}];
	
	boot.kernel.sysctl = {
		"vm.swappiness" = 10;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_ratio" = 15;
	};

	boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

	# Laptop-specific power management
	services.tlp = {
		enable = true;
		settings = {
			CPU_SCALING_GOVERNOR_ON_AC = "performance";
			CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
			START_CHARGE_THRESH_BAT0 = 20;
			STOP_CHARGE_THRESH_BAT0 = 80;
		};
	};

	sops.defaultSopsFile = ./secrets.yaml;
}
