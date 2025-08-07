{ config, pkgs, inputs, ...}:
let
	NeoSolarized = pkgs.vimUtils.buildVimPlugin {
		name = "NeoSolarized";
		src = inputs.NeoSolarized;
	};
in
{
    programs.nvf = {
        enable = true;
        
        settings = {
            vim = {
				additionalRuntimePaths = [ ./misc ];

                viAlias = false;
                vimAlias = true;
                globals.mapleader = " ";
                
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

                # Basic keymaps to start
                keymaps = [
                    # Save and quit
                    { key = "<C-s>"; mode = "n"; action = ":w<cr>"; desc = "Save file"; }
                    { key = "<C-s>"; mode = "i"; action = "<Esc>:w<cr>a"; desc = "Save file (insert)"; }
                    { key = "<C-q>"; mode = "n"; action = ":q<cr>"; desc = "Quit"; }

                    # File Tree
					{ key = "<leader>pv"; mode = "n"; action = ":Neotree toggle<cr>"; desc = "Toggle file tree"; }
                    
                    # Telescope
                    { key = "<leader>f"; mode = "n"; action = ":Telescope find_files<cr>"; desc = "Find files"; }
                    { key = "<leader>g"; mode = "n"; action = ":Telescope live_grep<cr>"; desc = "Live grep"; }
                    { key = "<leader>tb"; mode = "n"; action = ":Telescope buffers<cr>"; desc = "Find buffers"; }
                    { key = "<leader>th"; mode = "n"; action = ":Telescope help_tags<cr>"; desc = "Help tags"; }

                    # Search and replace current word
                    { 
                        key = "<leader>s"; 
                        mode = "n"; 
                        action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
                        desc = "Search and replace current word"; 
                    }
                ];

                theme.enable = false

				startPlugins = [
					NeoSolarized
					pkgs.vimPlugins.vim-easy-align
					pkgs.vimPlugins.vim-surround
					pkgs.vimPlugins.vim-multiple-cursors
					pkgs.vimPlugins.nvim-autopairs
				];

				treesitter = {
                    enable = true;
                    grammars = [
                        "llvm" "c" "cpp" "lua" "rust" "fish" 
                        "python" "bash" "sql" "vim" "go"
                    ];
                    highlight = {
                        enable = true;
                        disable = [ "c" "cpp" "rust" ];
                        additionalVimRegexHighlighting = true;
                    };
                };

				statusline.lualine = {
                    enable = true;
                    theme = "NeoSolarized";
                    componentSeparators = {
                        left = "";
                        right = "";
                    };
                    sectionSeparators = {
                        left = "";
                        right = "";
                    };
                    sections = {
                        lualine_a = [ "mode" ];
                        lualine_b = [ "branch" ];
                        lualine_c = [ "filename" ];
                        lualine_x = [ "encoding" "filetype" ];
                        lualine_y = [ "progress" ];
                        lualine_z = [ "location" ];
                    };
                    inactiveSections = {
                        lualine_a = [ ];
                        lualine_b = [ ];
                        lualine_c = [ "filename" ];
                        lualine_x = [ "location" ];
                        lualine_y = [ ];
                        lualine_z = [ ];
                    };
                };

                # Telescope with your ripgrep settings
                telescope = {
                    enable = true;
                    setupOpts = {
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

                lsp = {
                    enable = true;
                    servers = {
						nil_ls.enable = true;
                        pylsp.enable = true;
                        lua_ls.enable = true;
                        clangd.enable = true;
                        bashls.enable = true;
                    };
                };

                autocomplete.nvim-cmp = {
                    enable = true;
                    setupOpts = {
                        sources = [
                            { name = "nvim_lsp"; }
                            { name = "luasnip"; }
                            { name = "buffer"; }
                            { name = "path"; }
                        ];
                    };
                };

				snippets.luasnip.enable = true;

				filetree.neo-tree.enable = true;

				git = {
					enable = true;
					gitsigns.enable = true;
				};

				debugger.nvim-dap = {
					enable = true;
					ui.enable = true;
				};

				lazy = {
                    enable = true;
                    plugins = {
						"NeoSolarized.nvim" = {
                            package = NeoSolarized;
                            setupModule = "NeoSolarized";
                            setupOpts = {
                                style = "dark";
                                transparent = false;
                                terminal_colors = true;
                                enable_italics = true;
                                styles = {
                                    comments = { italic = true; };
                                    keywords = { italic = true; };
                                    functions = { bold = true; };
                                    variables = { };
                                    string = { italic = false; };
                                    underline = true;
                                    undercurl = true;
                                };
                            };
                            # Load early and set colorscheme
                            priority = 1000;
                            lazy = false;
                            after = ''
                                vim.cmd.colorscheme("NeoSolarized")
                            '';
                        };

                        "vim-easy-align" = {
                            package = pkgs.vimPlugins.vim-easy-align;
                            keys = [
                                { key = "ga"; mode = [ "n" "x" ]; action = "<Plug>(EasyAlign)"; desc = "Easy Align"; }
                            ];
                        };
                        
                        "trouble.nvim" = {
                            package = pkgs.vimPlugins.trouble-nvim;
                            setupModule = "trouble";
                            setupOpts = {
                                icons = false;
                            };
                            cmd = [ "Trouble" ];
                        };
                        
                        "nvim-autopairs" = {
                            package = pkgs.vimPlugins.nvim-autopairs;
                            setupModule = "nvim-autopairs";
                            event = [ "InsertEnter" ];
                        };
                    };
                };

				luaConfigRC = {
                    colemak-commands = ''
                        -- Simple Colemak toggle commands
                        vim.api.nvim_create_user_command("Colemak", function()
                            require('colemak').setup()
                        end, { desc = "Enable Colemak mappings" })
                        
                        vim.api.nvim_create_user_command("Qwerty", function()
                            require('colemak').disable()
                        end, { desc = "Disable Colemak mappings" })
                    '';
                };

                extraPackages = with pkgs; [
                    rust-analyzer nil python3Packages.python-lsp-server
                    lua-language-server clang-tools nodePackages.bash-language-server
                    ripgrep fd rustc cargo gcc python3
                ];
            };
        };
    };
}
