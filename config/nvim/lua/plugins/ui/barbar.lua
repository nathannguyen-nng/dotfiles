return {
  "romgrk/barbar.nvim",
  event = "BufReadPre",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  version = "^1.0.0", -- optional: only update when a new 1.x version is released
  config = function()
    require("barbar").setup({
      animation = true,
      tabpages = true,
      -- Disable highlighting alternate buffers
      highlight_alternate = true,

      -- Disable highlighting file icons in inactive buffers
      highlight_inactive_file_icons = true,

      -- Enable highlighting visible buffers
      highlight_visible = true,
      icons = {
        preset = "default",
        separator = { left = "", right = "" },

        -- If true, add an additional separator at the end of the buffer list
        separator_at_end = false,
      },
      -- Set the filetypes which barbar will offset itself for
      sidebar_filetypes = {
        ["leetcode.nvim"] = {
          text = "Leetcode",
          align = "center",
        },
        undotree = {
          text = "Undo Tree",
          align = "center", -- *optionally* specify an alignment (either 'left', 'center', or 'right')
        },
        codecompanion = { -- <─ the filetype to match
          text = "Code Companion", -- label shown in the tabline
          align = "center", -- 'left' | 'center' | 'right'
        },
        ["neo-tree"] = true,

        -- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
        -- NvimTree = true,
        -- Or, specify the text used for the offset:
      },
    })
  end,
}
