{ config, pkgs, ... }:
let
	alsaProfileBase = "${config.services.pipewire.package}/share/alsa-card-profile/mixer";
in
{
	imports = [
	  ./hardware-configuration.nix
	  ../nvidia.nix
	];

    # Root storage
	fileSystems."/" = {
		device = "/dev/disk/by-uuid/ac92f2b3-e480-43c3-8f81-b9428988d9cd";
		fsType = "ext4";
	};
	fileSystems."/home/vortex/Storage" = {
		device = "/dev/sda1";
		fsType = "ext4";
	};
	swapDevices = [{ 
		device = "/swapfile"; 
		size = 8192;
	}];
	boot.kernel.sysctl = {
		"vm.swappiness" = 1;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_ratio" = 15;
	};

	# Enable NVIDIA drivers
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.nvidia = {
		open = false;
		modesetting.enable = true;
		powerManagement.enable = false;
		nvidiaSettings = true;
		prime = {
			sync.enable = true;
			amdgpuBusId = "PCI:5:0:0";
			nvidiaBusId = "PCI:1:0:0";
		};
	};
        
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

	# Internal mic (Realtek ALC233): fix clipping + RNNoise noise suppression
	services.pipewire = {
		extraLadspaPackages = [ pkgs.rnnoise-plugin ];

		extraConfig.pipewire."99-tuf-mic-denoise" = {
			context.modules = [
				{
					name = "libpipewire-module-filter-chain";
					flags = [ "nofail" ];
					args = {
						"node.description" = "TUF Mic (Noise Cancelled)";
						"media.name" = "TUF Mic (Noise Cancelled)";
						"audio.rate" = 48000;
						"audio.position" = [ "FL" ];
						filter.graph = {
							nodes = [
								{
									type = "builtin";
									name = "highpass";
									label = "bq_highpass";
									control = {
										"Freq" = 100.0;
										"Q" = 0.707;
									};
								}
								{
									type = "ladspa";
									name = "rnnoise";
									plugin = "librnnoise_ladspa";
									label = "noise_suppressor_mono";
									control = {
										"VAD Threshold (%)" = 35.0;
										"VAD Grace Period (ms)" = 500;
										"Retroactive VAD Grace (ms)" = 100;
									};
								}
							];
						};
						capture.props = {
							"node.name" = "capture.tuf_mic";
							"node.passive" = true;
							"audio.rate" = 48000;
							"target.object" = "alsa_input.pci-0000_05_00.6.analog-stereo";
						};
						playback.props = {
							"node.name" = "tuf_mic_processed";
							"media.class" = "Audio/Source";
							"audio.rate" = 48000;
						};
					};
				}
			];
		};
	};

	services.pipewire.wireplumber.extraConfig = {
		# Map 100% UI volume to ~0 dB hardware gain instead of +30 dB (prevents clipping)
		"51-tuf-mic-gain" = {
			"monitor.alsa.rules" = [
				{
					matches = [
						{ "device.name" = "alsa_card.pci-0000_05_00.6"; }
					];
					actions = {
						"update-props" = {
							"api.alsa.ignore-dB" = true;
						};
					};
				}
			];
		};

		"52-tuf-default-mic" = {
			"wireplumber.settings" = {
				"default.audio.source" = "tuf_mic_processed";
			};
		};
	};

	# Limit Capture slider: 100% UI = 0 dB (step 31), not +30 dB (step 63)
	environment.etc."alsa-card-profile/mixer/profile-sets/default.conf".text =
		(builtins.readFile "${alsaProfileBase}/profile-sets/default.conf")
		+ "\n[DecibelFix Capture]\ndb-values = 0:-96.00 31:0.00\n";

	# Internal Mic Boost (+30 dB) overdrives the capsule on TUF/Realtek laptops
	environment.etc."alsa-card-profile/mixer/paths/analog-input-internal-mic.conf".text =
		builtins.replaceStrings
			[
				"[Element Internal Mic Boost]\nrequired-any = any\nswitch = select\nvolume = merge"
				"[Element Int Mic Boost]\nrequired-any = any\nswitch = select\nvolume = merge"
			]
			[
				"[Element Internal Mic Boost]\nrequired-any = any\nswitch = select\nvolume = zero"
				"[Element Int Mic Boost]\nrequired-any = any\nswitch = select\nvolume = zero"
			]
			(builtins.readFile "${alsaProfileBase}/paths/analog-input-internal-mic.conf");

	environment.systemPackages = with pkgs; [
		pavucontrol # switch input device / verify "TUF Mic (Noise Cancelled)"
	];
}
