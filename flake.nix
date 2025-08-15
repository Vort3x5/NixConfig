{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
		nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";

		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = {self, nixpkgs, nixpkgs-unstable, chaotic, home-manager, nixos-hardware, sops-nix, nixneovimplugins, ...}@inputs:
	let

    unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
    };

	sharedModules = [
	    ./vortex.nix

		chaotic.nixosModules.default

		sops-nix.nixosModules.sops

		home-manager.nixosModules.home-manager
		{
			nixpkgs.overlays = [ nixneovimplugins.overlays.default ];

			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "backup";
			home-manager.users.vortex = { config, pkgs, ... }: {
			    imports = [
				    ./home.nix
				    ./x11.nix
				    ./neovim.nix
				];
			};
			home-manager.extraSpecialArgs = { inherit inputs unstable; };
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
