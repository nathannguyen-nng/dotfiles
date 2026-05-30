-- No recursive mapping and silent command messages
local opts = { noremap = true, silent = true }
-- Set leader prefix key
vim.g.mapleader = " "
vim.g.localleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down in visual selection" })
vim.keymap.set("v", "K", ":m '-2<CR>gv=gv", { desc = "Move lines up in visual selection" })

-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move down in buffer with cursor centered" })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next match with cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous match with cursor centered" })

vim.keymap.set("n", "<leader>hc", ":nohl<CR>", { desc = "Clear search highlights." })

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Paste without replacing clipboard content
vim.keymap.set("x", "<leader>p", [["dP]])
vim.keymap.set("v", "p", '"_dp', opts)

-- Delete without copying to clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "x", '"_x', opts)

-- Exit insert mode with Ctrl + C
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- Set format key
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format) -- Use conform.nvim instead

-- Set Q to nop
vim.keymap.set("n", "Q", "<nop>")

-- Global word search and replace
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word cursor is on globally" }
)

-- Tab
-- vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open a new tab" })
-- vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current tab in a new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>BufferClose<CR>", { desc = "Close current buffer (barbar)" })
vim.keymap.set("n", "<leader>tn", "<cmd>BufferNext<CR>", { desc = "Next buffer (barbar)" })
vim.keymap.set("n", "<leader>tp", "<cmd>BufferPrevious<CR>", { desc = "Previous buffer (barbar)" })
vim.keymap.set("n", "<leader>t1", "<Cmd>BufferGoto 1<CR>", { desc = "Go to buffer 1 (barbar)" })
vim.keymap.set("n", "<leader>t2", "<Cmd>BufferGoto 2<CR>", { desc = "Go to buffer 2 (barbar)" })
vim.keymap.set("n", "<leader>t3", "<Cmd>BufferGoto 3<CR>", { desc = "Go to buffer 3 (barbar)" })
vim.keymap.set("n", "<leader>t4", "<Cmd>BufferGoto 4<CR>", { desc = "Go to buffer 4 (barbar)" })
vim.keymap.set("n", "<leader>t5", "<Cmd>BufferGoto 5<CR>", { desc = "Go to buffer 5 (barbar)" })
vim.keymap.set("n", "<leader>t6", "<Cmd>BufferGoto 6<CR>", { desc = "Go to buffer 6 (barbar)" })
vim.keymap.set("n", "<leader>t7", "<Cmd>BufferGoto 7<CR>", { desc = "Go to buffer 7 (barbar)" })
vim.keymap.set("n", "<leader>t8", "<Cmd>BufferGoto 8<CR>", { desc = "Go to buffer 8 (barbar)" })
vim.keymap.set("n", "<leader>t9", "<Cmd>BufferGoto 9<CR>", { desc = "Go to buffer 9 (barbar)" })
vim.keymap.set("n", "<leader>t0", "<Cmd>BufferLast<CR>", { desc = "Go to last buffer (barbar)" })

-- Split
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make split windows equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split window" })

-- Copy file path to clipboard
vim.keymap.set("n", "<leader>fp", function()
  -- Get the file path relative to home directory
  local filePath = vim.fn.expand("%:~")
  -- Copy the file path to clipboard register
  vim.fn.setreg("+", filePath)
  print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- Compile C++ for Competitive Programming
vim.keymap.set(
  "n",
  "<leader>ccp",
  ":w<CR>:!clang++ -I$HOME/repo/study/cp/lib -fsanitize=address -std=c++17 -Wall -Wextra -Wshadow -DONPC -gdwarf-4 -O0 -o %< %<CR>",
  { noremap = true, silent = false, desc = "Compile current C++ file (CP)" }
)

-- vim.keymap.set(
--   "n",
--   "<leader>ppp",
--   ":w<CR>:!g++-15 -I$HOME/repo/study/ppp_3rd/include/ -L/opt/homebrew/lib/gcc/current -std=c++20 -stdlib=libstdc++ -Wall -Werror -Wextra -pedantic -o %< %<CR>",
--   { noremap = true, silent = false, desc = "Compile current C++ file (PPP)" }
-- )

vim.keymap.set("n", "<leader>ppp", function()
  -- 1. Save the file
  vim.cmd("write")

  -- 2. Safely extract and escape ABSOLUTE filenames
  -- %:p gives the full absolute path to the file
  -- %:p:r gives the absolute path without the extension
  local source = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")

  local safe_source = vim.fn.shellescape(source)
  local safe_output = vim.fn.shellescape(output)

  -- 3. Define compiler and flags
  local compiler = "g++-15"
  local flags =
  "-I$HOME/repo/study/ppp_3rd/include/ -L/opt/homebrew/lib/gcc/current -std=c++20 -stdlib=libstdc++ -Wall -Werror -Wextra -pedantic"

  -- Construct the shell command
  -- We pass the safe_output directly as the execution command.
  -- Since it is an absolute path, it is perfectly safe and deterministic.
  local cmd = string.format("%s %s -o %s %s && %s", compiler, flags, safe_output, safe_source, safe_output)

  -- 4. Calculate floating window geometry
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- 5. Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded"
  }

  -- Open the window and focus it
  vim.api.nvim_open_win(buf, true, win_config)

  -- 6. Spawn the terminal process
  vim.fn.termopen(cmd)

  -- Automatically enter insert mode
  vim.cmd("startinsert")

  -- Optional: Allow pressing 'q' in normal mode to instantly close the float
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, noremap = true, silent = true })
end, { desc = "Compile and Run C++ (PPP) in Float" })

vim.keymap.set("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save current buffer" })
