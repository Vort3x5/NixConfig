{ config, pkgs, ... }:
{
	imports = [
	  ./hardware-configuration.nix
	];

    # Root storage
	fileSystems."/" = {
		device = "/dev/disk/by-uuid/ac92f2b3-e480-43c3-8f81-b9428988d9cd";
		fsType = "ext4";
	};
	fileSystems."/home/vortex/Storage" = {
		device = "/dev/sda1";
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
		prime = {
			sync.enable = true;
			amdgpuBusId = "PCI:5:0:0";
			nvidiaBusId = "PCI:1:0:0";
		};
	};
        
	# Secrets config
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

	# Host-machine specific packages
	environment.systemPackages = with pkgs; [
	];
}
