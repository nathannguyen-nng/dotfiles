return {
  -- requires pngpaste ( brew install pngpaste )
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  cmd = { "PasteImage" },
  keys = {
    -- suggested keymap
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
