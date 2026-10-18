{ inputs, lib, pkgs, ... }:
{
	# Only import on hosts that boot CachyOS (currently TUF).
	nixpkgs.overlays = [
		inputs.nix-cachyos-kernel.overlays.pinned
	];

	nix.settings = {
		substituters = lib.mkAfter [ "https://attic.xuyh0120.win/lantian" ];
		trusted-public-keys = lib.mkAfter [
			"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
		];
	};

	boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-bore;

	boot.loader.grub.extraConfig = lib.mkAfter ''
		# Menu entries (with specialisations):
		# "NixOS" - CachyOS Gaming Kernel (BORE scheduler, gaming optimized)
		# "NixOS - cachyos-dev" - CachyOS Development (debug symbols, profiling tools)
		# "NixOS - stable-fallback" - Linux Stable Kernel (maximum compatibility)
	'';

	specialisation = {
		dev = {
			configuration = {
				system.nixos.tags = [ "cachyos-dev" ];

				boot.kernelParams = [
					"amd_pstate=guided"

					# Development-specific parameters
					"debug"
					"ignore_loglevel"
					"dyndbg=+p"
					"kgdboc=kbd"
				];

				boot.kernel.sysctl = {
					"kernel.dmesg_restrict" = 0;
					"kernel.perf_event_paranoid" = -1;
					"kernel.kptr_restrict" = 0;
					"kernel.yama.ptrace_scope" = 0;
				};
			};
		};

		stable = {
			configuration = {
				boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
				boot.kernelParams = [
					"amd_pstate=guided"

					# Conservative parameters for maximum stability
					"quiet"
					"splash"
					"loglevel=3"
				];
			};
		};
	};
}
