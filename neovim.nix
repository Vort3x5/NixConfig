{ pkgs, ... }:
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
      
      # File navigation
      telescope-nvim
      telescope-fzf-native-nvim

      # theme
	  colorbuddy-nvim
      
      # Treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        lua nix python rust c cpp bash fish sql vim go wgsl llvm
      ]))
      
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
  
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
