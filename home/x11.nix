{ pkgs, layout ? "colemak", ...}:
{
	imports = [
		(import ./sxhkd.nix { inherit layout; })
	];

	xdg.enable = true;

	xsession.windowManager.bspwm = {
		enable = true;
		monitors = {
			"primary" = [ "X" "X" "X" "X" "X" ];
		};
		settings = {
			border_width = 0;
			window_gap = 30;
			split_ratio =  0.57;
			borderless_monocle =  true;
			gapless_monocle = true;
			top_padding = 30;
		};
		startupPrograms = [
			''systemctl --user set-environment DISPLAY="$DISPLAY"''
			''systemctl --user set-environment PATH="/run/current-system/sw/bin:$PATH"''
	
			''nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"''
			"xrandr --setprovideroutputsource modesetting NVIDIA-0"
			"xrandr --auto"
	
			''setxkbmap -layout pl -option ""''
	
			''sxhkd -m 1''
			''unclutter --start-hidden --timeout=1''
	
			"feh --bg-fill --randomize /etc/nixos/home/misc/Wallps"
			"bspc node -t floating"
			"bspc node -g sticky"
			"systemctl --user start polybar"
			"systemctl --user restart picom"
		];
	};

	services.polybar = {
		enable = true;
		package = pkgs.polybar.override {
			alsaSupport = true;
		};
		config = {
			"colors" = {
				background = "#CA02020f";
				background-alt = "#CA02020f";
				foreground = "#C5C8C6";
				primary = "#06f72e";
				secondary = "#8ABEB7";
				alert = "#A54242";
				disabled = "#707880";
			};
			"bar/Left" = {
				width = "10%";
				offset-x = "1%";
				height = "25pt";
				radius = "12";
				fixed-center = false;

				background = "\${colors.background}";
				foreground = "\${colors.foreground}";

				line-size = "3pt";
				border-size = "4pt";
				border-color = "#00000000";

				padding-left = 0;
				padding-right = 1;
				module-margin = 1;

				separator = "|";
				separator-foreground = "\${colors.disabled}";

				font-0 = "Terminus:pixelsize=25;1";

				modules-left = "xworkspaces";

				cursor-click = "pointer";
				cursor-scroll = "ns-resize";
				enable-ipc = true;
				tray-position = "none";
				
				# for gap defined in bspwm
				override-redirect = true;
			};
			"bar/Center" = {
				width = "14%";
				offset-x = "43%";
				height = "25pt";
				radius = "12";
				fixed-center = true;

				background = "\${colors.background}";
				foreground = "\${colors.foreground}";

				line-size = "3pt";
				border-size = "4pt";
				border-color = "#00000000";

				padding-left = 0;
				padding-right = 1;
				module-margin = 1;

				separator = "|";
				separator-foreground = "\${colors.disabled}";

				font-0 = "Terminus:pixelsize=25;1";

				modules-center = "date";

				enable-ipc = true;
				tray-position = "none";
				override-redirect = true;
			};
			"bar/Right" = {
				width = "15%";
				offset-x = "84%";
				height = "25pt";
				radius = "12";
				fixed-center = true;

				background = "\${colors.background}";
				foreground = "\${colors.foreground}";

				line-size = "3pt";
				border-size = "4pt";
				border-color = "#00000000";

				padding-left = 0;
				padding-right = 1;
				module-margin = 1;

				separator = "|";
				separator-foreground = "\${colors.disabled}";

				font-0 = "Terminus:pixelsize=25;1";

				modules-center = "cpu wlan";

				enable-ipc = true;
				tray-position = "right";
				override-redirect = true;
			};
			"module/xworkspaces" = {
				type = "internal/xworkspaces";
				label-active = "%name%";
				label-active-background = "\${colors.background-alt}";
				label-active-underline = "\${colors.primary}";
				label-active-padding = 1;
				label-occupied = "%name%";
				label-occupied-padding = 1;
				label-urgent = "%name%";
				label-urgent-background = "\${colors.alert}";
				label-urgent-padding = 1;
				label-empty = "%name%";
				label-empty-foreground = "\${colors.disabled}";
				label-empty-padding = 1;
			};
			"module/cpu" = {
				type = "internal/cpu";
				interval = 2;
				format-prefix = "CPU ";
				format-prefix-foreground = "\${colors.primary}";
				label = "%percentage:2%%";
			};
			"module/wlan" = {
				type = "internal/network";
				interface-type = "wireless";
				interval = 5;
				format-connected = "<label-connected>";
				format-disconnected = "<label-disconnected>";
				label-connected = "%essid%";
				label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
			};
			"module/date" = {
				type = "internal/date";
				interval = 1;
				date = "%b %d";
				time = "%l:%M %p";
				label = "%date%  %time%";
			};
			"settings" = {
				screenchange-reload = true;
				pseudo-transparency = true;
			};
		};
        # systemctl --user start polybar will launch this:
		script = ''
			killall -q polybar
			polybar Left 2>&1 | tee -a /tmp/polybar.log & disown
			polybar Center 2>&1 | tee -a /tmp/polybar.log & disown
			polybar Right 2>&1 | tee -a /tmp/polybar.log & disown
		'';
	};
}
