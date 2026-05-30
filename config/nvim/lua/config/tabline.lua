local M = {}

local SEP = "" -- separator glyph at buffer boundary
local CLOSE = "" -- close icon shown on active buffer
local NO_NAME = "[NO NAME]"

local _tab_cache = nil -- cached rendered string
local _tab_cache_buf = nil -- bufnr when cache was built

local _tab_invalidate_events = {
	"BufAdd",
	"BufDelete",
	"BufWipeout",
	"BufFilePost",    -- buffer renamed
	"BufModifiedSet", -- modified flag changed (shows/hides the indicator)
	"BufEnter",       -- recompute disambiguated names when switching
}

vim.api.nvim_create_autocmd(_tab_invalidate_events, {
	group = vim.api.nvim_create_augroup("MyTablineCache", { clear = true }),
	callback = function()
		_tab_cache = nil
	end,
})

function M.set_highlights()
	local ok, cp = pcall(require, "catppuccin.palettes")
	local p = ok and cp.get_palette() or {}
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "MyBufInactive", { fg = p.subtext0 or "#ABB2BF", bg = "NONE" })
	local active_bg = p.surface1 or "#3E4451"
	vim.api.nvim_set_hl(0, "MyBufActive", { fg = p.text or "#ECEFF4", bg = active_bg, bold = true })
	vim.api.nvim_set_hl(0, "MyBufSeparator", { fg = p.mantle or "#21252B", bg = "NONE" })
	vim.api.nvim_set_hl(0, "MyBufClose", { fg = p.red or "#BF616A", bg = active_bg })
end

-- Safe devicons resolve (cached per render)
local function get_icon(filename, name)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok or not name or name == "" then
		return ""
	end
	local ext = vim.fn.fnamemodify(name, ":e")
	local icon = devicons.get_icon(filename, ext, { default = true })
	return icon and (icon .. " ") or ""
end

-- Build a display name for each listed buffer, showing only enough path to disambiguate.
-- Files with unique names show just the filename; duplicates get parent folders added
-- one level at a time until they differ.
local function build_display_names()
	local bufs = vim.tbl_filter(function(b)
		return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())

	-- Collect full paths and split into parts
	local info = {} -- [bufnr] = { path, parts }
	for _, b in ipairs(bufs) do
		local path = vim.api.nvim_buf_get_name(b)
		local parts = vim.split(path ~= "" and path or NO_NAME, "/", { plain = true })
		info[b] = { path = path, parts = parts }
	end

	-- For each buffer, find the minimum suffix (from the right) that makes it unique
	local names = {} -- [bufnr] = display string
	for _, b in ipairs(bufs) do
		local my_parts = info[b].parts
		local depth = 1 -- start with just filename
		while depth <= #my_parts do
			local candidate = table.concat(my_parts, "/", #my_parts - depth + 1)
			local clash = false
			for _, other in ipairs(bufs) do
				if other ~= b then
					local op = info[other].parts
					local other_candidate = table.concat(op, "/", #op - depth + 1)
					if candidate == other_candidate then
						clash = true
						break
					end
				end
			end
			if not clash then
				names[b] = candidate
				break
			end
			depth = depth + 1
		end
		if not names[b] then
			names[b] = table.concat(my_parts, "/", math.max(1, #my_parts - 2))
		end
	end
	return names
end

-- Click handlers (minwid = bufnr)
function _G.tabline_buf_click(bufnr, clicks, button)
	if button == "l" then
		vim.api.nvim_set_current_buf(bufnr)
	elseif button == "m" then
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
	end
end

function _G.tabline_close_click(bufnr, clicks, button)
	if button == "l" then
		-- If closing the current buffer, switch to an adjacent one first
		if vim.api.nvim_get_current_buf() == bufnr then
			local listed = vim.tbl_filter(function(b)
				return b ~= bufnr and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
			end, vim.api.nvim_list_bufs())
			if #listed > 0 then
				-- prefer the next buffer, fall back to previous
				local next_buf = nil
				for _, b in ipairs(listed) do
					if b > bufnr then next_buf = b; break end
				end
				vim.api.nvim_set_current_buf(next_buf or listed[#listed])
			else
				-- no other listed buffers — force-create a new one (enew reuses the
				-- same unmodified buffer, so we'd delete what we just switched to)
				local new_buf = vim.api.nvim_create_buf(true, false)
				vim.api.nvim_set_current_buf(new_buf)
			end
		end
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
	end
end

-- Render a single buffer chunk
local function render_buf(bufnr, current, display_names)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return ""
	end
	if not vim.bo[bufnr].buflisted then
		return ""
	end

	local name = vim.api.nvim_buf_get_name(bufnr)
	local display_name = display_names[bufnr] or vim.fn.fnamemodify(name, ":t") or NO_NAME
	local filename = (name ~= "" and vim.fn.fnamemodify(name, ":t")) or NO_NAME
	local icon = get_icon(filename, name)
	local content = icon .. display_name

	if bufnr == current then
		return table.concat({
			"%" .. bufnr .. "@v:lua.tabline_buf_click@",
			"%#MyBufActive# ",
			content,
			" %X",
			"%" .. bufnr .. "@v:lua.tabline_close_click@",
			"%#MyBufClose# ",
			CLOSE,
			" %X",
			"%#MyBufSeparator#",
			SEP,
		})
	else
		return table.concat({
			"%" .. bufnr .. "@v:lua.tabline_buf_click@",
			"%#MyBufInactive# ",
			content,
			"  %X",
			"%#MyBufSeparator#",
			SEP,
		})
	end
end

function _G.tabline()
	local current = vim.api.nvim_get_current_buf()

	-- Return cached string if the buffer list and active buffer haven't changed
	if _tab_cache and _tab_cache_buf == current then
		return _tab_cache
	end

	local display_names = build_display_names()
	local parts = {}
	-- Iterate listed buffers in ascending handle order for stability
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local chunk = render_buf(bufnr, current, display_names)
		if chunk ~= "" then
			table.insert(parts, chunk)
		end
	end

	if #parts == 0 then
		_tab_cache = ""
		_tab_cache_buf = current
		return ""
	end

	local line = table.concat(parts)
	-- Trim trailing separator if present
	local result = line:gsub(vim.pesc(SEP) .. "$", "")
	_tab_cache = result
	_tab_cache_buf = current
	return result
end

function M.setup()
	vim.schedule(M.set_highlights) -- defer so catppuccin is loaded first

	vim.api.nvim_create_augroup("MyTabline", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = "MyTabline",
		callback = function() vim.schedule(M.set_highlights) end,
	})

	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua.tabline()"
end

-- Close all buffers to the left/right of the current one
vim.keymap.set("n", "<leader>bl", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and buf < cur then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end, { desc = "Close all left buffers" })

vim.keymap.set("n", "<leader>br", function()
	local cur = vim.api.nvim_get_current_buf()
	local bufs = vim.api.nvim_list_bufs()
	for i = #bufs, 1, -1 do
		local buf = bufs[i]
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and buf > cur then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end, { desc = "Close all right buffers" })

M.setup()

return M

