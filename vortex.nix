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
		pname = "infinity-sddm-6";
		version = "1.1";

		src = pkgs.fetchFromGitHub {
			owner = "L4ki";
			repo = "Infinity-Plasma-Themes";
			rev = "e40490e79decb2f76d8e30c737bf7065f3112715";
			sha256 = "sha256-T2Y0EHrxNLzype41Sb9ohn5vNakLCuJa/triJrGVv9U=";
		};

		nativeBuildInputs = [ pkgs.gnused ];

		installPhase = ''
			theme=$out/share/sddm/themes/Infinity-SDDM-6
			mkdir -p "$theme"
			cp -r $src/Infinity-SDDM/Infinity-SDDM-6/. "$theme/"
			find "$theme" -name '*.qml' -exec \
				${pkgs.gnused}/bin/sed -i \
				-e "s|/usr/share/sddm/themes/Infinity-SDDM-6|$theme|g" \
				-e "s|icon.name: \"assets/|icon.name: \"$theme/assets/|g" \
				-e "s|source: \"assets/|source: \"$theme/assets/|g" \
				{} +
			chmod -R 755 "$theme"
		'';
	};

	sddmInfinityPackages = with pkgs.kdePackages; [
		infinity-sddm
		plasma-workspace
		libplasma
		kirigami
		plasma5support
		qt5compat
		qtsvg
		qqc2-breeze-style
	];
in
{
	system.stateVersion = "26.05";

	# Users
	users.users.vortex = {
	  isNormalUser = true;
	  extraGroups = [ 
			"wheel" 
			"video" 
			"audio" 
			"networkmanager" 
			"render" 
			"docker" 
			"kvm" 
			"adbusers" 
			"vboxusers" 
			"plugdev" 
			"wireshark" 
		];
	  shell = pkgs.fish;
	  initialPassword = "Vort3x5";
	};

	services.udev.extraRules = ''
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="664", GROUP="plugdev", TAG+="uaccess"
	'';
	services.udev.packages = [ pkgs.openocd ];

	programs.fish.enable = true;

	virtualisation.virtualbox.host.enable = true;
	virtualisation.docker.enable = true;
	virtualisation.podman = {
		enable = true;
		# dockerCompat = true;
	};

	nix = {
		package = pkgs.nix;
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
			substituters = lib.mkAfter [ "https://attic.xuyh0120.win/lantian" ];
			trusted-public-keys = lib.mkAfter [
				"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
			];
		};
        
		# keep only latest two nixos versions
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 2d";
		};
	};

	boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-bore;

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
        systemd-boot.enable = lib.mkDefault false;
        grub = {
            enable = lib.mkDefault true;
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
        efi.canTouchEfiVariables = lib.mkDefault true;
    };

	specialisation = {
        dev = {
            configuration = {
                system.nixos.tags = [ "cachyos-dev" ];
                
                boot.kernelParams = [
                    "amd_pstate=guided"

                    # Development-specific parameters
                    "debug"
                    "ignore_loglevel"
                    "dyndbg=+p"
                    "kgdboc=kbd"
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
		"amd_pstate=guided"

        # Gaming Optimizations
		"mitigations=off" 
        "preempt=full"
        "split_lock_detect=off"
        "quiet"
        "loglevel=3"
		"usbcore.quirks=041e:4055:bc"
	];

	boot.extraModulePackages = [ ];
	boot.blacklistedKernelModules = [ "snd_pcsp" "kvm" "kvm_amd" "ftdi_sio" ];

	boot.extraModprobeConfig = ''
		options snd-hda-intel model=headset-mode
	'';

	# required for flatpak
	xdg.portal = {
		enable = true;
		extraPortals = [
			pkgs.xdg-desktop-portal-gtk
		];
		config.common.default = "*";
	};
	services.flatpak.enable = true;
        
	# Enable LVM support
	services.lvm.enable = true;

	hardware.enableAllFirmware = true;
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
		infinity-sddm
		pkgs.grub2_efi
	];

	networking = {
		networkmanager = {
			enable = true;
			wifi.powersave = false;
		};
	};

    # X11 services
	services.displayManager = {
		defaultSession = "none+bspwm";
		sddm = {
			enable = true;
			wayland.enable = false;
			package = pkgs.kdePackages.sddm;
			theme = "Infinity-SDDM-6";
			extraPackages = sddmInfinityPackages;
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
	  noto-fonts-color-emoji
	  terminus_font
	  terminus_font_ttf
	];
	
	# Enable bitmap fonts (for Terminus)
	fonts.fontconfig.allowBitmaps = true;
}
