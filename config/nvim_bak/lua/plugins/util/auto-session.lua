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
    require("auto-session").setup({
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      
      -- 1. Close Neo-tree before saving the session
      pre_save_cmds = {
        "Neotree close",
      },

      -- 2. Re-open Neo-tree after the session is restored
      post_restore_cmds = {
        "Neotree show", -- Use 'show' to open without stealing focus
      },
    })
  end,
}
