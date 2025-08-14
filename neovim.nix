{ inputs, unstable, ... }:
let
  colorbuddy = unstable.vimUtils.buildVimPlugin {
    name = "colorbuddy";
    src = inputs.colorbuddy;
  };
  
  neosolarized = unstable.vimUtils.buildVimPlugin {
    name = "neosolarized";
    src = inputs.neosolarized;
  };
in
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    vimAlias = true;
    viAlias = false;
    
    plugins = with unstable.vimPlugins; [
      plenary-nvim
      nvim-web-devicons
      
      lualine-nvim
      colorbuddy
      neosolarized
      
      telescope-nvim
      telescope-fzf-native-nvim
      
      (nvim-treesitter.withPlugins (p: with p; [
        lua
        nix
        python
        rust
        c
        cpp
        bash
        fish
        sql
        vim
        go
        wgsl
        llvm
      ]))
      
      gitsigns-nvim
      
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      
      vim-surround
      vim-multiple-cursors
      vim-easy-align
      nvim-autopairs
      
      rust-vim
      rust-tools-nvim
      vim-llvm
      
      nvim-dap
      nvim-dap-ui
      
      trouble-nvim
    ];
    
    extraPackages = with unstable; [
      lua-language-server
      nil
      clang-tools
      python3Packages.python-lsp-server
      rust-analyzer
      
      ripgrep
      fd
      
      tree-sitter
    ];
    
    extraConfig = "";
  };
  
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
