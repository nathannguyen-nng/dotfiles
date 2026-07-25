---@brief
---
--- https://github.com/DetachHead/basedpyright
---
--- `basedpyright`, a pyright fork with stricter defaults and richer completion docs

local function set_python_path(path)
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
		name = "basedpyright",
	})
	for _, client in ipairs(clients) do
		if client.settings then
			client.settings.python = vim.tbl_deep_extend("force", client.settings.python, { pythonPath = path })
		else
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
		end
		client:notify("workspace/didChangeConfiguration", { settings = nil })
	end
end

return {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				-- Notebooks routinely leave a bare expression at the end of a cell to
				-- display its value; don't flag that as unused. See molten-nvim's
				-- Notebook-Setup.md docs.
				diagnosticSeverityOverrides = {
					reportUnusedExpression = "none",
				},
			},
		},
	},
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspBasedpyrightOrganizeImports", function()
			client:exec_cmd({
				command = "basedpyright.organizeimports",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, {
			desc = "Organize Imports",
		})
		vim.api.nvim_buf_create_user_command(bufnr, "LspBasedpyrightSetPythonPath", set_python_path, {
			desc = "Reconfigure basedpyright with the provided python path",
			nargs = 1,
			complete = "file",
		})
	end,
}
