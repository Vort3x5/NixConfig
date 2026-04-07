{ pkgs }:
{
	list = with pkgs; [

        # EFI management
		efibootmgr

		# Phone Cam
		droidcam

        # Nix
		age sops ssh-to-age

        # Network
		networkmanager
		networkmanagerapplet # optional

        # Sound
		alsa-utils

        # Terminal and shell
		alacritty fish

        # Editor
		neovim vim emacs zathura

        # X11
		bspwm sxhkd polybar rofi
		picom feh
		xorg.xinit xorg.xrandr xorg.xsetroot xorg.xprop
		xclip
		arandr

        # Development
		gcc gnumake gdb
		python3 lua fasm verilator
		git qemu kicad typst
		tcsh octave gnuplot gtkwave

        # Utils
		ffmpeg usbutils wget curl jq openssl nmap sshfs screen
		unzip zip unclutter
		flameshot lsd ripgrep pfetch killall
		wl-clipboard brightnessctl
		wmname binwalk
		evince

		# Containers
		distrobox podman docker docker-compose

        # Apps
		firefox steam discord vlc obs-studio

        # Gaming
		mangohud gamemode gamescope wine
		(lutris.override {
			extraLibraries =  pkgs: [
				pkgs.gamemode
				pkgs.libnghttp2
				pkgs.openssl
				pkgs.icu
			];
		})

        # File manager
		ranger

        # ZSA Moonlander tools
		wally-cli
		qmk

        # System monitoring
		lm_sensors
		acpi htop 
		fastfetch

        # Terminus font
		terminus_font
		terminus_font_ttf

        # LVM management tools
		lvm2
	];
}
