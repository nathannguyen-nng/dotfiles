vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
})

-- Lazy load on first insert mode entry or cmdline entry, whichever comes first
local group = vim.api.nvim_create_augroup("BlinkCmpLazyLoad", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
	pattern = "*",
	group = group,
	once = true,
	callback = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "none",
				-- Accept / confirm (like CLion Enter)
				["<CR>"] = { "accept", "fallback" },
				-- Tab: accept if selected, else jump snippet placeholder, else fallback
				["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				-- Arrow keys to navigate (CLion style)
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				-- Ctrl+Space: force trigger (CLion Ctrl+Space)
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				-- Escape: always hide the completion menu (if open) AND fall through
				-- to normal <Esc> (leave insert mode) in the same keypress. Plain
				-- "hide" returns true when it closes something, which would swallow
				-- the keypress and leave you stuck in insert mode.
				["<Esc>"] = {
					function(cmp)
						cmp.hide()
						return false
					end,
					"fallback",
				},
				-- Ctrl+e: cancel (secondary dismiss)
				["<C-e>"] = { "cancel" },
				-- Scroll docs
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				-- Toggle signature help (VS Code-style active parameter highlighting)
				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
				use_nvim_cmp_as_default = true,
			},
			completion = {
				documentation = {
					auto_show = true,
					-- Faster than the 500ms default, closer to VS Code's near-instant doc popup
					auto_show_delay_ms = 100,
				},
				list = {
					-- Auto-select first item like CLion
					selection = { preselect = true, auto_insert = false },
				},
			},
			signature = { enabled = true },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			cmdline = {
				completion = {
					menu = { auto_show = true },
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		})
	end,
})
