{ config, pkgs, inputs, unstable, ...}:
let
  NeoSolarized = pkgs.vimUtils.buildVimPlugin {
    name = "NeoSolarized";
    src = inputs.NeoSolarized;
  };
in
{
  programs.nixvim = {
    enable = true;
    
    opts = {
      number = true;
      relativenumber = true;
      cmdheight = 1;
      hlsearch = true;
      ignorecase = false;
      showmode = false;
      smartindent = true;
      swapfile = false;
      undofile = false;
      shiftwidth = 4;
      tabstop = 4;
      cursorline = false;
      numberwidth = 2;
      wrap = false;
      termguicolors = true;
      background = "dark";
      scrolloff = 8;
      clipboard = "unnamedplus";
    };
    
    globals = {
      mapleader = " ";
    };

    keymaps = [
      # Save and quit
      { mode = "n"; key = "<C-s>"; action = ":w<cr>"; options.desc = "Save file"; }
      { mode = "i"; key = "<C-s>"; action = "<Esc>:w<cr>a"; options.desc = "Save file (insert)"; }
      { mode = "n"; key = "<C-q>"; action = ":q<cr>"; options.desc = "Quit"; }

      # File Tree
      { mode = "n"; key = "<leader>pv"; action = ":Neotree toggle<cr>"; options.desc = "Toggle file tree"; }
      
      # Telescope
      { mode = "n"; key = "<leader>f"; action = ":Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>g"; action = ":Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>tb"; action = ":Telescope buffers<cr>"; options.desc = "Find buffers"; }
      { mode = "n"; key = "<leader>th"; action = ":Telescope help_tags<cr>"; options.desc = "Help tags"; }

      # Search and replace current word
      { 
        mode = "n";
        key = "<leader>s";
        action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
        options.desc = "Search and replace current word";
      }
    ];

    extraPlugins = [
      NeoSolarized
      pkgs.vimPlugins.vim-easy-align
      pkgs.vimPlugins.vim-surround  
      pkgs.vimPlugins.vim-multiple-cursors
      pkgs.vimPlugins.trouble-nvim
    ];

    plugins = {

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          pylsp.enable = true;
          lua_ls.enable = true;
          clangd.enable = true;
        };
      };

      treesitter = {
        enable = true;
      };

      lualine = {
        enable = true;
        theme = "solarized_dark";
      };

      telescope = {
        enable = true;
        settings = {
          defaults = {
            vimgrep_arguments = [
              "rg" "--color=never" "--no-heading"
              "--with-filename" "--line-number" 
              "--column" "--smart-case" "-uu"
            ];
          };
          pickers = {
            find_files = {
              hidden = true;
            };
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
      };

      luasnip.enable = true;

      neo-tree.enable = true;

      gitsigns.enable = true;

      nvim-autopairs.enable = true;

      dap = {
        enable = true;
        extensions.dap-ui.enable = true;
      };
    };

    extraConfigLua = ''
      -- Set colorscheme
      pcall(vim.cmd.colorscheme, "NeoSolarized")
      
      -- Include the colemak module from misc/
      package.path = package.path .. ";" .. vim.fn.stdpath('config') .. "/misc/?.lua"
      
      -- Simple Colemak toggle commands
      vim.api.nvim_create_user_command("Colemak", function()
        local ok, colemak = pcall(require, 'colemak')
        if ok then
          colemak.setup()
        else
          vim.notify("Colemak module not found", vim.log.levels.ERROR)
        end
      end, { desc = "Enable Colemak mappings" })
      
      vim.api.nvim_create_user_command("Qwerty", function()
        local ok, colemak = pcall(require, 'colemak')
        if ok then
          colemak.disable()
        else
          vim.notify("Colemak module not found", vim.log.levels.ERROR)
        end
      end, { desc = "Disable Colemak mappings" })

      -- Easy align setup
      vim.keymap.set({'n', 'x'}, 'ga', '<Plug>(EasyAlign)', { desc = 'Easy Align' })
      
      -- Trouble setup
      require('trouble').setup({ icons = false })
    '';

    extraPackages = with unstable; [
    ];
  };

  # Copy the colemak.lua file to the right place
  home.file.".config/nvim/misc/colemak.lua".source = ./misc/colemak.lua;
}
