{ pkgs }:
{
	list = with pkgs; [

        # EFI management
		efibootmgr

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

        # Development
		gcc gnumake
		python3 lua fasm
		git

        # Utils
		wget curl jq
		unzip unclutter
		flameshot lsd ripgrep pfetch killall
		wl-clipboard
		wmname

		# Containers
		distrobox podman

        # Apps
		firefox steam discord

        # Gaming
		mangohud gamemode gamescope

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
