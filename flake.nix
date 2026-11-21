{
	description = "Vort3x'5 NixOS Config";

	# Applied when this flake is evaluated (needs accept-flake-config).
	# Daemon/system substituters still live in vortex/kernel-cachyos.nix.
	nixConfig = {
		extra-substituters = [ "https://cache.lantian.pub/lantian" ];
		extra-trusted-public-keys = [
			"lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
		];
	};

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

		# Cursor moves faster than nixpkgs; this flake tracks upstream AppImages (~3x/week).
		code-cursor-nix.url = "github:jacopone/code-cursor-nix";

		nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, nix-cachyos-kernel, code-cursor-nix, sops-nix, nixneovimplugins, ... }@inputs:
	let
		unstable = import nixpkgs-unstable {
			system = "x86_64-linux";
			config.allowUnfree = true;
		};

		sharedModules = [
			./vortex/common.nix
			sops-nix.nixosModules.sops
			({ pkgs, ... }: {
				nixpkgs.overlays = [
					nixneovimplugins.overlays.default
					code-cursor-nix.overlays.default
					# Keep existing `code-cursor` attr used in vortex/pkgs-common.nix.
					(final: prev: {
						code-cursor = final.cursor;
					})
				];
			})
		];

		mkSystem = hostname: extraModules: nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			specialArgs = {
				inherit inputs unstable;
			};
			modules = sharedModules ++ [
				{ networking.hostName = hostname; }
			] ++ extraModules;
		};
	in
	{
		nixosConfigurations = {
			TUF = mkSystem "TUF" [
				./TUF/hardware-configuration.nix
				./TUF/configuration.nix
				./vortex/gaming.nix
				./vortex/devtools.nix
				./vortex/kernel-cachyos.nix
			];

			Gaming = mkSystem "Gaming" [
				./Gaming/hardware-configuration.nix
				./Gaming/configuration.nix
				./vortex/gaming.nix
				./vortex/devtools.nix
			];

			Edu = mkSystem "Edu" [
				./Edu/hardware-configuration.nix
				./Edu/configuration.nix
			];
		};
	};
}
