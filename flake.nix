{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

		nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";

		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = {self, nixpkgs, nixpkgs-unstable, nixos-hardware, nix-cachyos-kernel, sops-nix, nixneovimplugins, ...}@inputs:
	let

    unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
    };

	sharedModules = [
	    ./vortex.nix

		sops-nix.nixosModules.sops

		({ pkgs, ... }:{
			nixpkgs.overlays = [
				nix-cachyos-kernel.overlays.pinned
				nixneovimplugins.overlays.default
			];
		})
	];

	mkSystem = hostname: extraModules: nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit inputs unstable;
		};
		modules = sharedModules ++ extraModules;
	};

	in
	{
		nixosConfigurations = { 
			TUF = mkSystem "TUF" [
				./TUF/hardware-configuration.nix
				./TUF/configuration.nix
			];

			Gaming = mkSystem "Gaming" [
				./Gaming/hardware-configuration.nix
				./Gaming/configuration.nix
			];

			Edu = mkSystem "Edu" [
				./Edu/hardware-configuration.nix
				./Edu/configuration.nix
			];
		};
	};
}
