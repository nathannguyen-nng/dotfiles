local function find_config(root)
	local home = vim.fn.expand("~")
	-- Project-local config
	if root and root ~= "" then
		for _, name in ipairs({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }) do
			local p = vim.fs.joinpath(root, name)
			if vim.fn.filereadable(p) == 1 then
				return p
			end
		end
	end
	-- Global fallback
	for _, name in ipairs({ ".oxfmtrc.jsonc", ".oxfmtrc.json" }) do
		local p = vim.fs.joinpath(home, name)
		if vim.fn.filereadable(p) == 1 then
			return p
		end
	end
	return nil
end

return {
	cmd = function(dispatchers, config)
		local root = config.root_dir or vim.uv.cwd()
		local cmd = "oxfmt"

		-- Use local binary if available
		local local_cmd = vim.fs.joinpath(root, "node_modules/.bin", "oxfmt")
		if vim.fn.executable(local_cmd) == 1 then
			cmd = local_cmd
		end

		local args = { cmd, "--lsp" }
		local cfg = find_config(root)

		if cfg then
			table.insert(args, "--config")
			table.insert(args, cfg)
		end

		return vim.lsp.rpc.start(args, dispatchers)
	end,
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"toml",
		"json",
		"jsonc",
		"json5",
		"yaml",
		"html",
		"vue",
		"handlebars",
		"css",
		"scss",
		"less",
		"graphql",
		"markdown",
	},
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		if fname == "" then
			on_dir(nil)
			return
		end

		-- Detect project root
		local root = vim.fs.root(fname, {
			".oxfmtrc.json",
			".oxfmtrc.jsonc",
			"oxfmt.config.ts",
			"package.json",
			".git",
		})

		-- Always provide a root_dir to ensure the LSP starts even without project markers
		on_dir(root or vim.fs.dirname(fname))
	end,
}

