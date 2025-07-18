return {
  "mrjones2014/smart-splits.nvim",
  keys = {
    { "<A-h>",             desc = "Resize left" },
    { "<A-j>",             desc = "Resize down" },
    { "<A-k>",             desc = "Resize up" },
    { "<A-l>",             desc = "Resize right" },
    { "<C-h>",             desc = "Move left" },
    { "<C-j>",             desc = "Move down" },
    { "<C-k>",             desc = "Move up" },
    { "<C-l>",             desc = "Move right" },
    { "<C-\\>",            desc = "Move to previous window" },
    { "<leader><leader>h", desc = "Swap buffer left" },
    { "<leader><leader>j", desc = "Swap buffer down" },
    { "<leader><leader>k", desc = "Swap buffer up" },
    { "<leader><leader>l", desc = "Swap buffer right" },
  },
  config = function()
    local ss = require("smart-splits")
    vim.keymap.set("n", "<A-h>", ss.resize_left)
    vim.keymap.set("n", "<A-j>", ss.resize_down)
    vim.keymap.set("n", "<A-k>", ss.resize_up)
    vim.keymap.set("n", "<A-l>", ss.resize_right)
    vim.keymap.set("n", "<C-h>", ss.move_cursor_left)
    vim.keymap.set("n", "<C-j>", ss.move_cursor_down)
    vim.keymap.set("n", "<C-k>", ss.move_cursor_up)
    vim.keymap.set("n", "<C-l>", ss.move_cursor_right)
    vim.keymap.set("n", "<C-\\>", ss.move_cursor_previous)
    vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left)
    vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down)
    vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up)
    vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right)
  end,
}
