{ config, lib, pkgs, ... }:
let
    systemPackages = import ./pkgs.nix { inherit pkgs; };

	fallout-grub-theme = pkgs.stdenv.mkDerivation {
		pname = "fallout-grub-theme";
        version = "1.0";
        
        src = pkgs.fetchFromGitHub {
            owner = "shvchk";
            repo = "fallout-grub-theme";
            rev = "80734103d0b48d724f0928e8082b6755bd3b2078";
            sha256 = "sha256-7kvLfD6Nz4cEMrmCA9yq4enyqVyqiTkVZV5y4RyUatU=";
        };
        
        installPhase = ''
            mkdir -p $out/share/grub/themes/fallout
            cp -r * $out/share/grub/themes/fallout/
        '';
	};

	infinity-sddm = pkgs.stdenv.mkDerivation {
	 	pname = "infinity-sddm";
	 	version = "1.0";
	 	
	 	src = ./home/misc/Infinity-SDDM.tar.gz;

	 	sourceRoot = ".";

	 	
	 	installPhase = ''
	    mkdir -p $out/share/sddm/themes/infinity
	 	cp -r * $out/share/sddm/themes/infinity/

		${pkgs.gnused}/bin/sed -i '/QtVersion/d' $out/share/sddm/themes/infinity/metadata.desktop
	 	chmod -R 755 $out/share/sddm/themes/infinity/
	 	'';
	 };

	nativeBuildInputs = with pkgs; [ gnutar gnused ];
in
{
	system.stateVersion = "25.05";

	# Users
	users.users.vortex = {
	  isNormalUser = true;
	  extraGroups = [ "wheel" "video" "audio" "networkmanager" "render" "docker" ];
	  shell = pkgs.fish;
	  initialPassword = "Vort3x5";
	};
	programs.fish.enable = true;

	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};

	nix = {
		package = pkgs.nix;
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
		};
        
		# keep only latest two nixos versions
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 2d";
		};
	};

	boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos;
	system.modulesTree = [ (lib.getOutput "modules" config.boot.kernelPackages.kernel) ];

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

	  boot.loader = {
        systemd-boot.enable = false;
        grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
            configurationLimit = 5;
            
            theme = fallout-grub-theme + "/share/grub/themes/fallout";
            splashImage = null;
            
            extraConfig = ''
                set timeout=10
                set default=0
                
                # Fallout-style colors and fonts
                set color_normal=light-green/black
                set color_highlight=yellow/dark-gray
                
                # Menu entries will be auto-generated as:
                # "NixOS" - CachyOS Gaming Kernel (BORE scheduler, gaming optimized)
                # "NixOS - cachyos-dev" - CachyOS Development (debug symbols, profiling tools)
                # "NixOS - stable-fallback" - Linux Stable Kernel (maximum compatibility)
            '';
        };
        efi.canTouchEfiVariables = true;
    };

	specialisation = {
        dev = {
            configuration = {
                system.nixos.tags = [ "cachyos-dev" ];
                
                boot.kernelParams = [
                    "nvidia-drm.modeset=1"
                    "nvidia.NVreg_EnableGpuFirmware=1"
                    "nvidia.NVreg_UsePageAttributeTable=1"
                    "nvidia.NVreg_InitializeSystemMemoryAllocations=0"
                    "amd_pstate=guided"

                    # Development-specific parameters
                    "debug"
                    "ignore_loglevel"
                    "dyndbg=+p"
                    "kgdboc=kbd"
                ];
                
                environment.systemPackages = systemPackages.list ++ [
                    fallout-grub-theme
					infinity-sddm
                    pkgs.grub2_efi
                    pkgs.gdb
                    pkgs.strace
                    pkgs.ltrace
                    pkgs.perf-tools
                    pkgs.kernelshark
                    pkgs.trace-cmd
                    pkgs.bpftrace
                    pkgs.bcc
                ];
                
                # Enable kernel debugging features
                boot.kernel.sysctl = {
                    "kernel.dmesg_restrict" = 0;
                    "kernel.perf_event_paranoid" = -1;
                    "kernel.kptr_restrict" = 0;
                    "kernel.yama.ptrace_scope" = 0;
                };
            };
        };
        
       stable = {
           configuration = {
               
               boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
               boot.kernelParams = [
                   "nvidia-drm.modeset=1"
                   "nvidia.NVreg_EnableGpuFirmware=1"
                   "nvidia.NVreg_UsePageAttributeTable=1"
                   "nvidia.NVreg_InitializeSystemMemoryAllocations=0"
                   "amd_pstate=guided"

                   # Conservative parameters for maximum stability
                   "quiet"
                   "splash"
                   "loglevel=3"
               ];
           };
       };
    };
	
	boot.kernelParams = lib.mkDefault [
	    "nvidia-drm.modeset=1"
	    "nvidia.NVreg_EnableGpuFirmware=1"
	    "nvidia.NVreg_UsePageAttributeTable=1"
	    "nvidia.NVreg_InitializeSystemMemoryAllocations=0"
		"amd_pstate=guided"

        # Gaming Optimizations
		"mitigations=off" 
        "preempt=full"
        "split_lock_detect=off"
        "quiet"
        "loglevel=3"
	];

	boot.extraModulePackages = [ ];
	boot.blacklistedKernelModules = [ "snd_pcsp" ];
	boot.initrd.kernelModules = [  "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
	boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

	boot.extraModprobeConfig = ''
		options snd-hda-intel model=headset-mode
	'';

        
	# Enable LVM support
	services.lvm.enable = true;

	hardware.nvidia = {
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		modesetting.enable = true;
	};

	hardware.graphics = {
	  enable = true;
	  enable32Bit = true;
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
		jack.enable = true;
	};

    # Packages
	environment.systemPackages = systemPackages.list ++ [
	    fallout-grub-theme
		pkgs.grub2_efi
	];

	networking = {
		networkmanager = {
			enable = true;
			wifi.powersave = false;
		};
		wireless.enable = false;
	};

    # X11 services
	services.displayManager = {
		defaultSession = "none+bspwm";
		sddm = {
			enable = true;
			wayland.enable = false;
			theme = "infinity";
		};
	};

    services.xserver = {
		enable = true;
		xkb = {
			layout = "pl";
			model = "pc105";
			options = "";
		};
		windowManager.bspwm.enable = true;
		displayManager = {
			startx.enable = false;
		};
	};

	environment.etc."xdg/sessions/bspwm.desktop".source = ./home/misc/bspwm.desktop;
	environment.etc = { 
		"xdg/sessions/bspwm-session" = {
			source = ./home/misc/bspwm-session.sh;
			mode = "0755";
		}; 
		"$out/share/sddm/themes/infinity/metadata.desktop" = {
			source = ./home/misc/metadata.desktop;
			mode = "0755";
		}; 
	};

	programs.steam = {
		enable = true;
		gamescopeSession.enable = true;
	};

	programs.gamemode.enable = true;

    # Time zone and locale
	time.timeZone = "Europe/Warsaw";
	i18n = {
		defaultLocale = "en_US.UTF-8";
		extraLocaleSettings = {
			LC_TIME = "pl_PL.UTF-8";
			LC_MONETARY = "pl_PL.UTF-8";
			LC_CTYPE = "pl_PL.UTF-8";
			LC_MESSAGE = "en_US.UTF-8";
		};
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"pl_PL.UTF-8/UTF-8"
		];
		inputMethod.enable = false;
	};
        
    # Console configuration
	console = {
		font = "Lat2-Terminus16";
		useXkbConfig = true;
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
