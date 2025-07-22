return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        quarto = { "injected" },
        markdown = { "injected" },
        r = { "styler" }
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })
    -- Customize the "injected" formatter
    require('conform').formatters.injected = {
      -- Set the options field
      options = {
        -- Set to true to ignore errors
        ignore_errors = false,
        -- Map of treesitter language to file extension
        -- A temporary file name with this extension will be generated during formatting
        -- because some formatters care about the filename.
        lang_to_ext = {
          bash = 'sh',
          c_sharp = 'cs',
          elixir = 'exs',
          javascript = 'js',
          julia = 'jl',
          latex = 'tex',
          markdown = 'md',
          python = 'py',
          ruby = 'rb',
          rust = 'rs',
          teal = 'tl',
          r = 'r',
          typescript = 'ts',
        },
        -- Map of treesitter language to formatters to use
        -- (defaults to the value from formatters_by_ft)
        lang_to_formatters = {},
      },
    }

    -- Configure individual formatters
    conform.formatters.prettier = {
      args = {
        "--stdin-filepath",
        "$FILENAME",
        "--tab-width",
        "2",
        -- "--use-tab",
        -- "false",
      },
    }

    conform.formatters.deno_fmt = {
      command = "deno",
      args = { "fmt", "-", "--ext", "ts" },
      stdin = true,
    }

    conform.formatters.shfmt = {
      prepend_args = { "-i", "4" },
    }

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format code" })
  end,
}
