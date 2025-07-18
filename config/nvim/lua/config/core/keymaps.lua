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
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Set Q to nop
vim.keymap.set("n", "Q", "<nop>")

-- Global word search and replace
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word cursor is on globally" }
)

-- Highlight yank after copying
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Tab
-- vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open a new tab" })
-- vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current tab in a new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>BufferClose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>BufferNext<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>BufferPrevious<CR>", { desc = "Go to previous tab" })
-- Goto buffer in position...
vim.keymap.set("n", "<leader>t1", "<Cmd>BufferGoto 1<CR>", { desc = "Go to 1st tab" })
vim.keymap.set("n", "<leader>t2", "<Cmd>BufferGoto 2<CR>", { desc = "Go to 2nd tab" })
vim.keymap.set("n", "<leader>t3", "<Cmd>BufferGoto 3<CR>", { desc = "Go to 3rd tab" })
vim.keymap.set("n", "<leader>t4", "<Cmd>BufferGoto 4<CR>", { desc = "Go to 4th tab" })
vim.keymap.set("n", "<leader>t5", "<Cmd>BufferGoto 5<CR>", { desc = "Go to 5th tab" })
vim.keymap.set("n", "<leader>t6", "<Cmd>BufferGoto 6<CR>", { desc = "Go to 6th tab" })
vim.keymap.set("n", "<leader>t7", "<Cmd>BufferGoto 7<CR>", { desc = "Go to 7th tab" })
vim.keymap.set("n", "<leader>t8", "<Cmd>BufferGoto 8<CR>", { desc = "Go to 8th tab" })
vim.keymap.set("n", "<leader>t9", "<Cmd>BufferGoto 9<CR>", { desc = "Go to 9th tab" })
vim.keymap.set("n", "<leader>t0", "<Cmd>BufferLast<CR>", { desc = "Go to last tab" })

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

-- Compile C++
vim.keymap.set(
  "n",
  "<leader>cp",
  ":w<CR>:!clang++ -I$HOME/repo/study/cp/lib -fsanitize=address -std=c++17 -Wall -Wextra -Wshadow -DONPC -gdwarf-4 -O0 -o %< %<CR>",
  { noremap = true, silent = false, desc = "Compile current C++ file (CP)" }
)

vim.keymap.set("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save current buffer" })

vim.keymap.set("n", "<leader>ch", function()
  vim.cmd("noh")
end, { desc = "Clear search highlights" })
