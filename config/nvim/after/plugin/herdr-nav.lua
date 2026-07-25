-- Must be set before vim-tmux-navigator's plugin/ is sourced below, so our own
-- mappings (set last, further down) are the single source of truth for
-- <C-h/j/k/l>.
vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/paulbkim-dev/vim-herdr-navigation",
})

-- Reimplementation of vim-herdr-navigation's editor/nvim.lua (its own
-- vim-tmux-navigator port), extended to be snacks.nvim-aware.
--
-- snacks.nvim's picker/explorer manages its own window layout with a wrapper
-- "root" window and WinEnter/WinLeave autocmds that snap focus back into the
-- picker whenever focus leaves it. Both vim-herdr-navigation's nav() and
-- vim-tmux-navigator detect "am I at a window edge" by probing with
-- `wincmd l` and checking whether the window changed — that probe briefly
-- focuses snacks' wrapper window, its autocmd immediately bounces back into
-- the picker in the opposite direction, and we mistake that bounce for
-- "moved within Neovim". That's why <C-l> from a right-docked snacks
-- explorer lands back on the main buffer instead of crossing into herdr.
-- See https://github.com/folke/snacks.nvim/discussions/1802 and
-- aserowy/tmux.nvim's fix for the same issue (lua/tmux/wrapper/nvim.lua).
--
-- Fix: never probe-move. Determine the border first without touching the
-- window layout — via the focused snacks picker's known dock position, or a
-- side-effect-free `winnr()` comparison otherwise — then only call `wincmd`
-- once we know the move stays inside Neovim.

local snacks_position_to_wincmd = { left = "h", right = "l", top = "k", bottom = "j" }

local function focused_snacks_picker()
	local ok, Snacks = pcall(require, "snacks")
	if not ok then
		return nil
	end
	for _, picker in ipairs(Snacks.picker.get()) do
		if picker:is_focused() then
			return picker
		end
	end
	return nil
end

local function is_border(wincmd)
	local picker = focused_snacks_picker()
	if picker and picker.layout and picker.layout.root and picker.layout.root.opts then
		return snacks_position_to_wincmd[picker.layout.root.opts.position] == wincmd
	end
	return vim.fn.winnr() == vim.fn.winnr("1" .. wincmd)
end

local function cross_out(dir)
	if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
		local herdr = vim.env.HERDR_BIN_PATH
		if herdr == nil or herdr == "" then
			herdr = "herdr"
		end
		vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
	elseif vim.env.TMUX and vim.env.TMUX ~= "" then
		-- Don't call vim-tmux-navigator's :TmuxNavigate* commands here: they do
		-- their own border probe (plain `wincmd`) before forwarding to tmux,
		-- which re-triggers the exact snacks bounce-back this file works
		-- around, so the forward-to-tmux branch never fires. We've already
		-- established we're at the border, so go straight to tmux.
		local tmux_select_flag = { left = "L", down = "D", up = "U", right = "R" }
		local socket = vim.split(vim.env.TMUX, ",")[1]
		local exe = vim.env.TMUX:find("tmate") and "tmate" or "tmux"
		vim.fn.system({ exe, "-S", socket, "select-pane", "-t", vim.env.TMUX_PANE, "-" .. tmux_select_flag[dir] })
	end
end

local function nav(wincmd, dir)
	if is_border(wincmd) then
		cross_out(dir)
	else
		vim.cmd("wincmd " .. wincmd)
	end
end

local function map(lhs, wincmd, dir, desc)
	vim.keymap.set("n", lhs, function()
		nav(wincmd, dir)
	end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
