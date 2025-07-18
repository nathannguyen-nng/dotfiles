return {
  "NvChad/nvim-colorizer.lua",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "BufReadPre",
  opts = {},
  config = function()
    local nvchadcolorizer = require("colorizer")
    local tailwindcolorizer = require("tailwindcss-colorizer-cmp")

    nvchadcolorizer.setup({
      user_default_options = {
        tailwind = true,
      },
      filetypes = { "html", "css", "javascript", "typescript", "jsx", "tsx", "vue", "svelte" },
    })

    tailwindcolorizer.setup({
      color_square_width = 2,
    })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      callback = function()
        vim.cmd("ColorizerAttachToBuffer")
      end,
    })
  end,
}
