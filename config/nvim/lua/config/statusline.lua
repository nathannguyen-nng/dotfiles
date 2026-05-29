local M = {}

local function apply_highlights()
	local ok, cp = pcall(require, "catppuccin.palettes")
	local p = ok and cp.get_palette() or {}

	local function hl(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- surface0 has real contrast from base in both latte and frappe
	-- (mantle is too close to base in latte)
	local bar_bg = p.surface0
	local bar_fg = p.subtext1

	hl("StatusLine", { bg = bar_bg, fg = bar_fg })
	hl("StatusLineNC", { bg = bar_bg, fg = p.overlay0 })

	-- Per-mode highlight groups (bg changes per mode)
	hl("StatusModeNormal",   { bg = p.green,  fg = p.crust, bold = true })
	hl("StatusModeInsert",   { bg = p.blue,   fg = p.crust, bold = true })
	hl("StatusModeVisual",   { bg = p.mauve,  fg = p.crust, bold = true })
	hl("StatusModeReplace",  { bg = p.red,    fg = p.crust, bold = true })
	hl("StatusModeCommand",  { bg = p.peach,  fg = p.crust, bold = true })
	hl("StatusModeTerminal", { bg = p.teal,   fg = p.crust, bold = true })
	-- Transition arrows (fg = mode bg so powerline arrow blends)
	hl("StatusModeNormalSep",   { bg = bar_bg, fg = p.green  })
	hl("StatusModeInsertSep",   { bg = bar_bg, fg = p.blue   })
	hl("StatusModeVisualSep",   { bg = bar_bg, fg = p.mauve  })
	hl("StatusModeReplaceSep",  { bg = bar_bg, fg = p.red    })
	hl("StatusModeCommandSep",  { bg = bar_bg, fg = p.peach  })
	hl("StatusModeTerminalSep", { bg = bar_bg, fg = p.teal   })

	hl("StatusGit", { bg = p.surface1, fg = p.text, bold = true })
	hl("StatusGitToNorm", { bg = bar_bg, fg = p.mauve })
	hl("StatusDiffAdd", { bg = bar_bg, fg = p.green, bold = true })
	hl("StatusDiffChange", { bg = bar_bg, fg = p.yellow, bold = true })
	hl("StatusDiffDelete", { bg = bar_bg, fg = p.red, bold = true })

	hl("StatusFile", { bg = bar_bg, fg = p.text, bold = true })
	hl("StatusFileToNorm", { bg = bar_bg, fg = bar_fg })

	hl("StatusLSP", { bg = bar_bg, fg = p.text, bold = true })
	hl("StatusLSPToNorm", { bg = bar_bg, fg = bar_fg })

	hl("StatusErrorIcon", { bg = bar_bg, fg = p.red, bold = true })
	hl("StatusWarnIcon", { bg = bar_bg, fg = p.yellow, bold = true })
	hl("StatusInfoIcon", { bg = bar_bg, fg = p.blue })
	hl("StatusHintIcon", { bg = bar_bg, fg = p.teal })

	hl("StatusBuffer", { bg = p.surface1, fg = p.text })
	hl("StatusType", { bg = p.surface1, fg = p.text })
	hl("StatusNorm", { bg = bar_bg, fg = bar_fg })
	hl("StatusLocation", { bg = p.surface2, fg = p.text })
	hl("StatusPercent", { bg = p.teal, fg = p.crust, bold = true })

	-- Transparent backgrounds for floating/picker windows
	hl("SnacksPickerList",    { link = "Normal" })
	hl("SnacksPickerInput",   { link = "Normal" })
	hl("SnacksPicker",        { link = "Normal" })
	hl("TinyCmdlineNormal",   { link = "Normal" })
end

-- Defer so catppuccin is loaded before first apply
vim.schedule(apply_highlights)

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("StatuslineHL", { clear = true }),
	callback = function() vim.schedule(apply_highlights) end,
})

local fn = vim.fn

local _diag_cache = {} -- [bufnr] -> { e=n, w=n, i=n, h=n }

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function(args)
		local buf = args.buf
		local sev = vim.diagnostic.severity
		local counts = vim.diagnostic.count(buf)
		_diag_cache[buf] = {
			e = counts[sev.ERROR] or 0,
			w = counts[sev.WARN] or 0,
			i = counts[sev.INFO] or 0,
			h = counts[sev.HINT] or 0,
		}
	end,
})

local _wc_state = { words = 0, timer = nil }

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
	callback = function()
		local ft = vim.bo.filetype
		if not (ft:match("md") or ft:match("markdown") or ft == "text") then
			return
		end
		if _wc_state.timer then
			_wc_state.timer:stop()
			_wc_state.timer:close()
		end
		_wc_state.timer = vim.defer_fn(function()
			_wc_state.timer = nil
			_wc_state.words = fn.wordcount().words or 0
		end, 500)
	end,
})

local _icon_cache = {} -- [bufnr] -> icon string

vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
	callback = function(args)
		_icon_cache[args.buf] = nil
	end,
})

-- Git repo/branch with caching - uses gitsigns buffer variables for performance
local function get_git_branch()
	local branch = vim.b.gitsigns_head
	if not branch or branch == "" then
		return ""
	end

	-- Get repo name from gitsigns status dict if available
	local gs = vim.b.gitsigns_status_dict
	if gs and gs.root then
		-- Extract repo name from the root path
		local repo_name = vim.fn.fnamemodify(gs.root, ":t")
		return repo_name .. "/" .. branch
	end

	return branch
end

local function build_git_diff()
	local gs = vim.b.gitsigns_status_dict or {}
	local added = gs.added or 0
	local changed = gs.changed or 0
	local removed = gs.removed or 0

	local diff_str = ""
	if added > 0 then
		diff_str = diff_str .. "%#StatusDiffAdd# " .. added .. " "
	end
	if changed > 0 then
		diff_str = diff_str .. "%#StatusDiffChange# " .. changed .. " "
	end
	if removed > 0 then
		diff_str = diff_str .. "%#StatusDiffDelete# " .. removed .. " "
	end

	-- reset to StatusLine for everything that follows
	return diff_str .. "%#StatusLine#"
end

-- Diagnostics symbols
local function get_diagnostics()
	local buf = vim.api.nvim_get_current_buf()
	local c = _diag_cache[buf] or {}
	local s = ""
	if (c.e or 0) > 0 then
		s = s .. "%#StatusErrorIcon# " .. c.e .. " "
	end
	if (c.w or 0) > 0 then
		s = s .. "%#StatusWarnIcon# " .. c.w .. " "
	end
	if (c.i or 0) > 0 then
		s = s .. "%#StatusInfoIcon# " .. c.i .. " "
	end
	if (c.h or 0) > 0 then
		s = s .. "%#StatusHintIcon# " .. c.h .. " "
	end

	-- reset to StatusLine for following text
	return s .. "%#StatusLine#"
end

-- File icon
local function get_file_icon()
	local bufnr = vim.api.nvim_get_current_buf()
	if _icon_cache[bufnr] ~= nil then
		return _icon_cache[bufnr]
	end

	local ok, icons = pcall(require, "nvim-web-devicons")
	if not ok then
		_icon_cache[bufnr] = ""
		return ""
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	local f = fn.fnamemodify(name, ":t")
	local e = fn.fnamemodify(name, ":e")
	local icon = icons.get_icon(f, e, { default = true })
	local result = icon and icon .. " " or ""
	_icon_cache[bufnr] = result
	return result
end

-- Word count & reading time
local function word_reading()
	local ft = vim.bo.filetype
	if ft:match("md") or ft:match("markdown") or ft == "text" then
		local w = _wc_state.words
		if w == 0 then
			return ""
		end
		return w .. "w " .. " " .. math.ceil(w / 200) .. "m"
	end
	return ""
end

-- Mode icons
local mode_labels = {
	n      = " NORMAL",
	c      = " COMMAND",
	t      = " TERMINAL",
	i      = " INSERT",
	R      = " REPLACE",
	V      = " V-LINE",
	["\22"] = " V-BLOCK",
	r      = " R-PENDING",
	v      = " VISUAL",
}

local mode_hl = {
	n      = "StatusModeNormal",
	c      = "StatusModeCommand",
	t      = "StatusModeTerminal",
	i      = "StatusModeInsert",
	R      = "StatusModeReplace",
	V      = "StatusModeVisual",
	["\22"] = "StatusModeVisual",
	r      = "StatusModeReplace",
	v      = "StatusModeVisual",
}

local mode_sep_hl = {
	n      = "StatusModeNormalSep",
	c      = "StatusModeCommandSep",
	t      = "StatusModeTerminalSep",
	i      = "StatusModeInsertSep",
	R      = "StatusModeReplaceSep",
	V      = "StatusModeVisualSep",
	["\22"] = "StatusModeVisualSep",
	r      = "StatusModeReplaceSep",
	v      = "StatusModeVisualSep",
}

-- 4) Build statusline
function M.build()
	local st = ""

	-- A: mode
	local m = fn.mode()
	local mhl  = mode_hl[m]     or "StatusModeNormal"
	local msep = mode_sep_hl[m] or "StatusModeNormalSep"
	st = st .. "%#" .. mhl .. "# " .. (mode_labels[m] or m) .. " %#" .. msep .. "#"

	-- B: git
	local br = get_git_branch()
	if br ~= "" then
		st = st .. "%#StatusGit# " .. " " .. br .. " " .. "%#StatusGitToNorm#"

		local git_diff = build_git_diff()
		if git_diff ~= "" then
			st = st .. git_diff .. "%#StatusGitToNorm#"
		end
	end

	-- C: filename
	-- local fnm = fn.expand("%:t")
	local fnm = fn.expand("%:.")
	if fnm ~= "" then
		st = st .. "%#StatusFile# " .. fnm .. " " .. (vim.bo.modified and " " or "") .. "%#StatusFileToNorm#"
	end

	local di = get_diagnostics()
	if di ~= "" then
		st = st .. "%#StatusLSP# " .. di .. " " .. "%#StatusLSPToNorm#"
	end

	-- right align
	st = st .. "%="

	-- LSP progress (e.g. "indexing…" from language servers)
	local progress = vim.ui.progress_status and vim.ui.progress_status() or ""
	if progress ~= "" then
		st = st .. "%#StatusLSP# " .. progress .. " %#StatusLine#"
	end

	-- X: filetype
	local ft = vim.bo.filetype
	if ft ~= "" then
		st = st .. "%#StatusType# " .. get_file_icon() .. ft .. "%#StatusTypeToNorm#"
	end

	-- Y: word/reading
	local wr = word_reading()
	if wr ~= "" then
		st = st .. "%#StatusBuffer# " .. " " .. wr
	end

	-- Z: encoding, format, location, percent
	st = st
		.. "%#StatusBuffer# "
		.. vim.bo.fileencoding
		.. " "
		.. vim.bo.fileformat
		.. " "
		.. "%#StatusLocation# %l:%c "
		.. "%#StatusPercent# %p%% "

	return st
end

vim.opt.laststatus = 3 -- global statusline
vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.o.statusline = "%!v:lua.require('config.statusline').build()"

-- Force immediate redraw on every mode transition so the indicator
-- updates without waiting for cursor movement (e.g. V-LINE on first keypress).
vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function() vim.cmd.redrawstatus() end,
})

return M

