{ config, pkgs, lib, ... }:
{
	imports = [
	  ./hardware-configuration.nix
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

	specialisation = lib.mkForce {};

	boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
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

    sops = {
		defaultSopsFile = ./secrets.yaml;
		defaultSopsFormat = "yaml";
		age.keyFile = "/home/vortex/.config/sops/age/keys.txt";
		
		secrets = {
			ssh_private_key = {
				owner = "vortex";
				group = "users";
				mode = "0600";
				path = "/home/vortex/.ssh/id_ed25519";
			};
		};
    };

	environment.systemPackages = with pkgs; [
	];
}
