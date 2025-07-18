return {
  {
    "gelguy/wilder.nvim",
    event = "CmdlineEnter",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- re-enable devicons
      "romgrk/fzy-lua-native",
    },
    config = function()
      local wilder = require("wilder")

      wilder.setup({ modes = { ":", "/", "?" } })

      wilder.set_option("pipeline", {
        wilder.branch(
          wilder.python_file_finder_pipeline({
            file_command = function(_, arg)
              if string.find(arg, "%.") then
                return { "fd", "-tf", "-H" }
              else
                return { "fd", "-tf" }
              end
            end,
            dir_command = { "fd", "-td" },
            filters = { "fuzzy_filter", "difflib_sorter" },
          }),
          wilder.cmdline_pipeline({
            language = "python",
            fuzzy = 1,
          }),
          wilder.python_search_pipeline({
            pattern = wilder.python_fuzzy_pattern(),
            sorter = wilder.python_difflib_sorter(),
            engine = "re",
          })
        ),
      })

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
            accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#8839ef" } }),
          },
        }))
      )
    end,
  },
}

-- return {
--   {
--     "gelguy/wilder.nvim",
--     event = "CmdlineEnter",
--     -- "nvim-telescope/telescope.nvim",
--     build = ":UpdateRemotePlugins",
--     dependencies = {
--       "nvim-tree/nvim-web-devicons",
--       "romgrk/fzy-lua-native",
--     },
--     config = function()
--       local wilder = require("wilder")
--
--       wilder.setup({ modes = { ":", "/", "?" } })
--
--       -- Define custom highlight groups
--       wilder.set_option("pipeline", {
--         wilder.branch(
--           wilder.cmdline_pipeline({
--             -- sets the language to use, 'vim' and 'python' are supported
--             language = "python",
--             -- 0 turns off fuzzy matching
--             -- 1 turns on fuzzy matching
--             -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
--             fuzzy = 1,
--           }),
--           wilder.python_search_pipeline({
--             -- can be set to wilder#python_fuzzy_delimiter_pattern() for stricter fuzzy matching
--             pattern = wilder.python_fuzzy_pattern(),
--             -- omit to get results in the order they appear in the buffer
--             sorter = wilder.python_difflib_sorter(),
--             -- can be set to 're2' for performance, requires pyre2 to be installed
--             -- see :h wilder#python_search() for more details
--             engine = "re",
--           })
--         ),
--       })
--
--       wilder.set_option("pipeline", {
--         wilder.branch(
--           wilder.python_file_finder_pipeline({
--             -- to use ripgrep : {'rg', '--files'}
--             -- to use fd      : {'fd', '-tf'}
--             -- file_command = { "find", ".", "-type", "f", "-printf", "%P\n" },
--             file_command = function(_, arg)
--               if string.find(arg, ".") ~= nil then
--                 return { "fd", "-tf", "-H" }
--               else
--                 return { "fd", "-tf" }
--               end
--             end,
--             -- to use fd      : {'fd', '-td'}
--             -- dir_command = { "find", ".", "-type", "d", "-printf", "%P\n" },
--             dir_command = { "fd", "-td" },
--             -- use {'cpsm_filter'} for performance, requires cpsm vim plugin
--             -- found at https://github.com/nixprime/cpsm
--             filters = { "fuzzy_filter", "difflib_sorter" },
--           }),
--           wilder.cmdline_pipeline(),
--           wilder.python_search_pipeline()
--         ),
--       })
--
--       wilder.set_option(
--         "renderer",
--         wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
--           border = "rounded",
--           max_height = "75%",      -- max height of the palette
--           min_height = 0,          -- set to the same as 'max_height' for a fixed height window
--           prompt_position = "top", -- 'top' or 'bottom' to set the location of the prompt
--           reverse = 0,             -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
--           highlighter = {
--             wilder.basic_highlighter(),
--             wilder.lua_pcre2_highlighter(), -- requires `luarocks install pcre2`
--             wilder.lua_fzy_highlighter(),   -- requires fzy-lua-native vim plugin found
--           },
--           left = { " ", wilder.popupmenu_devicons() },
--           right = { " ", wilder.popupmenu_scrollbar() },
--           highlights = {
--             -- accent = "WilderAccent",
--             -- default = "WilderMenu",
--             accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#8839ef" } }),
--           },
--         }))
--       )
--     end,
--   },
-- }
