return { -- scrollbar
  "dstein64/nvim-scrollview",
  event = "BufWinEnter",
  enabled = true,
  opts = {
    current_only = true,
  },
}
