require'nvim-treesitter.configs'.setup {
	ensure_installed = {"llvm", "c", "cpp", "lua", "rust", "fish", "python", "bash", "sql", "vim", "go", "wgsl" },
	sync_install = true,
	auto_install = true,
	highlight = { 
		enable = true, 

		disable = {"c", "c++", "rust"},

		disable = function(lang, buf)
			local max_filesize = 100 * 1024
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,

		additional_vim_regex_highlighting = true,
	},
}
