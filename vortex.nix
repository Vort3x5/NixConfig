{ config, pkgs, inputs, unstable, ... }:
let
    systemPackages = import ./pkgs.nix { inherit pkgs unstable; };
in
{
	system.stateVersion = "24.05";

	# Users
	users.users.vortex = {
	  isNormalUser = true;
	  extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
	  shell = pkgs.fish;
	  initialPassword = "Vort3x5";
	};
	programs.fish.enable = true;

	nix = {
		package = pkgs.nix;
		settings.experimental-features = [ "nix-command" "flakes" ];
        
		# keep only latest two nixos versions
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 2d";
		};
		settings.auto-optimise-store = true;
	};

    # Allow to reboot and poweroff without sudo
	security.polkit.enable = true;
	environment.etc."polkit-1/rules.d/10-power.rules".text = ''
		polkit.addRule(function(action, subject) {
			if (action.id.match("org.freedesktop.login1.(reboot|power-off|suspend|hibernate|shutdown)")) {
				if (subject.isInGroup("wheel")) {
					return polkit.Result.YES;
				}
			}
		});
	  '';
	
	# Boot loader - systemd-boot
	boot.loader.systemd-boot.enable = true;
	boot.loader.systemd-boot.configurationLimit = 2;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.grub.enable = false;
	
	# Xanmod kernel as default
	boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
	
	# Keep standard kernel as backup for systemd-boot switching
	boot.extraModulePackages = [ ];

	boot.blacklistedKernelModules = [ "snd_pcsp" ];
        
	# Enable LVM support
	boot.initrd.kernelModules = [ "dm-snapshot" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
	boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
	services.lvm.enable = true;

	hardware.opengl = {
	  enable = true;
	  driSupport32Bit = true;
	};
        
	# Allow unfree packages (for NVIDIA)
	nixpkgs.config.allowUnfree = true;

    # Sound
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa = {
			enable = true;
			support32Bit = true;
		};
		pulse.enable = true;
	};

    # Packages
	environment.systemPackages = systemPackages.list;

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

	networking = {
		networkmanager = {
			enable = true;
			wifi.powersave = false;
		};
		wireless.enable = false;
	};

    # X11 services enable
    services.xserver = {
		enable = true;
		xkb = {
			layout = "pl";
			options = "compose:ralt";
		};
		displayManager.startx.enable = true;
		windowManager.bspwm.enable = true;
	};

    # Time zone and locale
	time.timeZone = "Europe/Warsaw";
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_TIME = "pl_PL.UTF-8";
		LC_MONETARY = "pl_PL.UTF-8";
	};
        
    # Console configuration
	console = {
		font = "Lat2-Terminus16";
		keyMap = "pl";
	};
        
	# Fonts
	fonts.packages = with pkgs; [
	  liberation_ttf
	  noto-fonts
	  noto-fonts-emoji
	  terminus_font
	  terminus_font_ttf
	];
	
	# Enable bitmap fonts (for Terminus)
	fonts.fontconfig.allowBitmaps = true;
}
