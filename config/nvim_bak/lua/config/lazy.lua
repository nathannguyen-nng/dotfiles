-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins.ui" },
    { import = "plugins.editor" },
    { import = "plugins.lang" },
    { import = "plugins.util" },
    { import = "plugins.debugger" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin" } },
  -- automatically check for plugin updates
  checker = {
    enabled = true,
    notify = false
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",             -- rarely used for reading .gz files
        "netrwPlugin",      -- disable if you use telescope, nvim-tree, neo-tree, etc.
        "tarPlugin",        -- disables support for browsing .tar files
        "tohtml",           -- convert buffer to HTML; probably never used
        "tutor",            -- the Vim tutor
        "zipPlugin",        -- like tarPlugin, but for zip files
        "shada_plugin",     -- shada session plugin (if not using `shada` at all)
        "spellfile_plugin", -- spellfile.vim; if you're not using spelling
      },
    },
  }
})
