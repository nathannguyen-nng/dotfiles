vim.pack.add({
	"https://github.com/folke/which-key.nvim",
})

local wk = require("which-key")
wk.setup({
	preset = "classic",
})
wk.add({
	{ "<leader><tab>", group = "tabs" },
	{ "<leader>c", group = "code" },
	{ "<leader>d", group = "debug" },
	{ "<leader>dp", group = "profiler" },
	{ "<leader>f", group = "file/find" },
	{ "<leader>g", group = "git" },
	{ "<leader>gh", group = "hunks" },
	{ "<leader>q", group = "quit/session" },
	{ "<leader>s", group = "search" },
	{ "<leader>t", group = "terminal" },
	{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
	{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
	{ "[", group = "prev" },
	{ "]", group = "next" },
	{ "g", group = "goto" },
	{ "gs", group = "surround" },
	{ "z", group = "fold" },
	{
		"<leader>b",
		group = "buffer",
		expand = function()
			return require("which-key.extras").expand.buf()
		end,
	},
	{
		"<leader>w",
		group = "windows",
		proxy = "<c-w>",
		expand = function()
			return require("which-key.extras").expand.win()
		end,
	},
	-- better descriptions
	{ "gx", desc = "Open with system app" },
	{
		"<leader>fC",
		group = "Copy Path",
		{
			"<leader>fCf",
			function()
				vim.fn.setreg("+", vim.fn.expand("%:p")) -- Copy full file path to clipboard
				vim.notify("Copied full file path: " .. vim.fn.expand("%:p"))
			end,
			desc = "Copy full file path",
		},
		{
			"<leader>fCn",
			function()
				vim.fn.setreg("+", vim.fn.expand("%:t")) -- Copy file name to clipboard
				vim.notify("Copied file name: " .. vim.fn.expand("%:t"))
			end,
			desc = "Copy file name",
		},
		{
			"<leader>fCr",
			function()
				local cwd = vim.fn.getcwd() -- Current working directory
				local full_path = vim.fn.expand("%:p") -- Full file path
				local rel_path = full_path:sub(#cwd + 2) -- Remove cwd prefix and leading slash
				vim.fn.setreg("+", rel_path) -- Copy relative file path to clipboard
				vim.notify("Copied relative file path: " .. rel_path)
			end,
			desc = "Copy relative file path",
		},
	},
	-- top-level singletons: concise labels + icons.
	-- Icons reuse which-key's own Material Design glyphs (these render in this Nerd Font);
	-- entries without an icon inherit a sensible one from which-key's keyword rules.
	{ "<leader>/", desc = "Grep", icon = { icon = "󰛔 ", color = "blue" } },
	{ "<leader><space>", desc = "Smart Find" },
	{ "<leader>:", desc = "Command History" },
	{ "<leader>,", desc = "Buffers", icon = { icon = "󰈔 ", color = "cyan" } },
	{ "<leader>.", desc = "Scratch", icon = { icon = "󱥰 ", color = "purple" } },
	{ "<leader>S", desc = "Scratch Select", icon = { icon = "󱥰 ", color = "purple" } },
	{ "<leader>;", desc = "Symbols" },
	{ "<leader>e", desc = "Explorer", icon = { icon = "󰓩 ", color = "orange" } },
	{ "<leader>n", desc = "Notifications", icon = { icon = "󰵅 ", color = "blue" } },
	{ "<leader>N", desc = "Neovim News", icon = { icon = "󰈸 ", color = "orange" } },
	{ "<leader>z", desc = "Zen", icon = { icon = "󱅻 ", color = "cyan" } },
	{ "<leader>Z", desc = "Zoom", icon = { icon = "󱅻 ", color = "cyan" } },
	{ "<leader>`", desc = "Other Buffer", icon = { icon = "󰈔 ", color = "cyan" } },
	{ "<leader>K", desc = "Keywordprg" },
	{
		"<leader>?",
		function()
			require("which-key").show({ global = false })
		end,
		desc = "Buffer Keymaps",
		icon = { icon = "󰙵 ", color = "blue" },
	},
	{
		"<c-w><space>",
		function()
			require("which-key").show({ keys = "<c-w>", loop = true })
		end,
		desc = "Window Hydra",
	},
	{
		mode = { "n", "v" }, -- NORMAL and VISUAL mode
		{ "<leader>W", "<cmd>w<cr>", desc = "Write", icon = { icon = "󰆓 ", color = "green" } },
	},
})
