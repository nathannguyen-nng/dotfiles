return {
  'nvim-neotest/neotest',
  dependencies = { 'nvim-neotest/neotest-python' },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('neotest').setup {
      adapters = {
        require 'neotest-python',
      },
    }
  end,
  keys = {
    { '<leader>dtt', ":lua require'neotest'.run.run({strategy = 'dap'})<cr>", desc = '[t]est' },
    { '<leader>dts', ":lua require'neotest'.run.stop()<cr>",                  desc = '[s]top test' },
    { '<leader>dta', ":lua require'neotest'.run.attach()<cr>",                desc = '[a]ttach test' },
    { '<leader>dtf', ":lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", desc = 'test [f]ile' },
    { '<leader>dts', ":lua require'neotest'.summary.toggle()<cr>",            desc = 'test [s]ummary' },
  },
}
