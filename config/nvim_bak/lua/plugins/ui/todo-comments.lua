return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  --TODO: test
  keys = {
    {
      "<leader>pt",
      function()
        Snacks.picker.todo_comments()
      end,
      desc = "Todo",
    },
    {
      "<leader>pT",
      function()
        Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
      end,
      desc = "Todo/Fix/Fixme",
    },
  },
  config = function()
    local todo_comments = require("todo-comments")
    -- keymaps
    vim.keymap.set("n", "]t", function()
      todo_comments.jump_next()
    end, { desc = "Next todo comment" })

    vim.keymap.set("n", "[t", function()
      todo_comments.jump_prev()
    end, { desc = "Previous todo comment" })

    todo_comments.setup({})
  end,
}
