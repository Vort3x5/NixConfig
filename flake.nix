{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		sops-nix = {
			url = "github:Mic92/sops-nix/9517dcb";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		nvf = {
			url = "github:notashelf/nvf";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		NeoSolarized = {
			url = "github:Tsuzat/NeoSolarized.nvim";
			flake = false;
		};
	};

	outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, sops-nix, nvf, ...}@inputs:
	let

    unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
    };

	sharedModules = [
	    ./vortex.nix

		sops-nix.nixosModules.sops

		home-manager.nixosModules.home-manager
		{
			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "backup";
			home-manager.users.vortex = { config, pkgs, ... }: {
			    imports = [
				nvf.homeManagerModules.default
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
