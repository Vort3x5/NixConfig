{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		nixos-cachyos-kernel.url = "github:drakon64/nixos-cachyos-kernel";

		nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";

		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = {self, nixpkgs, nixpkgs-unstable, nixos-hardware, sops-nix, nixneovimplugins, nixos-cachyos-kernel, ...}@inputs:
	let

    unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
    };

	sharedModules = [
	    ./vortex.nix

		sops-nix.nixosModules.sops
		nixos-cachyos-kernel.nixosModules.default

		{
			nixpkgs.overlays = [ nixneovimplugins.overlays.default ];
		}
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

		packages.x86_64-linux.iso = self.nixosConfigurations.TUF.config.system.build.isoImage;
	};
}
