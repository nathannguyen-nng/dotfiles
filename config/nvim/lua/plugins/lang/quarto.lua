return { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
  -- for complete functionality (language features)
  "quarto-dev/quarto-nvim",
  ft = { "quarto", "markdown" },
  dev = false,
  opts = {
    lspFeatures = {
      enabled = true,
      chunks = "curly",
      languages = { "r", "python", "julia", "bash", "html" },
      diagnostics = {
        enabled = true,
        triggers = { "BufWritePost" },
      },
      completion = {
        enabled = true,
      },
    },
    codeRunner = {
      enabled = true,
      default_method = "slime",
    },
  },
  keys = {
    -- { "<leader>q", group = "[q]uarto" },
    {
      "<leader>qE",
      function()
        require("otter").export(true)
      end,
      desc = "[E]xport with overwrite",
    },
    { "<leader>qa", ":QuartoActivate<cr>", desc = "[a]ctivate" },
    { "<leader>qe", require("otter").export, desc = "[e]xport" },
    { "<leader>qh", ":QuartoHelp ", desc = "[h]elp" },
    { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review" },
    { "<leader>qu", ":lua require'quarto'.quartoUpdatePreview()<cr>", desc = "[u]pdate preview" },
    { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uiet preview" },
    { "<leader>qr", group = "[r]un" },
    { "<leader>qra", ":QuartoSendAll<cr>", desc = "run [a]ll" },
    { "<leader>qrb", ":QuartoSendBelow<cr>", desc = "run [b]elow" },
    { "<leader>qrr", ":QuartoSendAbove<cr>", desc = "to cu[r]sor" },
  },
  dependencies = {
    -- for language features in code cells
    -- configured in lua/plugins/lsp.lua
    "jmbuhr/otter.nvim",
  },
}
