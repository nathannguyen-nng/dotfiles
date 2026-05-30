local opt = vim.opt

vim.cmd("let g:netrw_banner = 0") -- Disable NetRW file explorer banner
vim.g.markdown_recommended_style = 0

-- General editor settings
-- opt.guicursor = ""					        -- Use block cursor
opt.guicursor = {
  "n-v-c:block",                  -- normal, visual, cmdline
  "i-ci-ve:ver25",                -- insert, insert-completion, visual-select
  "r-cr:hor20",                   -- replace & virtual-replace
  "o:hor50",                      -- operator-pending
}
opt.number = true                 -- Display line numbers
opt.relativenumber = true     -- Enable relative line numbers
opt.cmdheight = 0             -- Hide cmdline
opt.cursorline = true
opt.hidden = true 				-- allow hidden buffers
opt.autochdir = false 				-- don't auto change directory
opt.iskeyword:append("-") 			-- treat dash as part of word
opt.path:append("**") 				-- include subdirectories in search
opt.selection = "exclusive" 			-- selection behavior
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- sync with system clipboard
opt.modifiable = true 				-- allow buffer modifications
opt.encoding = "UTF-8" 				-- set encoding

-- Status line
opt.laststatus = 3 -- One global status line for all buffers

-- Wrap
opt.wrap = true
opt.linebreak = true
opt.breakindent = true -- keep indentation on wrapped lines
opt.showbreak = "↪ " -- marker shown on wrapped segments

-- Tab and indentation settings
opt.tabstop = 2        -- Set tab stop
opt.softtabstop = 2    -- Set soft tab stop
opt.shiftwidth = 2     -- Set shift width
opt.expandtab = true   -- Convert tab into spaces
opt.autoindent = true  -- Automatically indent new line
opt.smartindent = true -- Set smartindent mode
opt.shiftround = true -- Round indent

-- File settings
opt.swapfile = false -- Disable swap file
opt.backup = false   -- Disable file backup
opt.undofile = true  -- Enable persistent undo
opt.undolevels = 10000
opt.undodir = vim.fn.expand("~/.vim/undodir") 	-- undo directory
opt.updatetime = 300 -- LSP / completion debounce; CursorHold (GitSigns, etc.)
opt.timeoutlen = vim.g.vscode and 1000 or 300 	-- lower than default (1000) to quickly trigger which-key
opt.ttimeoutlen = 0 				-- key code timeout
opt.autoread = true 				-- auto reload files changed outside vim
opt.autowrite = true 				-- auto save

-- Search settings
opt.hlsearch = true                          -- Highlight match when searching
opt.incsearch = true     -- Highlight every match, not only the first
opt.inccommand = "split" -- Show live preview of substitute in a split window
opt.ignorecase = true    -- Search will not be case-sensitive generally
opt.smartcase = true     -- Search will be case-sensitive when it includes capitalized letters

-- Visual settings
opt.termguicolors = true -- Enable 24-bit true-color
opt.scrolloff = 10        -- Number of lines visible above and below the cursor when scrolling
opt.sidescrolloff = 8        -- Number of lines visible left and right of the cursor when scrolling
opt.signcolumn = "yes:1"
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
opt.statuscolumn = "%=%l%s%C"
opt.jumpoptions = "view"
opt.showmatch = true
opt.conceallevel = 2 				-- hide * markup for bold and italic, but not markers with substitutions
opt.concealcursor = "nc"			-- do not hide * markup for bold and italic when in editing mode
opt.confirm = true				-- confirm to save changes before exiting an modified buffer
opt.synmaxcol = 300 				-- syntax highlighting limit
opt.ruler = false 				-- disable the default ruler
opt.virtualedit = "block" 			-- allow cursor to move where there is no text in visual block mode



opt.backspace = { "start", "eol", "indent" } -- Set backspace behaviors in Insert mode
opt.splitright = true                        -- Allow vertical splitting
opt.splitbelow = true                        -- Allow horizontal splitting

opt.isfname:append("@-@")                    -- Treat '@' as part of a filename under the cursor
opt.colorcolumn = "120"                      -- Draw vertical marker


opt.mouse = "a"                              -- Support mouse in all modes
vim.g.editorconfig = true                        -- Read ".editorconfig" for consistent settings across editors

-- folding (treesitter)
opt.smoothscroll = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.formatoptions = "jcroqlnt" 			-- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- command-line completion
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- better diff options
opt.diffopt:append("linematch:60")

-- performance improvements
opt.redrawtime = 10000
opt.maxmempattern = 20000

-- create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
