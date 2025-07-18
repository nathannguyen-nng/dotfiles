return {
  enabled = false,
  "rmagatti/auto-session",
  opts = {
    auto_restore_enabled = false,
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/", "~/Desktop" },
    -- log_level = 'debug',
  },
  config = function()
    vim.keymap.set("n", "<leader>Wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
    vim.keymap.set("n", "<leader>Ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" })
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    require("auto-session").setup({})
  end,
}
