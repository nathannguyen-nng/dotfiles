-- Native LSP management commands (LspInfo/LspStart/LspStop/LspRestart/LspLog),
-- since this config uses vim.lsp.enable() instead of nvim-lspconfig.

local function client_names_complete()
	return vim.tbl_map(function(c)
		return c.name
	end, vim.lsp.get_clients())
end

vim.api.nvim_create_user_command("LspInfo", function()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.INFO)
		return
	end

	local lines = { string.format("%d active LSP client(s)", #clients) }
	for _, client in ipairs(clients) do
		local bufnames = {}
		for buf in pairs(client.attached_buffers) do
			table.insert(bufnames, vim.api.nvim_buf_get_name(buf))
		end

		table.insert(lines, "")
		table.insert(lines, string.format("%s (id: %d)", client.name, client.id))
		table.insert(lines, string.format("  root_dir: %s", client.root_dir or "-"))
		table.insert(lines, string.format("  offset_encoding: %s", client.offset_encoding or "-"))
		local cmd = client.config.cmd
		local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or type(cmd) == "function" and "<function>" or "-"
		table.insert(lines, string.format("  cmd: %s", cmd_str))
		table.insert(lines, string.format("  buffers: %s", #bufnames > 0 and table.concat(bufnames, ", ") or "-"))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LspInfo" })
end, { desc = "Show active LSP clients" })

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd("edit " .. vim.fn.fnameescape(vim.lsp.log.get_filename()))
end, { desc = "Open the LSP log file" })

vim.api.nvim_create_user_command("LspStop", function(opts)
	local names = opts.fargs
	local clients = #names == 0 and vim.lsp.get_clients()
		or vim.tbl_filter(function(c)
			return vim.tbl_contains(names, c.name)
		end, vim.lsp.get_clients())

	if #clients == 0 then
		vim.notify("No matching LSP clients", vim.log.levels.WARN)
		return
	end

	for _, client in ipairs(clients) do
		client:stop(true)
	end
	vim.notify("Stopped: " .. table.concat(vim.tbl_map(function(c)
		return c.name
	end, clients), ", "))
end, {
	desc = "Stop LSP client(s) by name (default: all)",
	nargs = "*",
	complete = client_names_complete,
})

vim.api.nvim_create_user_command("LspStart", function()
	-- Re-triggers the FileType/BufReadPost machinery that vim.lsp.enable()
	-- hooks into, so any server configured for this buffer's filetype (re)attaches.
	vim.cmd("edit")
end, { desc = "Re-trigger LSP attachment for the current buffer" })

vim.api.nvim_create_user_command("LspRestart", function(opts)
	local names = opts.fargs
	local clients = #names == 0 and vim.lsp.get_clients()
		or vim.tbl_filter(function(c)
			return vim.tbl_contains(names, c.name)
		end, vim.lsp.get_clients())

	if #clients == 0 then
		vim.notify("No matching LSP clients", vim.log.levels.WARN)
		return
	end

	local bufs = {}
	for _, client in ipairs(clients) do
		for buf in pairs(client.attached_buffers) do
			bufs[buf] = true
		end
		client:stop(true)
	end

	local function reattach()
		for buf in pairs(bufs) do
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("edit")
				end)
			end
		end
	end

	-- Give the client(s) a moment to fully shut down before re-triggering attach.
	local timer = vim.uv.new_timer()
	timer:start(200, 0, function()
		timer:stop()
		timer:close()
		vim.schedule(reattach)
	end)
end, {
	desc = "Restart LSP client(s) by name (default: all)",
	nargs = "*",
	complete = client_names_complete,
})
