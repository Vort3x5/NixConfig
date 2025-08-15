-- NoPlug
vim.g.mapleader = ' '

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

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

-- Plug

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', telescope.find_files, {})
vim.keymap.set('n', '<leader>g', telescope.live_grep, {})
vim.keymap.set('n', '<leader>tb', telescope.buffers, {})
vim.keymap.set('n', '<leader>th', telescope.help_tags, {})

-- vim-easy-align
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true }) -- Visual mode
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true }) -- Normal mode
