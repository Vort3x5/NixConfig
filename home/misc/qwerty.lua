-- Move selected lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Move current line in normal mode
vim.keymap.set("n", "<A-j>", ":move .+1<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":move .-2<CR>", { desc = "Move line up" })
