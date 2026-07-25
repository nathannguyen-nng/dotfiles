-- JupyterLab-style cell shortcuts for .ipynb (via jupytext.nvim, ft=markdown)
-- and .qmd (ft=quarto) buffers, so switching between nvim and Jupyter Lab
-- doesn't require relearning muscle memory. Leader-based rather than
-- Cmd/Alt/Shift+Enter: those can't be reliably distinguished by nvim when
-- running under tmux (Cmd specifically never can be, see <localleader>mr
-- below), so this sticks to plain <localleader> combos that work everywhere.
--
-- Cell boundaries are found the same way quarto's own code runner finds them
-- (fenced_code_block nodes from the markdown treesitter parser -- quarto's
-- filetype maps to the "markdown" parser too, see :lua
-- print(vim.treesitter.language.get_lang("quarto"))), then sent straight to
-- Molten with MoltenEvaluateRange, bypassing otter/quarto's own runner. That
-- runner requires quarto.activate() (otter), which only fires automatically
-- for ft=quarto, not for jupytext's ft=markdown ipynb buffers. Going straight
-- to Molten works uniformly for both and matches what quarto.lua's own
-- codeRunner.default_method already does for the same reason (see comment
-- there re: end_col dropping the cell's last line).

-- Returns every code cell in the buffer as 0-indexed {open, close} fence
-- line numbers (both inclusive), in document order.
local function get_cells(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return {}
	end
	local root = parser:parse()[1]:root()
	local query = vim.treesitter.query.parse(parser:lang(), "(fenced_code_block) @cell")
	local cells = {}
	for _, node in query:iter_captures(root, bufnr) do
		local open, _, close_exclusive = node:range()
		table.insert(cells, { open = open, close = close_exclusive - 1 })
	end
	table.sort(cells, function(a, b)
		return a.open < b.open
	end)
	return cells
end

local function cell_at_cursor(bufnr)
	local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
	for _, cell in ipairs(get_cells(bufnr)) do
		if cur >= cell.open and cur <= cell.close then
			return cell
		end
	end
	return nil
end

local function fence_lines(bufnr)
	if vim.bo[bufnr].filetype == "quarto" then
		return { "```{python}", "", "```" }
	end
	return { "```python", "", "```" }
end

local function run_cell(cell)
	if not cell or cell.close <= cell.open + 1 then
		return -- no cursor cell, or an empty cell with nothing to run
	end
	vim.fn.MoltenEvaluateRange(cell.open + 2, cell.close)
end

-- Insert a new empty cell above/below the cell at the cursor (or at the
-- cursor line if the cursor isn't inside a cell) and drop into insert mode
-- in its body, mirroring Jupyter's A/B + edit-mode behavior.
local function insert_cell(bufnr, direction)
	local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
	local cell = cell_at_cursor(bufnr)
	local row = direction == "above" and (cell and cell.open or cur) or (cell and cell.close + 1 or cur + 1)
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, fence_lines(bufnr))
	vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
	vim.cmd("startinsert")
end

local function goto_cell(bufnr, delta)
	local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
	local cells = get_cells(bufnr)
	-- Compare against the current cell's opening row, not the raw cursor
	-- row: with the cursor mid-body (not literally on the fence line),
	-- comparing against `cur` directly makes "previous cell" match the
	-- cell the cursor is already in instead of skipping past it.
	local current = cell_at_cursor(bufnr)
	local boundary = current and current.open or cur
	if delta > 0 then
		for _, cell in ipairs(cells) do
			if cell.open > boundary then
				vim.api.nvim_win_set_cursor(0, { cell.open + 2, 0 })
				return
			end
		end
	else
		for i = #cells, 1, -1 do
			if cells[i].open < boundary then
				vim.api.nvim_win_set_cursor(0, { cells[i].open + 2, 0 })
				return
			end
		end
	end
end

local function delete_cell(bufnr)
	local cell = cell_at_cursor(bufnr)
	if not cell then
		return
	end
	vim.api.nvim_buf_set_lines(bufnr, cell.open, cell.close + 1, false, {})
end

local function attach(bufnr)
	if vim.b[bufnr].notebook_cell_keys_attached then
		return
	end
	vim.b[bufnr].notebook_cell_keys_attached = true

	local function map(modes, lhs, rhs, desc)
		vim.keymap.set(modes, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end

	-- run cell in place, cursor/mode unchanged (like Jupyter's Ctrl+Enter).
	-- Not bound to Cmd/Alt/Shift+Enter: tmux's CSI-u parser hardcodes the
	-- kitty protocol's "super" bit straight into Meta (see tty-keys.c), so
	-- Cmd+Enter can never reach nvim as a distinguishable key through tmux --
	-- no config on the tmux/Ghostty side fixes this. Leader-based instead.
	-- Normal-mode only: <localleader> is space, so mapping it in insert mode
	-- would hijack every literal " mr"/" mf"/" mR" typed while editing.
	map("n", "<localleader>mr", function()
		run_cell(cell_at_cursor(bufnr))
	end, "run cell")

	-- run cell, then move to the next cell (create one if there isn't one)
	map("n", "<localleader>mf", function()
		local cell = cell_at_cursor(bufnr)
		run_cell(cell)
		if not cell then
			return
		end
		local cells = get_cells(bufnr)
		for _, c in ipairs(cells) do
			if c.open > cell.close then
				vim.api.nvim_win_set_cursor(0, { c.open + 2, 0 })
				return
			end
		end
		insert_cell(bufnr, "below")
	end, "run cell, move to next")

	-- run cell, insert a new cell below and enter it
	map("n", "<localleader>mR", function()
		run_cell(cell_at_cursor(bufnr))
		insert_cell(bufnr, "below")
	end, "run cell, insert below")

	map("n", "<localleader>mj", function()
		goto_cell(bufnr, 1)
	end, "next cell")
	map("n", "<localleader>mk", function()
		goto_cell(bufnr, -1)
	end, "previous cell")

	map("n", "<localleader>ma", function()
		insert_cell(bufnr, "above")
	end, "insert cell above")
	map("n", "<localleader>mb", function()
		insert_cell(bufnr, "below")
	end, "insert cell below")
	map("n", "<localleader>mdd", function()
		delete_cell(bufnr)
	end, "delete cell")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "quarto", "markdown" },
	callback = function(e)
		if e.match == "quarto" or vim.endswith(e.file, ".ipynb") then
			attach(e.buf)
		end
	end,
})
