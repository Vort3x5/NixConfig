{
  description = "Vort3x Home Manager Configuration";

  inputs = {
	 nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";
    
    home-manager = {
	   url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixneovimplugins, ... }@inputs:
  let
    system = "x86_64-linux";
    
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        nixneovimplugins.overlays.default
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

    keyboardLayout = pkgs.lib.trim (builtins.readFile /home/vortex/.config/layout);
    
    makeHomeConfig = layout: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
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
        ./home.nix
        ./x11.nix  
        ./neovim.nix
      ];
    };
  in
  {
    homeConfigurations = {
      "vortex-colemak" = makeHomeConfig "colemak";
      "vortex-qwerty" = makeHomeConfig "qwerty";
    };
    
    homeConfigurations.vortex = makeHomeConfig keyboardLayout;
  };
}
