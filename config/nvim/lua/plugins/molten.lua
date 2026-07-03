vim.pack.add({
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/benlubas/molten-nvim", version = "v1.9.2" }, -- pin to latest 1.x tag
})

vim.g.molten_image_provider = "image.nvim"
vim.g.molten_output_win_max_height = 30

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
	max_width = 100,
	max_height = 30,
	max_height_window_percentage = math.huge,
	max_width_window_percentage = math.huge,
	window_overlap_clear_enabled = true,
	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
})

-- Auto-init a kernel and import existing outputs when opening a .ipynb,
-- and export outputs back into the notebook on save.
local function molten_import(e)
	vim.schedule(function()
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
		end
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

-- `ty` (our python LSP, see lsp/ty.lua) only auto-discovers real virtualenvs (it looks
-- for VIRTUAL_ENV + a pyvenv.cfg); conda envs don't have pyvenv.cfg so it silently falls
-- back to scanning system Pythons. ty *does* support pointing explicitly at a non-venv
-- (e.g. conda) environment via `environment.python` in a project-local ty.toml, so we
-- write that file to match Molten's active kernel and restart the ty client to pick it up.
local ty_root_markers = { "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }
local molten_managed_marker = "# molten-managed: kernel env synced from MoltenInit"

local function write_ty_env_config(root, venv_dir)
	local path = root .. "/ty.toml"
	if vim.fn.filereadable(path) == 1 then
		local existing = io.open(path, "r")
		local contents = existing:read("a")
		existing:close()
		if not contents:find(molten_managed_marker, 1, true) then
			return false -- user-authored ty.toml; don't clobber it
		end
	end
	local f = io.open(path, "w")
	if not f then
		return false
	end
	f:write(molten_managed_marker .. "\n[environment]\npython = " .. string.format("%q", venv_dir) .. "\n")
	f:close()
	return true
end

local function sync_ty_to_molten_kernel()
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
	local venv_dir = spec.argv[1]:match("(.+)/bin/[^/]+$")
	if not venv_dir then
		return
	end

	-- ty falls back to the file's own directory as a single-file root when no
	-- marker is found upward (e.g. scratch notebooks outside any git repo);
	-- match that behavior so we write ty.toml where ty will actually look for it.
	local root = vim.fs.root(0, ty_root_markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not root then
		return
	end

	if vim.b.molten_ty_venv == venv_dir then
		return -- this buffer's root is already synced to this kernel's env
	end

	if not write_ty_env_config(root, venv_dir) then
		vim.notify(
			"ty.toml already exists at " .. root .. " and isn't molten-managed; skipping kernel sync",
			vim.log.levels.WARN
		)
		return
	end
	vim.b.molten_ty_venv = venv_dir

	for _, client in ipairs(vim.lsp.get_clients({ name = "ty" })) do
		local bufs = vim.tbl_keys(client.attached_buffers)
		local restart_bufs = vim.tbl_filter(function(buf)
			local buf_root = vim.fs.root(buf, ty_root_markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
			return buf_root == root
		end, bufs)
		if #restart_bufs > 0 then
			client:stop()
			vim.schedule(function()
				for _, buf in ipairs(restart_bufs) do
					if vim.api.nvim_buf_is_valid(buf) then
						vim.lsp.start(vim.lsp.config.ty, { bufnr = buf })
					end
				end
			end)
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MoltenInitPost",
	callback = function()
		vim.schedule(sync_ty_to_molten_kernel)
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
