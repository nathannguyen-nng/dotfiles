return {
  "sphamba/smear-cursor.nvim",
  event = "InsertEnter",
  opts = { -- Default  Range
    stiffness = 0.5,
    trailing_stiffness = 0.5,
    damping = 0.67,
    matrix_pixel_threshold = 0.5,
    legacy_computing_symbols_support = true,
  },
}
