vim.pack.add({
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
})

local quarto = require("quarto")
quarto.setup({
	lspFeatures = {
		-- NOTE: put whatever languages you want here:
		languages = { "r", "python", "rust" },
		chunks = "all",
		diagnostics = {
			enabled = true,
			triggers = { "BufWritePost" },
		},
		completion = {
			enabled = true,
		},
	},
	keymap = {
		-- NOTE: setup your own keymaps:
		hover = "H",
		definition = "gd",
		rename = "<leader>cr",
		references = "gr",
		format = "<leader>gf",
	},
	codeRunner = {
		enabled = true,
		default_method = "molten",
	},
})

local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
	runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })

vim.keymap.set("n", "<localleader>nc", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, { "```python", "", "```" })
	vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
	vim.cmd("startinsert")
end, { desc = "insert new code cell", silent = true })
