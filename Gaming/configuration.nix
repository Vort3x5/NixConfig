{ pkgs, ... }:
{
	imports = [
	  ./hardware-configuration.nix
	  ../nvidia.nix
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

	nixpkgs.overlays = [
		(self: super: {
			firefox = super.writeShellScriptBin "firefox" ''
				export DRI_PRIME=1
				export __NV_PRIME_RENDER_OFFLOAD=1
				exec ${super.firefox}/bin/firefox "$@"
			'';
		})
	];

	environment.sessionVariables = {
	};
        
	# Host-machine specific packages
	environment.systemPackages = with pkgs; [
	];
}
