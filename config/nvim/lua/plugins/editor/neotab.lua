return {
  "kawre/neotab.nvim",
  event = "InsertEnter",
  opts = {
    tab_key = "",
    behavior = "nested",
    smart_punctuators = {
      enabled = true,
      semicolon = {
        enabled = false,
        ft = { "cs", "c", "cpp", "java", "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      escape = {
        enabled = true,
        triggers = {
          ["+"] = {
            pairs = {
              { open = '"', close = '"' },
            },
            -- string.format(format, typed_char)
            format = " %s ", -- " + "
            ft = { "java" },
          },
          [","] = {
            pairs = {
              { open = "'", close = "'" },
              { open = '"', close = '"' },
            },
            format = "%s ", -- ", "
          },
          ["="] = {
            pairs = {
              { open = "(", close = ")" },
            },
            ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            format = " %s> ", -- ` => `
            -- string.match(text_between_pairs, cond)
            cond = "^$",      -- match only pairs with empty content
          },
        },
      },
    },
  },
}
