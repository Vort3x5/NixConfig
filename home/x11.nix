{ pkgs, layout ? "colemak", ...}:
{
	imports = [
		(import ./sxhkd.nix { inherit layout; })
	];

	home.file = {
		".xinitrc".source = ./misc/.xinitrc;
	};

	xdg.enable = true;

	xsession.windowManager.bspwm = {
		enable = true;
		monitors = {
			"primary" = [ "X" "X" "X" "X" "X" ];
		};
		rules = {
			"Emacs" = {
				state = "tiled";
			};
		};
		settings = {
			border_width = 0;
			window_gap = 30;
			split_ratio =  0.57;
			borderless_monocle =  true;
			gapless_monocle = true;
		};
		startupPrograms = [
			"feh --bg-fill --randomize ~/Desktop/Wallps"
			"bspc node -t floating"
			"bspc node -g sticky"
			"systemctl --user start polybar"
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
			"bar/Statbar" = {
				width = "98%";
				offset-x = "1%";
				height = "24pt";
				radius = 8;
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

				modules-left = "xworkspaces";
				modules-center = "date";
				modules-right = "cpu wlan";

				cursor-click = "pointer";
				cursor-scroll = "ns-resize";
				enable-ipc = true;
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
			polybar Statbar 2>&1 | tee -a /tmp/polybar.log & disown
		'';
	};
}
