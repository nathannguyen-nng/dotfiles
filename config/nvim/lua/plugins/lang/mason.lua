return {
  "mason-org/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "neovim/nvim-lspconfig",
    -- "saghen/blink.cmp",
  },
  config = function()
    -- import mason and mason_lspconfig
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      automatic_enable = true,
      -- servers for mason to install
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "denols",
        "emmet_language_server",
        "marksman",
        "bashls",
        "jsonls",
        -- "hls",
        "basedpyright",
        -- "r_language_server",
        "texlab",
        "dotls",
        "yamlls",
        "clangd",
        "sqlls",
        -- 'julia-lsp'
        -- 'rust-analyzer',
      },
    })

    mason_tool_installer.setup({
      auto_update = false,
      run_on_start = false,
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "pylint",
        "clangd",
        "black",
        "shfmt",
        "tree-sitter-cli",
        "jupytext",
        "deno",
        "eslint_d",
        -- { 'eslint_d', version = '13.1.2' },
      },

      -- NOTE: mason BREAKING Change! Removed setup_handlers
      -- moved lsp configuration settings back into lspconfig.lua file
    })
  end,
}
