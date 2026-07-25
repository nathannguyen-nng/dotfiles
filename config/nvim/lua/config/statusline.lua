local M = {}

local function apply_highlights()
	local ok, cp = pcall(require, "catppuccin.palettes")
	local p = ok and cp.get_palette() or {}

	local function hl(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	local bar_bg = "NONE"
	local bar_fg = p.subtext1
	local sep_fg = p.overlay0 -- dimmer color for | separators

	hl("StatusLine",   { bg = bar_bg, fg = bar_fg })
	hl("StatusLineNC", { bg = bar_bg, fg = p.overlay0 })

	-- Mode blocks (flat, no arrows)
	hl("StatusModeNormal",   { bg = p.blue,   fg = p.crust, bold = true })
	hl("StatusModeInsert",   { bg = p.green,  fg = p.crust, bold = true })
	hl("StatusModeVisual",   { bg = p.mauve,  fg = p.crust, bold = true })
	hl("StatusModeReplace",  { bg = p.red,    fg = p.crust, bold = true })
	hl("StatusModeCommand",  { bg = p.peach,  fg = p.crust, bold = true })
	hl("StatusModeTerminal", { bg = p.teal,   fg = p.crust, bold = true })

	-- Separator color (the | between right-side items)
	hl("StatusSep",  { bg = bar_bg, fg = sep_fg })

	-- Git
	hl("StatusGit",     { bg = bar_bg, fg = p.mauve, bold = true })
	hl("StatusDiffAdd", { bg = bar_bg, fg = p.green })
	hl("StatusDiffChange", { bg = bar_bg, fg = p.yellow })
	hl("StatusDiffDelete", { bg = bar_bg, fg = p.red })

	-- Filename
	hl("StatusFile", { bg = bar_bg, fg = p.text, bold = true })
	hl("StatusModified", { bg = bar_bg, fg = p.yellow })

	-- Diagnostics
	hl("StatusErrorIcon", { bg = bar_bg, fg = p.red,    bold = true })
	hl("StatusWarnIcon",  { bg = bar_bg, fg = p.yellow, bold = true })
	hl("StatusInfoIcon",  { bg = bar_bg, fg = p.blue })
	hl("StatusHintIcon",  { bg = bar_bg, fg = p.teal })

	-- Molten (jupyter kernel)
	hl("StatusMolten", { bg = bar_bg, fg = p.sapphire, bold = true })

	-- Right side items
	hl("StatusMeta",     { bg = bar_bg, fg = bar_fg })
	hl("StatusFiletype", { bg = bar_bg, fg = p.text })
	hl("StatusPercent",  { bg = p.blue, fg = p.crust, bold = true })
	hl("StatusLocation", { bg = bar_bg, fg = p.text, bold = true })

	-- Transparent backgrounds for floating/picker windows
	hl("SnacksPickerList",  { link = "Normal" })
	hl("SnacksPickerInput", { link = "Normal" })
	hl("SnacksPicker",      { link = "Normal" })
	hl("TinyCmdlineNormal", { link = "Normal" })
end

vim.schedule(apply_highlights)

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("StatuslineHL", { clear = true }),
	callback = function() vim.schedule(apply_highlights) end,
})

local fn = vim.fn

-- Nerd font icons via codepoint to avoid encoding issues in source files
local icons = {
	branch = vim.fn.nr2char(0xE0A0), --
	git    = vim.fn.nr2char(0xF1D3), --
	unix   = vim.fn.nr2char(0xE712), --
	dos    = vim.fn.nr2char(0xE70F), --
	mac    = vim.fn.nr2char(0xE711), --
	error  = vim.fn.nr2char(0xF659), --
	warn   = vim.fn.nr2char(0xF529), --
	info   = vim.fn.nr2char(0xF449), --
	hint   = vim.fn.nr2char(0xF835), --
	molten = vim.fn.nr2char(0xE606), --  (jupyter)
}

-- Diagnostics cache
local _diag_cache = {}
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function(args)
		local buf = args.buf
		local sev = vim.diagnostic.severity
		local counts = vim.diagnostic.count(buf)
		_diag_cache[buf] = {
			e = counts[sev.ERROR] or 0,
			w = counts[sev.WARN]  or 0,
			i = counts[sev.INFO]  or 0,
			h = counts[sev.HINT]  or 0,
		}
	end,
})

-- File icon cache
local _icon_cache = {}
vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
	callback = function(args) _icon_cache[args.buf] = nil end,
})

local function get_file_icon()
	local bufnr = vim.api.nvim_get_current_buf()
	if _icon_cache[bufnr] ~= nil then return _icon_cache[bufnr] end
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then _icon_cache[bufnr] = ""; return "" end
	local name = vim.api.nvim_buf_get_name(bufnr)
	local f = fn.fnamemodify(name, ":t")
	local e = fn.fnamemodify(name, ":e")
	local icon = devicons.get_icon(f, e, { default = true })
	local result = icon and (icon .. " ") or ""
	_icon_cache[bufnr] = result
	return result
end

local function get_git_branch()
	local branch = vim.b.gitsigns_head
	if not branch or branch == "" then return "" end
	local gs = vim.b.gitsigns_status_dict
	if gs and gs.root then
		return icons.branch .. " " .. fn.fnamemodify(gs.root, ":t") .. "/" .. branch
	end
	return icons.branch .. " " .. branch
end

local function build_git_diff()
	local gs = vim.b.gitsigns_status_dict or {}
	local parts = {}
	if (gs.added   or 0) > 0 then parts[#parts+1] = "%#StatusDiffAdd#+" .. gs.added end
	if (gs.changed or 0) > 0 then parts[#parts+1] = "%#StatusDiffChange#~" .. gs.changed end
	if (gs.removed or 0) > 0 then parts[#parts+1] = "%#StatusDiffDelete#-" .. gs.removed end
	if #parts == 0 then return "" end
	return " " .. table.concat(parts, " ") .. "%#StatusLine#"
end

local function get_diagnostics()
	local buf = vim.api.nvim_get_current_buf()
	local c = _diag_cache[buf] or {}
	local parts = {}
	if (c.e or 0) > 0 then parts[#parts+1] = "%#StatusErrorIcon#" .. icons.error .. " " .. c.e end
	if (c.w or 0) > 0 then parts[#parts+1] = "%#StatusWarnIcon#"  .. icons.warn  .. " " .. c.w end
	if (c.i or 0) > 0 then parts[#parts+1] = "%#StatusInfoIcon#"  .. icons.info  .. " " .. c.i end
	if (c.h or 0) > 0 then parts[#parts+1] = "%#StatusHintIcon#"  .. icons.hint  .. " " .. c.h end
	if #parts == 0 then return "" end
	return table.concat(parts, " ") .. "%#StatusLine#"
end

-- Filetypes molten-nvim is configured for (see plugins/molten.lua); .ipynb
-- buffers keep their `.ipynb` name even after jupytext converts the filetype,
-- so also match on the buffer name.
local molten_fts = { python = true, quarto = true, markdown = true }

local function is_molten_supported()
	if molten_fts[vim.bo.filetype] then return true end
	return vim.api.nvim_buf_get_name(0):match("%.ipynb$") ~= nil
end

local function get_molten_status()
	if not is_molten_supported() then return "" end
	local ok, status = pcall(require, "molten.status")
	if not ok then return "" end
	local ok2, init = pcall(status.initialized)
	if not ok2 or init ~= "Molten" then return "" end
	local ok3, kernels = pcall(status.kernels)
	if not ok3 or kernels == "" then return "" end
	return "%#StatusMolten#" .. icons.molten .. " " .. kernels .. "%#StatusLine#"
end

local mode_labels = {
	n       = "NORMAL",
	c       = "COMMAND",
	t       = "TERMINAL",
	i       = "INSERT",
	R       = "REPLACE",
	V       = "V-LINE",
	["\22"] = "V-BLOCK",
	r       = "R-PENDING",
	v       = "VISUAL",
}

local mode_hl = {
	n       = "StatusModeNormal",
	c       = "StatusModeCommand",
	t       = "StatusModeTerminal",
	i       = "StatusModeInsert",
	R       = "StatusModeReplace",
	V       = "StatusModeVisual",
	["\22"] = "StatusModeVisual",
	r       = "StatusModeReplace",
	v       = "StatusModeVisual",
}

local SEP = "%#StatusSep# | "

function M.build()
	local st = ""
	local m = fn.mode()

	-- A: mode (flat colored block, no arrows)
	local mhl = mode_hl[m] or "StatusModeNormal"
	st = st .. "%#" .. mhl .. "# " .. (mode_labels[m] or m) .. " %#StatusLine# "

	-- B: git branch + diff
	local br = get_git_branch()
	if br ~= "" then
		st = st .. "%#StatusGit# " .. br .. "%#StatusLine#"
		st = st .. build_git_diff()
		st = st .. " "
	end

	-- C: filename
	local fnm = fn.expand("%:.")
	if fnm ~= "" then
		st = st .. "%#StatusFile#" .. fnm
		if vim.bo.modified then
			st = st .. " %#StatusModified#●"
		end
		st = st .. "%#StatusLine# "
	end

	-- D: diagnostics
	local di = get_diagnostics()
	if di ~= "" then
		st = st .. di .. " "
	end

	-- E: molten kernel status (only in molten-supported files, when initialized)
	local mo = get_molten_status()
	if mo ~= "" then
		st = st .. mo .. " "
	end

	-- right align
	st = st .. "%="

	-- LSP progress
	local progress = vim.ui.progress_status and vim.ui.progress_status() or ""
	if progress ~= "" then
		st = st .. "%#StatusMeta#" .. progress .. SEP
	end

	-- encoding
	local enc = vim.bo.fileencoding
	if enc ~= "" then
		st = st .. "%#StatusMeta#" .. enc .. SEP
	end

	-- fileformat (icon)
	local fmt_icon = ({ unix = icons.unix, dos = icons.dos, mac = icons.mac })[vim.bo.fileformat]
		or vim.bo.fileformat
	st = st .. "%#StatusMeta#" .. fmt_icon .. SEP

	-- filetype with icon
	local ft = vim.bo.filetype
	if ft ~= "" then
		st = st .. "%#StatusFiletype#" .. get_file_icon() .. ft .. " "
	end

	-- percent
	st = st .. SEP .. "%#StatusPercent# %p%% "

	-- line:col
	st = st .. "%#StatusLocation# %l:%c "

	return st
end

vim.opt.laststatus = 3
vim.opt.showmode = false
vim.o.statusline = "%!v:lua.require('config.statusline').build()"

vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function() vim.schedule(vim.cmd.redrawstatus) end,
})

return M
