{
	description = "Vort3x'5 NixOS Config";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		# Cursor moves faster than nixpkgs; this flake tracks upstream AppImages (~3x/week).
		code-cursor-nix.url = "github:jacopone/code-cursor-nix";

		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, code-cursor-nix, home-manager, sops-nix, ... }@inputs:
	let
		system = "x86_64-linux";

		unstable = import nixpkgs-unstable {
			inherit system;
			config.allowUnfree = true;
		};

		# Shared overlay: Cursor AppImage + alias used by vortex/pkgs-common.nix.
		cursorOverlay = final: prev: {
			code-cursor = final.cursor;
		};

		sharedModules = [
			./vortex/common.nix
			./vortex/sops.nix
			sops-nix.nixosModules.sops
			({ pkgs, ... }: {
				nixpkgs.overlays = [
					code-cursor-nix.overlays.default
					cursorOverlay
				];
			})
		];

		mkSystem = hostname: extraModules: nixpkgs.lib.nixosSystem {
			inherit system;
			specialArgs = {
				inherit inputs unstable;
			};
			modules = sharedModules ++ [
				{ networking.hostName = hostname; }
			] ++ extraModules;
		};

		# Home Manager: keep standalone configs so `home-manager switch` stays independent
		# of nixos-rebuild. Layout is read from ~/.config/layout at eval time.
		hmPkgs = import nixpkgs {
			inherit system;
			overlays = [
				# GitHub rewrote/re-exported zbirenbaum/copilot.lua@v2.0.4; nixpkgs hash is stale.
				(final: prev: {
					vimPlugins = prev.vimPlugins.extend (self: super: {
						copilot-lua = super.copilot-lua.overrideAttrs (old: {
							src = prev.fetchFromGitHub {
								owner = "zbirenbaum";
								repo = "copilot.lua";
								rev = "refs/tags/v2.0.4";
								hash = "sha256-05f76OeWBlFmlUh90tH4XMMKfNI1jnhuIJDqYPPQokA=";
							};
						});
					});
				})
			];
			config.allowUnfree = true;
		};

		keyboardLayout = nixpkgs.lib.trim (builtins.readFile /home/vortex/.config/layout);

		makeHomeConfig = layout: home-manager.lib.homeManagerConfiguration {
			pkgs = hmPkgs;
			modules = [
				{
					home = {
						username = "vortex";
						homeDirectory = "/home/vortex";
						stateVersion = "26.05";
					};

					_module.args = {
						inherit unstable;
						layout = layout;
					};
				}
				./home/home.nix
				./home/x11.nix
				./home/neovim.nix
			];
		};
	in
	{
		nixosConfigurations = {
			TUF = mkSystem "TUF" [
				./TUF/hardware-configuration.nix
				./TUF/configuration.nix
				./vortex/gaming.nix
				./vortex/devtools.nix
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

		homeConfigurations = {
			"vortex-colemak" = makeHomeConfig "colemak";
			"vortex-qwerty" = makeHomeConfig "qwerty";
			vortex = makeHomeConfig keyboardLayout;
		};
	};
}
