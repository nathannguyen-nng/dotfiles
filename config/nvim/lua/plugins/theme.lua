vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } })

require("catppuccin").setup({
	flavour = "auto", -- latte, frappe, macchiato, mocha
	background = { -- :h background
		light = "latte",
		dark = "frappe",
	},
	transparent_background = true, -- disables setting the background color.
	float = {
		transparent = true, -- enable transparent floating windows
		solid = false, -- use solid styling for floating windows, see |winborder|
	},
	term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
	dim_inactive = {
		enabled = false, -- dims the background color of inactive window
		shade = "dark",
		percentage = 0.15, -- percentage of the shade to apply to the inactive window
	},
	no_italic = false, -- Force no italic
	no_bold = false, -- Force no bold
	no_underline = false, -- Force no underline
	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
		comments = { "italic" }, -- Change the style of comments
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
		-- miscs = {}, -- Uncomment to turn off hard-coded styles
	},
	lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
		virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
			ok = { "italic" },
		},
		underlines = {
			errors = { "underline" },
			hints = { "underline" },
			warnings = { "underline" },
			information = { "underline" },
			ok = { "underline" },
		},
		inlay_hints = {
			background = true,
		},
	},
	color_overrides = {},
	custom_highlights = function(p)
		return {
			-- blink.cmp: inherit NormalFloat so catppuccin's transparent float handling applies
			BlinkCmpMenu            = { link = "NormalFloat" },
			BlinkCmpMenuBorder      = { fg = p.surface2, bg = "NONE" },
			BlinkCmpMenuSelection   = { bg = p.surface1, bold = true },
			BlinkCmpScrollBarThumb  = { bg = p.surface1 },
			BlinkCmpScrollBarGutter = { link = "NormalFloat" },
			BlinkCmpLabel           = { fg = p.text },
			BlinkCmpLabelMatch      = { fg = p.blue, bold = true },
			BlinkCmpLabelDeprecated = { fg = p.overlay0, strikethrough = true },
			BlinkCmpKind            = { fg = p.blue },
			BlinkCmpDoc             = { link = "NormalFloat" },
			BlinkCmpDocBorder       = { fg = p.surface2, bg = "NONE" },
			BlinkCmpDocSeparator    = { fg = p.surface2, bg = "NONE" },
			BlinkCmpSignatureHelp   = { link = "NormalFloat" },
			BlinkCmpSignatureHelpBorder = { fg = p.surface2, bg = "NONE" },
		}
	end,
	default_integrations = true,
	auto_integrations = false,
})

-- setup must be called before loading
vim.cmd.colorscheme("catppuccin-nvim")

-- Re-apply colorscheme when the terminal signals a system theme change.
-- Catppuccin flavour="auto" reads vim.o.background, so reloading picks up the new flavor.
-- Debounced + value-guarded: tmux focus switches can spam OptionSet background without
-- actually changing the value (OSC 11 terminal queries), causing unnecessary reloads.
local _bg_last = vim.o.background
local _bg_timer = nil
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		local new_bg = vim.o.background
		if new_bg == _bg_last then
			return
		end
		_bg_last = new_bg
		if _bg_timer then
			_bg_timer:stop()
			_bg_timer:close()
		end
		_bg_timer = vim.defer_fn(function()
			_bg_timer = nil
			vim.cmd.colorscheme("catppuccin-nvim")
		end, 100)
	end,
})
