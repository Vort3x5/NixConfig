{ config, pkgs, lib, ... }:
{
	imports = [
	  ./hardware-configuration.nix
	  ../nvidia.nix
	];

	# RTL8852CE: drop newer rtw8852c firmware blobs with known regressions.
	# Note: linux-firmware sets dontFixup=true, so postInstall is required (not postFixup).
	nixpkgs.overlays = [
		(self: super: {
			linux-firmware = super.linux-firmware.overrideAttrs (old: {
				postInstall = (old.postInstall or "") + ''
					rm -f $out/lib/firmware/rtw89/rtw8852c_fw-1.bin
					rm -f $out/lib/firmware/rtw89/rtw8852c_fw-2.bin
				'';
			});
		})
		(self: super: {
			firefox = super.writeShellScriptBin "firefox" ''
				export DRI_PRIME=1
				export __NV_PRIME_RENDER_OFFLOAD=1
				exec ${super.firefox}/bin/firefox "$@"
			'';
		})
	];

    # Root storage
	fileSystems."/" = {
		device = "/dev/disk/by-uuid/0b37b873-339c-4603-91bb-bede66755562";
		fsType = "ext4";
	};
	swapDevices = [{ 
		device = "/swapfile"; 
		size = 8192;
	}];

	# The CachyOS 7.1.x kernel still triggers rtw89 firmware SER crashes here,
	# which forces the link down to low legacy rates.
	boot.kernelPackages = lib.mkOverride 900 pkgs.linuxPackages;

	boot.kernel.sysctl = {
		"vm.swappiness" = 1;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_ratio" = 15;

		"net.ipv4.tcp_congestion_control" = "bbr";
		"net.core.default_qdisc" = "fq";
		"net.ipv4.tcp_fastopen" = 3;
	};

	boot.kernelModules = [ "kvm-amd" "kvm-intel" "tcp_bbr" ];

	# RTL8852CE (rtw89): disable aggressive PCIe/WiFi power saving that
	# causes throughput drops and latency spikes on newer kernels.
	boot.extraModprobeConfig = ''
		options rtw89_core disable_ps_mode=Y
		options rtw89_pci disable_aspm_l1=Y disable_aspm_l1ss=Y disable_clkreq=Y
		options cfg80211 ieee80211_regdom=PL
	'';

	# iwd handles WPA on RTL8852CE more reliably than wpa_supplicant (5 GHz handshake bug).
	networking.networkmanager.wifi.backend = "iwd";

	networking.networkmanager.settings = {
		connectivity = {
			enabled = false;
		};
		connection = {
			"wifi.powersave" = 2;
		};
	};

	# Tune saved NM/iwd profiles: prefer home 5 GHz AP, don't fall back to phone hotspots.
	system.activationScripts.wifi-profile-tuning = lib.stringAfter [ "setupSecrets" ] ''
		nmcli="${pkgs.networkmanager}/bin/nmcli"
		for id in UPC29324E7 wifi-wlp7s0-1; do
			if $nmcli connection show "$id" &>/dev/null; then
				$nmcli connection modify "$id" \
					802-11-wireless.band a \
					802-11-wireless.bssid "90:5C:44:72:8F:E5" \
					802-11-wireless.mac-address-randomization 0 \
					802-11-wireless-security.key-mgmt wpa-psk \
					802-11-wireless-security.proto rsn \
					802-11-wireless-security.pairwise ccmp \
					802-11-wireless-security.group ccmp \
					802-11-wireless-security.pmf disable \
					802-11-wireless-security.auth-alg open \
					802-11-wireless.powersave 2 \
					connection.autoconnect yes \
					connection.autoconnect-priority 100 \
					connection.interface-name "" \
					|| true
			fi
		done
		for id in "Galaxy M217924" "Galaxy M2195DF" wifi-wlp7s0; do
			$nmcli connection modify "$id" connection.autoconnect no 2>/dev/null || true
		done
	'';

	# Enable NVIDIA drivers
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.nvidia = {
		open = false;
		modesetting.enable = true;
		powerManagement.enable = false;
		nvidiaSettings = true;
		forceFullCompositionPipeline = true;
	    prime = {
			reverseSync.enable = true;
			amdgpuBusId = "PCI:16:0:0";
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

	environment.sessionVariables = {
	};
	# Host-machine specific packages
	environment.systemPackages = with pkgs; [
	];
}
