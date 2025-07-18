return {
  "f-person/auto-dark-mode.nvim",
  event = "VeryLazy",
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.cmd("colorscheme catppuccin-frappe")
      local wilder = require("wilder")

      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
          border = "rounded",
          max_height = "75%",
          min_height = 0,
          prompt_position = "top",
          reverse = 0,
          highlighter = {
            wilder.basic_highlighter(),
            wilder.lua_fzy_highlighter(),
          },
          left = { " ", wilder.popupmenu_devicons() }, -- devicons here
          right = { " ", wilder.popupmenu_scrollbar() },
          highlights = {
            accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#e78284" } }),
          },
        }))
      )
    end,
    set_light_mode = function()
      vim.cmd("colorscheme catppuccin-latte")

      local wilder = require("wilder")

      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
          border = "rounded",
          max_height = "75%",
          min_height = 0,
          prompt_position = "top",
          reverse = 0,
          highlighter = {
            wilder.basic_highlighter(),
            wilder.lua_fzy_highlighter(),
          },
          left = { " ", wilder.popupmenu_devicons() }, -- devicons here
          right = { " ", wilder.popupmenu_scrollbar() },
          highlights = {
            accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#d20f39" } }),
          },
        }))
      )
    end,
  },
}
