{ pkgs, unstable }:
{
	list = with pkgs; [
        # Both kernels available
		linuxKernel.packages.linux_xanmod_stable.kernel
		linuxKernel.packages.linux_6_12.kernel

        # EFI management
		efibootmgr

        # Nix
		age unstable.sops ssh-to-age

        # Network
		networkmanager
		networkmanagerapplet # optional

        # Terminal and shell
		alacritty fish

        # Editor
		neovim vim emacs

        # X11
		bspwm sxhkd polybar rofi
		picom feh
		xorg.xinit xorg.xrandr xorg.xsetroot xorg.xprop
		xclip

        # Development
		gcc gnumake
		python3 lua
		git

        # Utils
		wget curl 
		unzip unclutter
		ksnip lsd ripgrep pfetch killall
		wl-clipboard

        # Apps
		firefox steam discord

        # Gaming
		mangohud gamemode gamescope

        # File manager (minimal)
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
