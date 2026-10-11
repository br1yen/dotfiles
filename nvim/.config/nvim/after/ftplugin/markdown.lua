if vim.b.notes_refire then
	return
end

vim.opt_local.wrap = true
vim.opt_local.linebreak = true

local buf = vim.api.nvim_get_current_buf()

-- Attach modules
require("notes.tags").setup()
require("notes.tags").attach(buf)
require("notes.todo").setup()
require("notes.todo").attach(buf)

local opts = { buffer = true, silent = true }

-- Date abbreviation
vim.cmd([[iabbrev <buffer> <expr> ddd strftime('%F')]])

-- Keymaps
vim.keymap.set("n", ">>", function()
	headings.change(1, ">>")
end, vim.tbl_extend("force", opts, { desc = "Demote heading" }))
vim.keymap.set("n", "<<", function()
	headings.change(-1, "<<")
end, vim.tbl_extend("force", opts, { desc = "Promote heading" }))
vim.keymap.set(
	"n",
	"<leader>p",
	"<cmd>PasteImage<cr>",
	vim.tbl_extend("force", opts, { desc = "Paste image from clipboard" })
)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true })
vim.keymap.set("x", "<leader>s", ":sort /.*due:/<CR>", vim.tbl_extend("force", opts, { desc = "Sort by due date" }))
vim.keymap.set(
	"n",
	"<leader>s",
	"vip:sort /.*due:/<CR>",
	vim.tbl_extend("force", opts, { desc = "Sort paragraph by due date" })
)
vim.keymap.set(
	"n",
	"gs",
	"vip:sort /.*due:/<CR>",
	vim.tbl_extend("force", opts, { desc = "Sort paragraph by due date" })
)
