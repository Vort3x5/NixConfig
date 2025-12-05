-- colorscheme (neosolarized) {{{
local function colorscheme()
  local status_cb, cb = pcall(require, 'colorbuddy.init')
  if not status_cb then
    vim.notify("colorbuddy not found, falling back to basic neosolarized", vim.log.levels.WARN)
    vim.cmd("silent! colorscheme neosolarized")
    return
  end

  local status_neo, n = pcall(require, "neosolarized")
  if not status_neo then 
    vim.notify("neosolarized not found", vim.log.levels.ERROR)
    return 
  end

  -- Setup neosolarized
  n.setup({
    comment_italics = true,
    background_set = false
  })

  -- Colorbuddy customizations
  local Color = cb.Color
  local colors = cb.colors
  local Group = cb.Group
  local styles = cb.styles

  Color.new('white', '#ffffff')
  Color.new('black', '#000000')

  Group.new('Normal', colors.base1, colors.NONE, styles.NONE)
  Group.new('CursorLine', colors.none, colors.base03, styles.NONE, colors.base1)
  Group.new('CursorLineNr', colors.yellow, colors.black, styles.NONE, colors.base1)
  Group.new('Visual', colors.none, colors.base03, styles.reverse)

  vim.cmd("colorscheme neosolarized")
end
-- }}}

-- autopairs {{{
local function autopairs()
  local status, autopairs = pcall(require, 'nvim-autopairs')
  if not status then return end

  autopairs.setup({
    check_ts = true,
    map_cr = true,
    map_bs = true,
    enable_check_bracket_line = true,
    break_undo = true,
    enable_moveright = true,
    enable_afterquote = true,
    enable_bracket_in_quote = true,
  })
end
-- }}}

-- treesitter {{{
local function treesitter()
  local status, configs = pcall(require, 'nvim-treesitter.configs')
  if not status then return end

  configs.setup {
    highlight = {
      enable = true,
	  additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  }
	vim.treesitter.language.register('jai', 'jai')
end
-- }}}

-- LSP {{{
local function lsp()
  local status, lspconfig = pcall(require, 'lspconfig')
  if not status then return end

  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

	vim.diagnostic.disable();

  lspconfig.nil_ls.setup({})
  lspconfig.clangd.setup({})
  lspconfig.pylsp.setup({})

  lspconfig.rust_analyzer.setup({
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
      },
    },
  })
	vim.fn.timer_start(1000 * 60 * 120, function()
		vim.cmd("LspRestart")
	end, {["repeat"] = -1})
end
-- }}}

-- nvim-cmp {{{
local function completion()
  local status_cmp, cmp = pcall(require, 'cmp')
  if not status_cmp then return end

  local status_luasnip, luasnip = pcall(require, 'luasnip')

  -- Main completion setup {{{
  cmp.setup({
    snippet = status_luasnip and {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    } or nil,
    
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping.select_next_item(),
      ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    
    sources = cmp.config.sources(
	{
      { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, 
	{
      { name = 'buffer' },
      { name = 'path' },
    })
  })
  -- }}}
  
  -- Command line completion {{{
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
  
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  local status_autopairs, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
  if status_autopairs then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
  -- }}}
end
-- }}}

-- Copilot {{{
local function copilot()
	local status, chat = pcall(require, 'CopilotChat')
	if not status then return end

	chat.setup({
		model = 'claude-sonnet-4.5',
		temperature = 0.1,

		window = {
 			layout = 'horizontal',
			width = 0.4,
		},

		auto_insert_mode = true,
	})
end
--}}}

-- telescope {{{
local function telescope()
  local status, telescope = pcall(require, 'telescope')
  if not status then return end

  -- Telescope configuration {{{
  telescope.setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '-uu'
      }
    },
    pickers = {
      find_files = {
        hidden = true,
      }
    }
  }
  -- }}}
end
-- }}}

-- vim-dispatch {{{
local function dispatch()
	vim.g.dispatch_no_maps = 1

	vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      if vim.fn.filereadable("Makefile") == 1 then
        vim.opt.makeprg = "make"
      elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
        vim.opt.makeprg = "cmake --build build"
      end
    end
  })
  
  -- Auto-open quickfix on errors
  vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    callback = function()
      if #vim.fn.getqflist() > 0 then
        vim.cmd("copen")
      end
    end
  })
end
-- }}}

-- lualine {{{
local function lualine()
  local status, lualine = pcall(require, 'lualine')
  if not status then return end

  lualine.setup {
    options = {
      icons_enabled = false,
      theme = 'solarized_dark',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 200,
        tabline = 200,
        winbar = 200,
      }
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
  }
end
-- }}}

-- multiple cursors {{{
local function multicursor()
  -- Multiple cursor key mappings
  vim.g.multi_cursor_use_default_mapping = 0
  vim.g.multi_cursor_start_word_key = '<C-n>'
  vim.g.multi_cursor_select_all_word_key = '<A-n>'
  vim.g.multi_cursor_start_key = 'g<C-n>'
  vim.g.multi_cursor_select_all_key = 'g<A-n>'
  vim.g.multi_cursor_next_key = '<C-n>'
  vim.g.multi_cursor_prev_key = '<C-p>'
  vim.g.multi_cursor_skip_key = '<C-x>'
  vim.g.multi_cursor_quit_key = '<Esc>'
end
-- }}}

-- terminal cursor {{{
local function terminal_cursor()
  vim.cmd[[
    augroup change_cursor
        au!
        au ExitPre * :set guicursor=a:ver90
    augroup END
  ]]
end
-- }}}

-- Jai {{{
local function jai()
	vim.filetype.add({
		extension = {
			jai = 'jai',
		},
	})
end
-- }}}

-- Setup All {{{
colorscheme()
autopairs()
treesitter()
lsp()
completion()
telescope()
dispatch()
lualine()
multicursor()
terminal_cursor()
jai()
copilot()
-- }}}
