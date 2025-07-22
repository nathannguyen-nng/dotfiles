return {
  "nvim-lualine/lualine.nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons", "AndreM222/copilot-lualine" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = "catppuccin",
        -- section_separators = { left = "", right = "" },
        component_separators = { left = "|", right = "|" },
        -- section_separators = { left = "█", right = "" },
        -- section_separators = { left = "", right = "" },
        section_separators = { left = "█", right = "" },
      },
      sections = {
        lualine_b = {
          {
            function()
              return vim.g.remote_neovim_host and ("Remote: %s"):format(vim.uv.os_gethostname()) or ""
            end,
            padding = { right = 1, left = 1 },
            separator = { left = "", right = "" },
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            -- color = { fg = "#ff9e64" },
          },
          { "copilot" },
          { "encoding" },
          {
            "fileformat",
            symbols = {
              unix = "", -- e712
              dos = "", -- e70f
              mac = "", -- e711
            },
          },
          { "filetype" },
        },
      },
      extensions = {
        "neo-tree",
        "mason",
        "lazy",
        "fzf",
        "fugitive",
        "nvim-dap-ui",
        "trouble",
      },
    })
  end,
}
