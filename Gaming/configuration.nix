{ config, pkgs, lib, unstable, ... }:
let
	# me3 0.13 lives on unstable; stable currently ships an older me3.
	elden-ring-convergence = pkgs.callPackage ../pkgs/elden-ring-convergence {
		me3 = unstable.me3;
	};
in
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

	# Stay on vanilla: CachyOS 7.1.x triggered rtw89 firmware SER crashes.
	# (CachyOS is only pulled in on TUF via vortex/kernel-cachyos.nix.)

	boot.kernel.sysctl = {
		"vm.swappiness" = 1;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_ratio" = 15;

		"net.ipv4.tcp_congestion_control" = "bbr";
		"net.core.default_qdisc" = "fq";
		"net.ipv4.tcp_fastopen" = 3;
		"net.ipv4.tcp_mtu_probing" = 1;
		"net.core.rmem_max" = 16777216;
		"net.core.wmem_max" = 16777216;
	};

	boot.kernelModules = [ "kvm-amd" "kvm-intel" "tcp_bbr" ];

	# RTL8852CE (rtw89): power-saving / ASPM causes throughput drops and spikes.
	# Also pin via cmdline so params apply even if modprobe conf races.
	boot.kernelParams = [
		"rtw89_core.disable_ps_mode=Y"
		"rtw89_pci.disable_aspm_l1=Y"
		"rtw89_pci.disable_aspm_l1ss=Y"
		"rtw89_pci.disable_clkreq=Y"
	];
	boot.extraModprobeConfig = ''
		options rtw89_core disable_ps_mode=Y
		options rtw89_pci disable_aspm_l1=Y disable_aspm_l1ss=Y disable_clkreq=Y
		options cfg80211 ieee80211_regdom=PL
	'';

	# Same silicon as WiFi; BT coexistence tanks throughput on RTL8852CE.
	# Soft-block at boot; unblock with: rfkill unblock bluetooth
	hardware.bluetooth.enable = false;
	boot.blacklistedKernelModules = [ "btusb" "btrtl" "btintel" "btbcm" "btmtk" ];

	# iwd: better WPA on this card than wpa_supplicant, but its default
	# roam-scans every ~60s cause recurring lag spikes on rtw89.
	networking.networkmanager.wifi.backend = "iwd";
	networking.wireless.iwd.settings = {
		General = {
			AddressRandomization = "disabled";
			RoamThreshold = "-90";
			RoamThreshold5G = "-95";
		};
		Scan = {
			DisablePeriodicScan = true;
		};
		Network = {
			EnableIPv6 = true;
			RoutePriorityOffset = 300;
		};
	};

	networking.networkmanager = {
		settings = {
			connectivity.enabled = false;
			connection."wifi.powersave" = 2;
		};
		# Prefer Cloudflare over ISP (play.pl / UPC) DNS — slow DNS feels like "slow wifi".
		insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
	};

	# Prefer home 5 GHz AP; never auto-fallback to phone hotspots.
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
					ipv4.ignore-auto-dns yes \
					ipv4.dns "1.1.1.1 1.0.0.1" \
					ipv6.ignore-auto-dns yes \
					ipv6.dns "2606:4700:4700::1111 2606:4700:4700::1001" \
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
	environment.systemPackages = [
		elden-ring-convergence
		pkgs.iw
	];

	# Optional: pin Steam so Elden Ring does not silently jump to an
	# unsupported patch while Convergence lags behind (check Nexus notes).
	# Set Auto-update → "Only update this game when I launch it" in Steam
	# properties for Elden Ring if Convergence is not yet on the latest patch.
}

