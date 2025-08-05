{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		sops-nix = {
			url = "github:Mic92/sops-nix/9517dcb";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};
	};

	outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, sops-nix, ...}@inputs:
	let

	sharedModules = [
	    ./vortex.nix

		sops-nix.nixosModules.sops

		home-manager.nixosModules.home-manager
		{
			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "backup";
			home-manager.users.vortex = { config, pkgs, ... }:
			    nixpkgs.lib.mkMerge [
				    (import ./home.nix { inherit config pkgs; })
				    (import ./x11.nix { inherit config pkgs; })
				];
			home-manager.extraSpecialArgs = { inherit inputs; };
		}
	];

	mkSystem = hostname: extraModules: nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit inputs;
			unstable = import nixpkgs-unstable {
				system = "x86_64-linux";
				config.allowUnfree = true;
			};
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
