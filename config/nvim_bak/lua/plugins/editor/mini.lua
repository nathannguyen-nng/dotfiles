return {
  "echasnovski/mini.nvim",
  version = false,
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })

    -- mini.comment
    require("mini.comment").setup({
      -- tsx, jsx, html, svelte comment support
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring({ key = "commentstring" })
            or vim.bo.commentstring
        end,
      },
    })
    -- mini.surround
    require("mini.surround").setup()
    -- mini.trailspace
    require("mini.trailspace").setup({
      only_in_normal_buffer = true,
    })

    vim.keymap.set("n", "<leader>cw", function()
      require("mini.trailspace").trim()
    end, { desc = "Clear all trailing whitespaces" })
    -- Ensure highlight never reappears by removing it on CursorMoved
    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "*",
      callback = function()
        require("mini.trailspace").unhighlight()
      end,
    })

    --mini.splitjoin
    require("mini.splitjoin").setup({
      mappings = { toggle = "" }, -- Disable default mapping
    })

    vim.keymap.set({ "n", "x" }, "sj", function()
      require("mini.splitjoin").join()
    end, { desc = "Join arguments" })
    vim.keymap.set({ "n", "x" }, "sk", function()
      require("mini.splitjoin").split()
    end, { desc = "Split arguments" })
  end,
}
