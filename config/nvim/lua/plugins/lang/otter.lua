return { -- for lsp features in code cells / embedded code
  'jmbuhr/otter.nvim',
  dev = false,
  event = 'VeryLazy',
  dependencies = {
    {
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  opts = {},
}
