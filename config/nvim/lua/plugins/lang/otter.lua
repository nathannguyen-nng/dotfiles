return { -- for lsp features in code cells / embedded code
  "jmbuhr/otter.nvim",
  dev = false,
  ft = { "markdown", "quarto", "python", "r", "julia" },
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  opts = {},
  config = function(_, opts)
    local otter = require("otter")
    otter.setup({
      lsp = {
        hover = true, -- this routes hover to the embedded LSP (e.g., basedpyright)
        diagnostics = true,
        completion = true,
      },
    })
    local is_code_chunk = function()
      local current, _ = require("otter.keeper").get_current_language_context()
      if current then
        return true
      else
        return false
      end
    end

    --- Insert code chunk of given language
    --- Splits current chunk if already within a chunk
    --- @param lang string
    local insert_code_chunk = function(lang)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
      local keys
      if is_code_chunk() then
        keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
      else
        keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
      end
      keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end

    local insert_r_chunk = function()
      insert_code_chunk("r")
    end

    local insert_py_chunk = function()
      insert_code_chunk("python")
    end

    local insert_lua_chunk = function()
      insert_code_chunk("lua")
    end

    local insert_julia_chunk = function()
      insert_code_chunk("julia")
    end

    local insert_bash_chunk = function()
      insert_code_chunk("bash")
    end

    local insert_ojs_chunk = function()
      insert_code_chunk("ojs")
    end

    local function get_otter_symbols_lang()
      local otterkeeper = require("otter.keeper")
      local main_nr = vim.api.nvim_get_current_buf()
      local langs = {}
      for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
        langs[i] = i .. ": " .. l
      end
      -- promt to choose one of langs
      local i = vim.fn.inputlist(langs)
      local lang = otterkeeper.rafts[main_nr].languages[i]
      local params = {
        textDocument = vim.lsp.util.make_text_document_params(),
        otter = {
          lang = lang,
        },
      }
      -- don't pass a handler, as we want otter to use it's own handlers
      vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
    end

    vim.keymap.set("n", "<leader>os", get_otter_symbols_lang, { desc = "otter [s]ymbols" })
    vim.keymap.set("n", "<leader>oa", require("otter").activate, { desc = "otter [a]ctivate" })
    vim.keymap.set("n", "<leader>ob", insert_bash_chunk, { desc = "[b]ash code chunk" })
    vim.keymap.set("n", "<leader>oc", "O# %%<cr>", { desc = "magic [c]omment code chunk # %%" })
    vim.keymap.set("n", "<leader>od", require("otter").activate, { desc = "otter [d]eactivate" })
    vim.keymap.set("n", "<leader>oj", insert_julia_chunk, { desc = "[j]ulia code chunk" })
    vim.keymap.set("n", "<leader>ol", insert_lua_chunk, { desc = "[l]lua code chunk" })
    vim.keymap.set("n", "<leader>oo", insert_ojs_chunk, { desc = "[o]bservable js code chunk" })
    vim.keymap.set("n", "<leader>op", insert_py_chunk, { desc = "[p]ython code chunk" })
    vim.keymap.set("n", "<leader>or", insert_r_chunk, { desc = "[r] code chunk" })
  end,
}
