{ config, pkgs, inputs, unstable, ...}:
let
  NeoSolarized = pkgs.vimUtils.buildVimPlugin {
    name = "NeoSolarized";
    src = inputs.NeoSolarized;
  };
in
{
  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim = {

          package = unstable.neovim-unwrapped;

          extraPackages = with unstable; [
              tree-sitter
              nodejs
              gcc
          ];

        viAlias = false;
        vimAlias = true;
        
        options = {
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

        languages = {
            enableTreesitter = true;
            enableLSP = true;
            enableFormat = true;
            enableExtraDiagnostics = true;
            nix.enable = true;
            clang.enable = true;
            python = {
                enable = true;
                lsp = {
                    server = "basedpyright";
                    package = unstable.basedpyright;
                };
            };
            lua.enable = true;
            markdown.enable = true;
        };

        globals = {
          mapleader = " ";
        };

        theme = {
          enable = false;
        };

        telescope = {
          enable = true;
        };

        filetree = {
          neo-tree = {
            enable = true;
          };
        };

        statusline = {
          lualine = {
            enable = true;
            theme = "solarized_dark";
          };
        };

        git = {
          gitsigns = {
                  enable = true;
          };
        };

        autocomplete = {
          nvim-cmp = {
            enable = true;
            sources = {
              nvim_lsp = "[LSP]";
              buffer = "[Buffer]";
              path = "[Path]";
            };
          };
        };

        snippets = {
          luasnip = {
            enable = true;
          };
        };

        autopairs = {
          nvim-autopairs = {
            enable = true;
          };
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui = {
              enable = true;
            };
          };
        };

        maps = {
          normal = {
            "<C-s>" = {
              action = ":w<cr>";
              desc = "Save file";
            };
            "<C-q>" = {
              action = ":q<cr>";
              desc = "Quit";
            };

            "<leader>pv" = {
              action = ":Neotree toggle<cr>";
              desc = "Toggle file tree";
            };

            "<leader>f" = {
              action = ":Telescope find_files<cr>";
              desc = "Find files";
            };
            "<leader>g" = {
              action = ":Telescope live_grep<cr>";
              desc = "Live grep";
            };
            "<leader>b" = {
              action = ":Telescope buffers<cr>";
              desc = "Find buffers";
            };
            "<leader>th" = {
              action = ":Telescope help_tags<cr>";
              desc = "Help tags";
            };

            "<leader>s" = {
              action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
              desc = "Search and replace current word";
            };
          };

          insert = {
            "<C-s>" = {
              action = "<Esc>:w<cr>a";
              desc = "Save file (insert)";
            };
          };
        };

        # Extra plugins - NeoSolarized and others
        extraPlugins = {

            nvim-treesitter = {
                package = unstable.vimPlugins.nvim-treesitter;
            };

          neo-solarized = {
            package = NeoSolarized;
            setup = ''
            vim.cmd.colorscheme("NeoSolarized");
            '';
          };

          vim-surround = {
            package = pkgs.vimPlugins.vim-surround;
          };

          vim-multiple-cursors = {
            package = pkgs.vimPlugins.vim-multiple-cursors;
          };

          trouble = {
            package = pkgs.vimPlugins.trouble-nvim;
            setup = ''
              require('trouble').setup({ icons = false })
            '';
          };

          vim-easy-align = {
            package = pkgs.vimPlugins.vim-easy-align;
            setup = ''
              vim.keymap.set({'n', 'x'}, 'ga', '<Plug>(EasyAlign)', { desc = 'Easy Align' })
            '';
          };
        };
      };
    };
  };
}
