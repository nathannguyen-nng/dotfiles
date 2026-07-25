vim.pack.add({
	{ src = "https://github.com/kawre/neotab.nvim" },
})

-- Set up immediately (not deferred to InsertEnter like blink.cmp) so neotab's
-- <Tab>/<S-Tab> insert-mode maps exist before blink's setup() runs on the first
-- InsertEnter. blink's "fallback" keymap action runs the next non-blink keymap
-- for that key, so this ordering is what lets Tab fall through to neotab's
-- tabout when blink has no completion/snippet action to take.
require("neotab").setup({})
