return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    -- "saghen/blink.cmp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    { "folke/neoconf.nvim", opts = {}, enabled = false },
  },
  config = function()
    -- NOTE: LSP Keybinds
    local Snacks = require("snacks")

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings
        -- Check `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- keymaps
        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", function()
          Snacks.picker.lsp_references()
        end, opts) -- show definition, references

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", function()
          Snacks.picker.lsp_definitions()
        end, opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", function()
          Snacks.picker.lsp_implementations()
        end, opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", function()
          Snacks.picker.lsp_type_definitions()
        end, opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>vca", function()
          vim.lsp.buf.code_action()
        end, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", function()
          Snacks.picker.diagnostics({ bufnr = 0 })
        end, opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

        vim.keymap.set("i", "<C-h>", function()
          vim.lsp.buf.signature_help()
        end, opts)
      end,
    })

    -- Define sign icons for each severity
    local signs = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    }

    -- Set the diagnostic config with all icons
    vim.diagnostic.config({
      signs = {
        text = signs, -- Enable signs in the gutter
      },
      virtual_text = false, -- Specify Enable virtual text for diagnostics
      underline = true, -- Specify Underline diagnostics
      update_in_insert = false, -- Keep diagnostics active in insert mode
    })

    -- Setup servers
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()
    local lsp = vim.lsp

    local lsp_flags = {
      allow_incremental_sync = true,
      debounce_text_changes = 150,
    }

    local function get_quarto_resource_path()
      local function strsplit(s, delimiter)
        local result = {}
        for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
          table.insert(result, match)
        end
        return result
      end

      local f = assert(io.popen("quarto --paths", "r"))
      local s = assert(f:read("*a"))
      f:close()
      return strsplit(s, "\n")[2]
    end

    local lua_library_files = vim.api.nvim_get_runtime_file("", true)
    local lua_plugin_paths = {}
    local resource_path = get_quarto_resource_path()
    if resource_path == nil then
      vim.notify_once("quarto not found, lua library files not loaded")
    else
      table.insert(lua_library_files, resource_path .. "/lua-types")
      table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
    end

    -- Config lsp servers here

    -- lua_ls
    lsp.enable("lua_ls")
    lsp.config("lua_ls", {
      single_file_support = true,
      flags = lsp_flags,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- emmet_language_server

    lsp.enable("emmet_language_server")
    lsp.config("emmet_language_server", {
      -- on_attach = on_attach,
      capabilities = capabilities,
      flags = lsp_flags,
      filetypes = {
        "css",
        "eruby",
        "html",
        "javascript",
        "javascriptreact",
        "less",
        "sass",
        "scss",
        "pug",
        "typescriptreact",
      },
      init_options = {
        includeLanguages = {},
        excludeLanguages = {},
        extensionsPath = {},
        preferences = {},
        showAbbreviationSuggestions = true,
        showExpandedAbbreviation = "always",
        showSuggestionsAsSnippets = false,
        syntaxProfiles = {},
        variables = {},
      },
    })

    -- denols

    lsp.enable("denols")
    lsp.config("denols", {
      -- on_attach = on_attach,
      capabilities = capabilities,
      root_markers = { "deno.json", "deno.jsonc" },
      flags = lsp_flags,
      workspace_required = true,
      -- init_options = {
      --   lint = true,
      -- },
    })

    -- ts_ls (replaces tsserver)
    lsp.enable("ts_ls")
    lsp.config("ts_ls", {
      -- on_attach = on_attach,
      capabilities = capabilities,
      flags = lsp_flags,
      root_markers = { "package.json" },
      workspace_required = true,
      init_options = {
        preferences = {
          includeCompletionsWithSnippetText = true,
          includeCompletionsForImportStatements = true,
        },
      },
    })

    -- clangd
    lsp.enable("clangd")
    lsp.config("clangd", {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    -- r_language_server

    -- lsp.enable("r_language_server")
    --
    -- lsp.config("r_language_server", {
    --   capabilities = capabilities,
    --   filetypes = { "r", "rmd", "rmarkdown" },
    --   flags = lsp_flags,
    --   settings = {
    --     r = {
    --       lsp = {
    --         rich_documentation = true,
    --       },
    --     },
    --   },
    -- })
    --
    -- yamlls
    lsp.enable("yamlls")
    lsp.config("yamlls", {
      capabilities = capabilities,
      flags = lsp_flags,
      settings = {
        yaml = {
          schemaStore = {
            enable = true,
            url = "",
          },
        },
      },
    })

    -- jsonls
    lsp.enable("jsonls")
    lsp.config("jsonls", {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    -- texlab
    lsp.enable("texlab")
    lsp.config("texlab", {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    -- dotls
    lsp.enable("dotls")
    lsp.config("dotls", {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    -- bashls
    lsp.enable("bashls")
    lsp.config("bashls", {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    -- See https://github.com/neovim/neovim/issues/23291
    -- disable lsp watcher.
    -- Too lags on linux for python projects
    -- because pyright and nvim both create too many watchers otherwise
    if capabilities.workspace == nil then
      capabilities.workspace = {}
      capabilities.workspace.didChangeWatchedFiles = {}
    end
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

    -- basedpyright - pyright + some exclusive pylance features
    lsp.enable("basedpyright")
    lsp.config("basedpyright", {
      capabilities = capabilities,
      flags = lsp_flags,
      root_markers = { ".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt" },
      settings = {
        basedpyright = {
          analysis = {
            diagnosticMode = "openFilesOnly",
            typeCheckingMode = "basic",
            capabilities = capabilities,
            useLibraryCodeForTypes = true,
            diagnosticSeverityOverrides = {
              autoSearchPaths = true,
              enableTypeIgnoreComments = false,
              reportGeneralTypeIssues = "none",
              reportArgumentType = "none",
              reportUnknownMemberType = "none",
              reportAssignmentType = "none",
            },
          },
        },
      },
    })
  end,
}
