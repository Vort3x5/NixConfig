-- COLORSCHEME SETUP (Neosolarized) {{{
local function setup_colorscheme()
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

-- TREESITTER SETUP (NixOS Compatible) {{{
local function setup_treesitter()
  local status, configs = pcall(require, 'nvim-treesitter.configs')
  if not status then return end

  configs.setup {
    -- CRITICAL: NixOS compatibility settings
    ensure_installed = {}, -- Empty for NixOS - parsers managed by Nix
    auto_install = false,  -- Disable auto-installation
    sync_install = false,  -- Don't install parsers synchronously
    
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    
    indent = {
      enable = true,
    },
    
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  }
end
-- }}}

-- LSP SETUP {{{
local function setup_lsp()
  local status, lspconfig = pcall(require, 'lspconfig')
  if not status then return end

  -- Lua Language Server {{{
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = {'vim'},
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
  -- }}}

  -- Other Language Servers {{{
  lspconfig.nil_ls.setup({})      -- Nix
  lspconfig.clangd.setup({})      -- C/C++
  lspconfig.pylsp.setup({})       -- Python

  -- Rust Analyzer
  lspconfig.rust_analyzer.setup({
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
      },
    },
  })
  -- }}}
end
-- }}}

-- COMPLETION SETUP (nvim-cmp) {{{
local function setup_completion()
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
    
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
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
  -- }}}
end
-- }}}

-- TELESCOPE SETUP {{{
local function setup_telescope()
  local status, telescope = pcall(require, 'telescope')
  if not status then return end

  -- Telescope configuration {{{
  telescope.setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color=never',
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

  -- Telescope keymaps {{{
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
  -- }}}
end
-- }}}

-- LUALINE SETUP (Status Line) {{{
local function setup_lualine()
  local status, lualine = pcall(require, 'lualine')
  if not status then return end

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = 'solarized_dark',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
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

-- AUTOPAIRS SETUP {{{
local function setup_autopairs()
  local status, autopairs = pcall(require, 'nvim-autopairs')
  if not status then return end

  -- Autopairs configuration {{{
  autopairs.setup({
    check_ts = true,                        -- Enable treesitter
    ts_config = {
      lua = {'string', 'source'},          -- Don't add pairs in lua string treesitter nodes
      javascript = {'string', 'template_string'}, -- Don't add pairs in javscript template_string
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      offset = 0, -- Offset from pattern match
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'PmenuSel',
      highlight_grey = 'LineNr'
    },
  })
  -- }}}

  -- CMP integration {{{
  local status_cmp, cmp = pcall(require, 'cmp')
  if status_cmp then
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  end
  -- }}}
end
-- }}}

-- MULTIPLE CURSORS SETUP {{{
local function setup_multicursor()
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

-- TERMINAL CURSOR SETUP {{{
local function setup_terminal_cursor()
  vim.cmd[[
    augroup change_cursor
        au!
        au ExitPre * :set guicursor=a:ver90
    augroup END
  ]]
end
-- }}}

-- KEYMAPS AND GENERAL SETTINGS {{{
local function setup_keymaps()
  -- Set leader key
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- General keymaps {{{
  vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Open file explorer' })
  -- }}}
  
  -- LSP keymaps (set up when LSP attaches) {{{
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
      local opts = { buffer = event.buf }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
      vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
      vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
    end
  })
  -- }}}

  -- Fold keymaps {{{
  vim.keymap.set('n', '<leader>za', 'za', { desc = 'Toggle fold' })
  vim.keymap.set('n', '<leader>zM', 'zM', { desc = 'Close all folds' })
  vim.keymap.set('n', '<leader>zR', 'zR', { desc = 'Open all folds' })
  -- }}}
end
-- }}}

-- MAIN SETUP FUNCTION {{{
local function setup_all()
  -- Setup in order of dependencies
  setup_colorscheme()
  setup_treesitter()
  setup_lsp()
  setup_completion()
  setup_telescope()
  setup_lualine()
  setup_autopairs()
  setup_multicursor()
  setup_terminal_cursor()
  setup_keymaps()
end

-- Initialize everything
setup_all()
-- }}}
