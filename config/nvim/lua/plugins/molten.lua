vim.pack.add({
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/benlubas/molten-nvim", version = "v1.9.2" }, -- pin to latest 1.x tag
})

vim.g.molten_image_provider = "image.nvim"
vim.g.molten_output_win_max_height = 100

-- Default is "open_then_enter": the first <localleader>os press only opens the
-- output window, the cursor stays in the code cell. Scrolling then moves the
-- cursor in the cell instead, which walks it out of the cell's range and molten
-- hides the window. Enter (focus) the floating window on the first press instead,
-- so j/k/<C-d>/<C-u> etc scroll it directly; leave with <C-w>w or :q.
vim.g.molten_enter_output_behavior = "open_and_enter"

-- The output window is a regular buffer/window, not a special popup, so `q`
-- doesn't close it by default -- only `:q` or :MoltenHideOutput do. Wire it
-- up too once focused inside it.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "molten_output",
	callback = function(e)
		vim.keymap.set(
			"n",
			"q",
			":MoltenHideOutput<CR>",
			{ buffer = e.buf, silent = true, desc = "close output window" }
		)
	end,
})

-- molten-nvim's bundled comment-stripping helper (used by :MoltenExportOutput to compare
-- cell contents) can hit a treesitter `#offset!` match whose metadata has no `.range` on
-- current Neovim, crashing the export (and, via jupytext.nvim, any save of the linked .md).
-- Patch it to fall back to the untouched text instead of throwing.
do
	local ok, remove_comments = pcall(require, "remove_comments")
	if ok then
		local original = remove_comments.remove_comments
		remove_comments.remove_comments = function(str, lang)
			local call_ok, result = pcall(original, str, lang)
			if call_ok then
				return result
			end
			return str
		end
	end
end

-- I find auto open annoying, keep in mind setting this option will require setting
-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
vim.g.molten_auto_open_output = false

-- optional, I like wrapping. works for virt text and the output window
vim.g.molten_wrap_output = true

-- Output as virtual text. Allows outputs to always be shown, works with images, but can
-- be buggy with longer images
vim.g.molten_virt_text_output = true

-- this will make it so the output shows up below the \`\`\` cell delimiter
vim.g.molten_virt_lines_off_by_1 = true

require("image").setup({
	backend = "kitty",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = true,
		},
	},
	-- molten-nvim sizes its floating output window from image.nvim's *absolute* max_width/
	-- max_height (in terminal cells), NOT the percentage options below -- its image_size()
	-- helper says so explicitly. Without these set, molten sizes the window to the image's
	-- true (uncapped) dimensions, then clamps the window to whatever screen space is left,
	-- so image.nvim ends up cropping the image to fit instead of scaling it down. Setting
	-- these lets molten pick a window size the image can actually render into untouched.
	max_width = 100,
	max_height = 40,
	max_height_window_percentage = 95,
	max_width_window_percentage = 95,
	window_overlap_clear_enabled = true,
	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
	tmux_show_only_in_active_window = true,
})

-- Auto-init a kernel: try the notebook's own kernelspec metadata first, then
-- fall back to whatever venv/conda env is active. Returns true if a kernel
-- was found and MoltenInit was called (so the caller can decide what to do
-- if not, e.g. prompt the user).
local function molten_auto_init(e)
	local kernels = vim.fn.MoltenAvailableKernels()
	local try_kernel_name = function()
		local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
		return metadata.kernelspec.name
	end
	local ok, kernel_name = pcall(try_kernel_name)
	if not ok or not vim.tbl_contains(kernels, kernel_name) then
		kernel_name = nil
		local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
		if venv ~= nil then
			kernel_name = string.match(venv, "/.+/(.+)")
		end
	end
	if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
		vim.cmd(("MoltenInit %s"):format(kernel_name))
		return true
	end
	return false
end

-- Auto-init a kernel and import existing outputs when opening a .ipynb,
-- and export outputs back into the notebook on save.
local function molten_import(e)
	vim.schedule(function()
		molten_auto_init(e)
		vim.cmd("MoltenImportOutput")
	end)
end

vim.api.nvim_create_autocmd("BufAdd", {
	pattern = { "*.ipynb" },
	callback = molten_import,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.ipynb" },
	callback = function(e)
		if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
			molten_import(e)
		end
	end,
})

-- Same kernel auto-detection for .qmd, minus the .ipynb-specific output
-- import/export (there's no embedded output JSON to import from). No
-- kernelspec metadata to read either, so this only tries the active venv/
-- conda env; if that fails to match a kernel, Molten's own MoltenInit prompt
-- (triggered manually, e.g. via keymap) will ask you to pick one.
-- Plain .md is excluded: most .md files aren't notebook-linked, so we don't
-- want every markdown file to prompt for a kernel.
local function molten_auto_init_plaintext(e)
	vim.schedule(function()
		local kernels = vim.fn.MoltenAvailableKernels()
		local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
		local kernel_name = venv ~= nil and string.match(venv, "/.+/(.+)") or nil
		if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
			vim.cmd(("MoltenInit %s"):format(kernel_name))
		else
			-- no confident match: fall back to Molten's own kernel-picker
			-- prompt (same one `:MoltenInit` with no args shows you)
			vim.cmd("MoltenInit")
		end
	end)
end

vim.api.nvim_create_autocmd("BufAdd", {
	pattern = { "*.qmd" },
	callback = molten_auto_init_plaintext,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.qmd" },
	callback = function(e)
		if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
			molten_auto_init_plaintext(e)
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.ipynb" },
	callback = function()
		if require("molten.status").initialized() == "Molten" then
			vim.cmd("MoltenExportOutput!")
		end
	end,
})

-- Plain .py files get compact output (no extra virt lines/text); notebook-ish
-- filetypes get the roomier virt text output configured above.
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.py",
	callback = function(e)
		if string.match(e.file, ".otter.") then
			return
		end
		if require("molten.status").initialized() == "Molten" then
			vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
			vim.fn.MoltenUpdateOption("virt_text_output", false)
		else
			vim.g.molten_virt_lines_off_by_1 = false
			vim.g.molten_virt_text_output = false
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.qmd", "*.md", "*.ipynb" },
	callback = function(e)
		if string.match(e.file, ".otter.") then
			return
		end
		if require("molten.status").initialized() == "Molten" then
			vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
			vim.fn.MoltenUpdateOption("virt_text_output", true)
		else
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_virt_text_output = true
		end
	end,
})

-- `basedpyright` (our python LSP, see lsp/basedpyright.lua) doesn't know which
-- interpreter/env a given Molten kernel is using, so on every kernel attach we push
-- the kernel's python executable into the attached basedpyright client(s) via
-- workspace/didChangeConfiguration -- same mechanism as :LspBasedpyrightSetPythonPath,
-- just triggered automatically instead of by hand. basedpyright picks this up live,
-- no restart needed.
local function sync_basedpyright_to_molten_kernel()
	local ok, kernel_ids = pcall(vim.fn.MoltenRunningKernels, { true })
	if not ok or not kernel_ids or #kernel_ids == 0 then
		return
	end
	-- kernel_id is kernel_name, or kernel_name_N if multiple instances of the same kernel
	-- are running; strip the suffix to get back the underlying jupyter kernel name.
	local kernel_name = kernel_ids[1]:gsub("_%d+$", "")
	local kernel_json = vim.fn.expand("~/Library/Jupyter/kernels/" .. kernel_name .. "/kernel.json")
	local f = io.open(kernel_json, "r")
	if not f then
		return
	end
	local ok2, spec = pcall(vim.json.decode, f:read("a"))
	f:close()
	if not ok2 or not spec.argv or not spec.argv[1] then
		return
	end
	-- python_path looks like <env>/bin/python3
	local python_path = spec.argv[1]

	if vim.b.molten_basedpyright_venv == python_path then
		return -- this buffer is already synced to this kernel's env
	end
	vim.b.molten_basedpyright_venv = python_path

	local bufnr = vim.api.nvim_get_current_buf()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })) do
		if client.settings then
			client.settings.python =
				vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = python_path })
		else
			client.config.settings =
				vim.tbl_deep_extend("force", client.config.settings or {}, { python = { pythonPath = python_path } })
		end
		client:notify("workspace/didChangeConfiguration", { settings = nil })
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MoltenInitPost",
	callback = function()
		vim.schedule(sync_basedpyright_to_molten_kernel)
	end,
})

-- :NewNotebook <name> creates and opens <name>.ipynb with a minimal Python 3 kernel spec
local default_notebook = [[
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
     ""
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
     "name": "ipython"
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
]]

vim.api.nvim_create_user_command("NewNotebook", function(opts)
	local path = opts.args .. ".ipynb"
	local file = io.open(path, "w")
	if file then
		file:write(default_notebook)
		file:close()
		vim.cmd("edit " .. path)
	else
		vim.notify("Could not open new notebook file for writing", vim.log.levels.ERROR)
	end
end, {
	nargs = 1,
	complete = "file",
})
