-- NoPlug
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Open file explorer' })

-- Save With "Ctrl + s" In Both Normal And Insert Mode
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")

-- Exit With "Ctrl + q" In Both Normal And Insert Mode
vim.keymap.set("n", "<C-q>", ":q<CR>")
vim.keymap.set("i", "<C-q>", "<Esc>:q<CR>a")

-- Turn Exit with "Ctrl + w" Off
vim.keymap.set("n", "<C-w>", "")
vim.keymap.set("i", "<C-w>", "")

-- Terminal Exit Insert Mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

-- Movement

-- cursor in the middle when paging up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- paste without changing clipboard
vim.keymap.set("x", "<leader>p", "\"_dP")

-- replace current word in whole file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Plugs {{{

-- Telescope {{{
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', telescope.find_files, {})
vim.keymap.set('n', '<leader>g', telescope.live_grep, {})
vim.keymap.set('n', '<leader>b', telescope.buffers, {})
vim.keymap.set('n', '<leader>h', telescope.help_tags, {})
-- }}}

-- vim-easy-align {{{
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true }) -- Visual mode
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true }) -- Normal mode
-- }}}

-- LSP keymaps (set up when LSP attaches) {{{
vim.api.nvim_create_autocmd('LspAttach', {
callback = function(event)
  local opts = { buffer = event.buf }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
end
})
-- }}}

-- compile-mode keymaps {{{
vim.keymap.set('n', '<leader>m', ':Make<CR>', { desc = "Compile" })
vim.keymap.set('n', '<leader>mc', ':Make clean<CR>', { desc = "Clean" })
vim.keymap.set('n', '<leader>mr', ':Dispatch make clean && make<CR>', { desc = "Recompile" })

vim.keymap.set('n', '<leader>EF', ':cfirst<CR>', { desc = "First error" })
vim.keymap.set('n', '<leader>EL', ':clast<CR>', { desc = "Last error" })

vim.keymap.set('n', ';e', ':cc<CR>', { desc = "Current error" })
vim.keymap.set('n', ']e', ':cnext<CR>', { desc = "Next error" })
vim.keymap.set('n', '[e', ':cprev<CR>', { desc = "Previous error" })

vim.keymap.set('n', '<leader>qf', ':copen<CR>', { desc = "Open compilation results" })
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', { desc = "Close compilation results" })
-- }}}

-- Copilot {{{
vim.keymap.set('n', '<leader>cm', ':CopilotChatModels<CR>', { desc = 'Select Copilot Model' })
vim.keymap.set({'n', 'v'}, '<leader>ce', ':CopilotChatExplain<CR>', { desc = 'Explain code' })
vim.keymap.set({'n', 'v'}, '<leader>cf', ':CopilotChatFix<CR>', { desc = 'Fix code' })
vim.keymap.set({'n', 'v'}, '<leader>co', ':CopilotChatOptimize<CR>', { desc = 'Optimize code' })
-- }}}
-- }}}
