return {
  "thePrimeagen/harpoon",
  enabled = true,
  event = "VeryLazy",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      global_settings = {
        save_on_toggle = true,
        save_on_change = true,
      },
    })

    local normalize_list = function(t)
      local normalized = {}
      for _, v in pairs(t) do
        if v ~= nil then
          table.insert(normalized, v)
        end
      end
      return normalized
    end

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Add current file to harpoon" })
    vim.keymap.set("n", "<leader>h1", function()
      harpoon:list():select(1)
    end, { desc = "Select 1st marked file in harpoon" })
    vim.keymap.set("n", "<leader>h2", function()
      harpoon:list():select(2)
    end, { desc = "Select 2nd marked file in harpoon" })
    vim.keymap.set("n", "<leader>h3", function()
      harpoon:list():select(3)
    end, { desc = "Select 3rd marked file in harpoon" })
    vim.keymap.set("n", "<leader>h4", function()
      harpoon:list():select(4)
    end, { desc = "Select 4th marked file in harpoon" })
    vim.keymap.set("n", "<leader>h5", function()
      harpoon:list():select(5)
    end, { desc = "Select 5th marked file in harpoon" })
    vim.keymap.set("n", "<leader>h6", function()
      harpoon:list():select(6)
    end, { desc = "Select 6th marked file in harpoon" })
    vim.keymap.set("n", "<leader>h7", function()
      harpoon:list():select(7)
    end, { desc = "Select 7th marked file in harpoon" })
    vim.keymap.set("n", "<leader>h8", function()
      harpoon:list():select(8)
    end, { desc = "Select 8th marked file in harpoon" })
    vim.keymap.set("n", "<leader>h9", function()
      harpoon:list():select(9)
    end, { desc = "Select 9th marked file in harpoon" })
    vim.keymap.set("n", "<leader>hh", function()
      Snacks.picker({
        finder = function()
          local file_paths = {}
          local list = normalize_list(harpoon:list().items)
          for i, item in ipairs(list) do
            table.insert(file_paths, { text = item.value, file = item.value })
          end
          return file_paths
        end,
        win = {
          input = {
            keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
          },
          list = {
            keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
          },
        },
        actions = {
          harpoon_delete = function(picker, item)
            local to_remove = item or picker:selected()
            harpoon:list():remove({ value = to_remove.text })
            harpoon:list().items = normalize_list(harpoon:list().items)
            picker:find({ refresh = true })
          end,
        },
      })
    end, { desc = "Open harpoon list" })

    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Go to next file in harpoon list" })
    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():next()
    end, { desc = "Go to previous file in harpoon list" })
  end,
}
