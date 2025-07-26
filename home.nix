{ config, pkgs, ... }: 
{
	home.stateVersion = "24.05";

	programs.git = {
		enable = true;
		userName = "vortex";
		userEmail = "Faking.Games857@gmail.com";
		extraConfig = {
			init.defaultBranch = "master";
			core.editor = "nvim";
		};
	};

	services.picom = {
		enable = true;
		backend = "glx";
	};

	programs.ssh = {
	enable = true;
	extraConfig = ''
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
	'';
	};

	programs.fish = {
		enable = true;
		shellAliases = {
			ll = "ls -l";
			la = "ls -la";
			".." = "cd ..";
			g = "git";
			gst = "git status";
			v = "nvim";
			sv = "sudo nvim";
			py3 = "python3";
			off = "shutdown -h now";
			pause = "systemctl suspend";
		};
		interactiveShellInit = ''
bind \t forward-word
bind \cz complete

clear
pfetch
set fish_greeting ""
		'';
	};
	home.file = {
		".config/fish/functions/fish_prompt.fish".source = ./misc/fish_prompt.fish;
	};

	programs.alacritty = {
		enable = true;
		settings = {
			colors = {
				bright = {
					black = "0x657b83";
					blue = "0x268bd2";
					cyan = "0x2aa198";
					green = "0x859900";
					magenta = "0x6c71c4";
					red = "0xdc322f";
					white = "0xfdf6e3";
					yellow = "0xb58900";
				};
				normal = {
					black = "0x002b36";
					blue = "0x268bd2";
					cyan = "0x2aa198";
					green = "0x859900";
					magenta = "0x6c71c4";
					red = "0xdc322f";
					white = "0x93a1a1";
					yellow = "0xb58900";
				  };
				primary = {
					background = "0x02020f";
					foreground = "0xffffff";
				};
			};
			cursor = {
				style = {
					blinking = "Always";
					shape = "Beam";
				};
				vi_mode_style = {
					shape = "Block";
				};
			};
			font = {
				size = 30;
				normal = {
					family = "Terminus";
				};
			};
			keyboard.bindings = [
			{
				key = "T";
				mods = "Super|Shift";
				action = "SpawnNewInstance";
			}
			{
				key = "C";
				mods = "Alt";
				chars = "make clean\n";
			}
			{
				key = "M";
				mods = "Alt";
				chars = "make\n";
			}
			{
				key = "R";
				mods = "Alt";
				chars = "make release\n";
			}
			{
				key = "D";
				mods = "Alt";
				chars = "make debug\n";
			}
			{
				key = "Q";
				mods = "Alt";
				chars = "make GRUB\n";
			}
			{
				key = "G";
				mods = "Alt";
				chars = "gst\n";
			}
			{
				key = "T";
				mods = "Alt";
				chars = "clear && lsd --tree --icon=never\n";
			}
			{
				key = "L";
				mods = "Alt";
				chars = "clear && ls -l\n";
			}
			{
				key = "P";
				mods = "Alt";
				chars = "v .\n";
			}
			{
				key = "H";
				mods = "Alt";
				chars = "cd\n";
			}
			{
				key = "Slash";
				mods = "Alt";
				chars = "cd /\n";
			}
			{
				key = "Comma";
				mods = "Alt";
				chars = "wc -l --total=only **/* 2>/dev/null | tail -n 1\n";
			}
			{
				key = "B";
				mods = "Alt";
				chars = "cd ..\n";
			}];
			window.opacity = 0.75;
		};
	};

    # Create directories using home.activation
    home.activation.createDirs = ''
    	mkdir -p $HOME/.config/{bspwm,sxhkd,polybar,kitty,sops/age}
    	mkdir -p $HOME/{Desktop/Wallps,Downloads,.local/bin,.ssh}
    '';
}
