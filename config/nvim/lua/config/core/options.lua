-- Use python3 from homebrew
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

vim.cmd("let g:netrw_banner = 0") -- Disable NetRW file explorer banner

-- General editor settings
-- vim.opt.guicursor = ""					        -- Use block cursor
vim.opt.guicursor = {
  "n-v-c:block", -- normal, visual, cmdline
  "i-ci-ve:ver25", -- insert, insert-completion, visual-select
  "r-cr:hor20", -- replace & virtual-replace
  "o:hor50", -- operator-pending
}
vim.opt.nu = true -- Display line numbers
vim.opt.relativenumber = true -- Enable relative line numbers
vim.opt.fillchars = { eob = " " } -- Fillchars
vim.opt.cmdheight = 0 -- Hide cmdline

-- Status line
vim.opt.laststatus = 3 -- One global status line for all buffers

-- Wrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true -- keep indentation on wrapped lines
vim.opt.showbreak = "↪ " -- marker shown on wrapped segments

-- Tab and indentation settings
vim.opt.tabstop = 2 -- Set tab stop
vim.opt.softtabstop = 2 -- Set soft tab stop
vim.opt.shiftwidth = 2 -- Set shift width
vim.opt.expandtab = true -- Convert tab into spaces
vim.opt.autoindent = true -- Automatically indent new line
vim.opt.smartindent = true -- Set smartindent mode

-- File settings
vim.opt.swapfile = false -- Disable swap file
vim.opt.backup = false -- Disable file backup
vim.opt.undofile = true -- Enable persistent undo

-- Search settings
vim.opt.incsearch = true -- Highlight every match, not only the first
vim.opt.inccommand = "split" -- Show live preview of substitute in a split window
vim.opt.ignorecase = true -- Search will not be case-sensitive generally
vim.opt.smartcase = true -- Search will be case-sensitive when it includes capitalized letters

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit true-color
vim.opt.scrolloff = 8 -- Number of lines visible above and below the cursor when scrolling
vim.opt.signcolumn = "yes:1"
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.opt.statuscolumn = "%=%l%s%C"

vim.opt.backspace = { "start", "eol", "indent" } -- Set backspace behaviors in Insert mode
vim.opt.splitright = true -- Allow vertical splitting
vim.opt.splitbelow = true -- Allow horizontal splitting

vim.opt.isfname:append("@-@") -- Treat '@' as part of a filename under the cursor
vim.opt.updatetime = 50 -- Set idle time before "CursorHold" events
-- vim.opt.timeoutlen = 300 -- Set timeout length for key sequences
vim.opt.colorcolumn = "120" -- Draw vertical marker

vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.hlsearch = true -- Highlight match when searching

vim.opt.mouse = "a" -- Support mouse in all modes
vim.g.editorconfig = true -- Read ".editorconfig" for consistent settings across editors
