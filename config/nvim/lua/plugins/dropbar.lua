vim.pack.add({ "https://github.com/Bekaboo/dropbar.nvim" })

require("dropbar").setup()
local dropbar_api = require("dropbar.api")
vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Symbols (winbar)" })
vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Context Start" })
vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Next Context" })
