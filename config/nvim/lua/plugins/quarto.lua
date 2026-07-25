vim.pack.add({
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
})

-- otter's completionItem/resolve handler unconditionally does
-- `ctx.params.data.uri = ...`, assuming a completion item's `data` field is always
-- a table. Per the LSP spec `data` can be any JSON value; pyrefly sends a plain
-- string there, and assigning a field on a string value raises a hard Lua error
-- (unlike reads, which silently return nil via the string metatable). Guard it.
do
	local ok, handlers = pcall(require, "otter.lsp.handlers")
	if ok then
		local ms = vim.lsp.protocol.Methods
		local original = handlers[ms.completionItem_resolve]
		handlers[ms.completionItem_resolve] = function(err, response, ctx)
			if type(ctx.params.data) ~= "table" then
				ctx.params.data = nil
			end
			return original(err, response, ctx)
		end
	end
end

-- otter's textDocument/completion handler rewrites every completion item's
-- `data.uri` from the otter shadow buffer's uri to the main buffer's uri (so
-- other consumers can treat `data.uri` as "the real file"). But blink caches
-- that same item and later sends it back verbatim for completionItem/resolve,
-- so basedpyright (and pyright) receive a resolve request whose `data.uri`
-- points at the .qmd/.md file instead of the shadow .otter.py document they
-- actually have open -- they can't find the symbol there, so resolve silently
-- returns no `documentation`/`detail` and blink's doc popup never shows
-- anything. Restore `data.uri` to the shadow buffer's uri after otter's own
-- handler runs so the later resolve request round-trips correctly; the
-- response-side completionItem/resolve handler above already rewrites the
-- uri back to the main buffer once resolution has actually happened.
do
	local ok, handlers = pcall(require, "otter.lsp.handlers")
	if ok then
		local ms = vim.lsp.protocol.Methods
		local original = handlers[ms.textDocument_completion]
		handlers[ms.textDocument_completion] = function(err, response, ctx)
			local otter_uri = ctx.params.otter and ctx.params.otter.otter_uri
			err, response, ctx = original(err, response, ctx)
			if response and otter_uri then
				local items = response.isIncomplete ~= nil and response.items or response
				for _, item in ipairs(items) do
					if type(item.data) == "table" and item.data.uri ~= nil then
						item.data.uri = otter_uri
					end
				end
			end
			return err, response, ctx
		end
	end
end

-- otter's get_current_language_context() (used by quarto's run_cell/run_above/
-- run_below/run_line to figure out which language chunk the cursor is in)
-- bounds-checks the cursor against the raw treesitter injection region. When a
-- cell's code runs right up against the closing fence (no trailing blank
-- line), that region's end lands exactly on the last content row with a small
-- end_col, so any cursor past that column on the cell's last line fails the
-- check and reports no chunk found -- moving up a row works because it's no
-- longer on that boundary row. Column position doesn't matter for these
-- cell-level commands, only the row does, so probe with column 0 instead of
-- the real cursor column.
do
	local ok, otterkeeper = pcall(require, "otter.keeper")
	if ok then
		local original = otterkeeper.get_current_language_context
		otterkeeper.get_current_language_context = function(main_nr, position)
			main_nr = main_nr or vim.api.nvim_get_current_buf()
			position = position or vim.api.nvim_win_get_cursor(0)
			return original(main_nr, { position[1], 0 })
		end
	end
end

-- otter-ls (otter's own in-process fake LSP server that proxies requests to
-- the real per-language shadow buffers, see otter/lsp/init.lua) never
-- returns `true, request_id` from its `cmd`-table's `request` function, so
-- `client:request()` against it always reports back `success = nil`. blink's
-- completion path ignores that return value, so the menu itself works fine,
-- but blink's *resolve* path (sources/lsp/init.lua) checks it: `if not
-- success then callback(item) end` -- so it immediately settles with the
-- pre-resolve item (no documentation/detail) the instant `client:request`
-- returns, before otter's real (correctly-uri'd, documented) response has
-- even come back. The real response still arrives, but blink's resolve
-- promise already settled, so it's silently discarded and the doc popup
-- never shows anything for otter/quarto buffers -- known upstream issue,
-- see https://github.com/jmbuhr/otter.nvim/issues/197. Patch the client's
-- rpc.request to actually return a request id.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or not client.name:match("^otter%-ls") or client.rpc.__request_patched then
			return
		end
		client.rpc.__request_patched = true
		local original_request = client.rpc.request
		local next_id = 0
		client.rpc.request = function(method, params, handler, notify_reply_callback)
			next_id = next_id + 1
			original_request(method, params, handler, notify_reply_callback)
			return true, next_id
		end
	end,
})

local quarto = require("quarto")
quarto.setup({
	lspFeatures = {
		-- NOTE: put whatever languages you want here:
		languages = { "r", "python", "rust" },
		chunks = "all",
		diagnostics = {
			enabled = true,
			triggers = { "BufWritePost" },
		},
		completion = {
			enabled = true,
		},
	},
	keymap = {
		-- NOTE: setup your own keymaps:
		hover = "H",
		definition = "gd",
		rename = "<leader>cr",
		references = "gr",
		format = "<leader>gf",
	},
	codeRunner = {
		enabled = true,
		-- Don't use the "molten" string shorthand or quarto.runner.molten.run(): both end up
		-- passing molten's end_col as chunk.range.to[2] + 1. Otter's chunk range always ends
		-- at column 0 of the closing fence (not the last content line), so that's always 1 --
		-- which molten turns into a 0-indexed end.colno of 0, and line[:0] is "", silently
		-- dropping the cell's *entire last line* (e.g. a bare last-line expression that would
		-- trigger IPython's last-expression auto-display never reaches the kernel at all).
		-- Pass 0 for end_col instead: molten computes colno = end_col - 1, so this is the
		-- only value that produces the -1 sentinel nvim_buf_set_extmark(strict=false) resolves
		-- to "end of line" -- passing -1 directly computes colno -2, which is not a valid
		-- extmark column and throws E5555.
		default_method = function(cell)
			local range = cell.range
			vim.fn.MoltenEvaluateRange(range.from[1] + 1, range.to[1], range.from[2] + 1, 0)
		end,
	},
})

-- Visual-mode gc picks ONE 'commentstring' (from the selection's start line) and
-- applies it to every line in the range (see vim._comment.lua: toggle_lines() calls
-- get_comment_parts(ref_position) once, not per line). Fine within a single
-- language, but selecting a whole code cell -- fence included -- starts the range on
-- the fence line, which is markdown, not the chunk's language, so python content
-- gets wrapped in `<!-- -->` too. Comment each line individually instead, so each
-- gets its own commentstring from vim._comment's own tree-sitter-aware detection.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	callback = function(event)
		vim.keymap.set("x", "gc", function()
			local start_line = vim.fn.line("v")
			local end_line = vim.fn.line(".")
			if start_line > end_line then
				start_line, end_line = end_line, start_line
			end
			vim.cmd("normal! \27") -- leave visual mode before editing lines
			local toggle_lines = require("vim._comment").toggle_lines
			for ln = start_line, end_line do
				toggle_lines(ln, ln, { ln, 0 })
			end
		end, { buffer = event.buf, desc = "Comment selection (per-line language-aware)" })
	end,
})

local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
	runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })
