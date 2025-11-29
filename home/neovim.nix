{ pkgs, layout ? "colemak", ... }:
let
	tree-sitter-jai = pkgs.tree-sitter.buildGrammar {
		language = "jai";
		version = "1.0.0";
		src = ./nvim/plugin/tree-sitter-jai;
	};
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = false;
    
    plugins = (with pkgs.vimPlugins; [
      # Core dependencies
      plenary-nvim
      nvim-web-devicons
      
      # UI
      lualine-nvim

	  copilot-vim
	  CopilotChat-nvim
      
      # File navigation
      telescope-nvim
      telescope-fzf-native-nvim

	  vim-dispatch

      # svrana/neosolarized requires this
	  colorbuddy-nvim
	  
      
      # Treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        lua nix python rust c cpp java matlab go
		bash fish sql vim make yaml toml
		wgsl llvm
      ] ++ [ tree-sitter-jai ]))
      
      # Git
      gitsigns-nvim
      
      # LSP & Completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      
      # Editing
      vim-surround
      vim-multiple-cursors
      vim-easy-align
      nvim-autopairs
      
      # Language specific
      rust-vim
      rustaceanvim
      vim-llvm
      
      # Debug & Diagnostics
      nvim-dap
      nvim-dap-ui
      trouble-nvim

    ]) ++ [
	  pkgs.vimExtraPlugins.neosolarized-nvim-svrana
	];
    
    extraPackages = with pkgs; [
      lua-language-server
      nil
      clang-tools
      python3Packages.python-lsp-server
      rust-analyzer
      ripgrep
      fd
      tree-sitter
    ];
  };
  
	xdg.configFile = {
		"nvim/init.lua".source = ./nvim/init.lua;

		"nvim/lua/plugs.lua".source = ./nvim/lua/plugs.lua;
		"nvim/lua/options.lua".source = ./nvim/lua/options.lua;
		"nvim/lua/keymaps.lua".source = ./nvim/lua/keymaps.lua;

		"nvim/plugin/optimize.lua".source = ./nvim/plugin/optimize.lua;
		"./nvim/plugin/layout-keymaps.lua" = if layout == "colemak" then {
			source = ./misc/colemak.lua;
		}
		else {
			source = ./misc/qwerty.lua;
		};
	};
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
