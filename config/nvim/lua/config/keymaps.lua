local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Prevent <space> from acting as a motion — ensures it always waits for which-key
map({ "n", "v" }, "<space>", "<nop>", { silent = true })

-- ═══════════════════════════════════════════════════════════
-- BUFFER NAVIGATION (think browser tabs)
-- ═══════════════════════════════════════════════════════════

-- Tab/Shift-Tab: Like browser tabs, feels natural
map("n", "<Tab>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Prev Buffer" })

-- Alternative buffer switching (vim-style)
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev Buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Quick switch to last edited file (super useful!)
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Other Buffer" })

-- ═══════════════════════════════════════════════════════════
-- WINDOW MANAGEMENT (splitting and navigation)
-- ═══════════════════════════════════════════════════════════

-- Note: window/pane navigation (<C-hjkl>) and resize (<A-hjkl>) are owned by tmux.nvim

-- Resize windows with Ctrl+Shift+arrows (macOS friendly)
map("n", "<C-S-Up>", "<cmd>resize +5<CR>", opts)
map("n", "<C-S-Down>", "<cmd>resize -5<CR>", opts)
map("n", "<C-S-Left>", "<cmd>vertical resize -5<CR>", opts)
map("n", "<C-S-Right>", "<cmd>vertical resize +5<CR>", opts)

-- Window splitting (w = window)
map("n", "<leader>ws", "<C-W>s", { desc = "Split Below", remap = true })
map("n", "<leader>wv", "<C-W>v", { desc = "Split Right", remap = true })
map("n", "<leader>ww", "<C-W>p", { desc = "Other Window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Close Window", remap = true })
map("n", "<leader>wo", "<C-W>o", { desc = "Close Other Windows", remap = true })

-- ═══════════════════════════════════════════════════════════
-- SMART LINE MOVEMENT (the VSCode experience)
-- ═══════════════════════════════════════════════════════════

-- Smart j/k: moves by visual lines when no count, real lines with count
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move lines up/down with Alt+Arrows (Alt+hjkl is owned by tmux.nvim resize)
map("n", "<A-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Move selected block up/down
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move Block Down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move Block Up" })

-- ═══════════════════════════════════════════════════════════
-- SEARCH & NAVIGATION (ergonomic improvements)
-- ═══════════════════════════════════════════════════════════

-- Better line start/end (more comfortable than $ and ^)
map("n", "gl", "$", { desc = "Line End" })
map("n", "gh", "^", { desc = "Line Start" })

-- Select all content
map("n", "==", "gg<S-v>G")
map("n", "<A-a>", "ggVG", { noremap = true, silent = true, desc = "Select all" })

-- Clear search highlighting
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })
map(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- Smart search navigation (n always goes forward, N always backward)

map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- ═══════════════════════════════════════════════════════════
-- SMART TEXT EDITING
-- ═══════════════════════════════════════════════════════════

-- Better indenting (stay in visual mode)

map("v", "<", "<gv")
map("v", ">", ">gv")

-- Better paste (doesn't replace clipboard with deleted text)
map("v", "p", '"_dP', opts)

-- Copy whole file to clipboard
map("n", "<C-c>", ":%y+<CR>", opts)

-- Smart undo break-points (create undo points at logical stops)
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Auto-close pairs (simple, no plugin needed)

map("i", "`", "``<left>")
map("i", '"', '""<left>')
map("i", "(", "()<left>")
map("i", "[", "[]<left>")
map("i", "{", "{}<left>")
map("i", "<", "<><left>")

-- Note: Single quotes commented out to avoid conflicts in some contexts
-- map("i", "'", "''<left>")

-- ═══════════════════════════════════════════════════════════
-- FILE OPERATIONS
-- ═══════════════════════════════════════════════════════════

-- Save file (works in all modes)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Create new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- Quit operations
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- ═══════════════════════════════════════════════════════════
-- DEVELOPMENT TOOLS
-- ═══════════════════════════════════════════════════════════

-- Commenting (add comment above/below current line)
map("n", "gco", "o<esc>Vcx<esc>gcc$a<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc>gcc$a<bs>", { desc = "Add Comment Above" })

-- Quickfix and location lists
map("n", "<leader>xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Inspection tools (useful for debugging highlights and treesitter)
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- Keyword program (K for help on word under cursor)
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- ═══════════════════════════════════════════════════════════
-- TERMINAL INTEGRATION
-- ═══════════════════════════════════════════════════════════

-- Terminal mode navigation
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- ═══════════════════════════════════════════════════════════
-- TAB MANAGEMENT (when you need multiple workspaces)
-- ═══════════════════════════════════════════════════════════

map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- ═══════════════════════════════════════════════════════════
-- FOLDING NAVIGATION (for code organization)
-- ═══════════════════════════════════════════════════════════

-- Close all folds except current one (great for focus)
map("n", "zv", "zMzvzz", { desc = "Focus Fold" })

-- Smart fold navigation (closes current, opens next/previous)
map("n", "zj", "zcjzOzz", { desc = "Next Fold" })
map("n", "zk", "zckzOzz", { desc = "Prev Fold" })

-- ═══════════════════════════════════════════════════════════
-- UTILITY SHORTCUTS
-- ═══════════════════════════════════════════════════════════

-- Fix spelling (picks first suggestion)
map("n", "z0", "1z=", { desc = "Fix Word Under Cursor" })

-- ═══════════════════════════════════════════════════════════
-- MOLTEN SHORTCUTS
-- ═══════════════════════════════════════════════════════════

map("n", "<localleader>ip", function()
	local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
	if venv ~= nil then
		-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
		venv = string.match(venv, "/.+/(.+)")
		vim.cmd(("MoltenInit %s"):format(venv))
	else
		vim.cmd("MoltenInit python3")
	end
end, { desc = "Initialize Molten for python3", silent = true })

map("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })
map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
map("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
map("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })
map("n", "<localleader>mi", ":MoltenImagePopup<CR>", { desc = "open image output in Preview", silent = true })
