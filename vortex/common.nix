{ config, lib, pkgs, ... }:
let
	systemPackages = import ./pkgs-common.nix { inherit pkgs; };

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

	users.users.vortex = {
		isNormalUser = true;
		extraGroups = [
			"wheel"
			"video"
			"audio"
			"networkmanager"
			"render"
			"adbusers"
			"plugdev"
			"wireshark"
		];
		shell = pkgs.fish;
		initialPassword = "Vort3x5";
	};

	# Embedded / lab hardware (Edu + others)
	services.udev.extraRules = ''
		# FTDI
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0664", GROUP="plugdev", TAG+="uaccess"

		# STLINK-V3 (Nucleo-G474RE) — 0483:374e
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666", GROUP="plugdev", TAG+="uaccess"

		# ST-Link V2 / V2.1
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev", TAG+="uaccess"
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev", TAG+="uaccess"
	'';
	services.udev.packages = [ pkgs.openocd pkgs.stlink ];

	programs.fish.enable = true;

	nix = {
		package = pkgs.nix;
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
		};

		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 2d";
		};
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
			'';
		};
		efi.canTouchEfiVariables = lib.mkDefault true;
	};

	boot.kernelParams = lib.mkDefault [
		"amd_pstate=guided"
		"quiet"
		"loglevel=3"
	];

	boot.extraModulePackages = [ ];
	boot.blacklistedKernelModules = [ "snd_pcsp" "kvm" "kvm_amd" "ftdi_sio" ];

	boot.extraModprobeConfig = ''
		options snd-hda-intel model=headset-mode
	'';

	services.openssh.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [
			pkgs.xdg-desktop-portal-gtk
		];
		config.common.default = "*";
	};
	services.flatpak.enable = true;

	services.lvm.enable = true;

	hardware.enableAllFirmware = true;
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};

	nixpkgs.config.allowUnfree = true;

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

	environment.systemPackages = systemPackages.list ++ [
		fallout-grub-theme
		infinity-sddm
		pkgs.grub2_efi
	];

	networking = {
		networkmanager = {
			enable = true;
			wifi.powersave = false;
			wifi.scanRandMacAddress = false;
			dns = "dnsmasq";
		};
	};

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

	environment.etc."xdg/sessions/bspwm.desktop".source = ../home/misc/bspwm.desktop;
	environment.etc = {
		"xdg/sessions/bspwm-session" = {
			source = ../home/misc/bspwm-session.sh;
			mode = "0755";
		};
	};

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

	console = {
		font = "Lat2-Terminus16";
		useXkbConfig = true;
	};

	fonts.packages = with pkgs; [
		liberation_ttf
		noto-fonts
		noto-fonts-color-emoji
		terminus_font
		terminus_font_ttf
	];

	fonts.fontconfig.allowBitmaps = true;
}
