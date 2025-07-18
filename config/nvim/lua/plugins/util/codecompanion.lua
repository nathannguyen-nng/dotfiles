return {
  "olimorris/codecompanion.nvim",
  version = "*",
  event = "InsertEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>ac", ":CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
    { "<leader>aa", ":CodeCompanionActions<cr>",     desc = "AI Action" },
  },
  config = function()
    require("codecompanion").setup({
      display = {
        chat = {
          window = {
            layout = "float", -- float|vertical|horizontal|buffer
            position = nil,   -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
            full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              numberwidth = 1,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
        },
        diff = {
          enabled = true,
        },
      },
      strategies = {
        chat = {
          -- adapter = "ollama",
          adapter = "copilot",
          -- adapter = "anthropic",
        },
        inline = {
          -- adapter = "ollama",
          adapter = "copilot",
          -- adapter = "anthropic",
        },
        agent = {
          -- adapter = "ollama",
          adapter = "copilot",
          -- adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          local key = os.getenv("ANTHROPIC_API_KEY")
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = key,
            },
          })
        end,
      },
    })
  end,
}
