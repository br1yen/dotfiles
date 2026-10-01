vim.opt_local.wrap = true
vim.opt_local.linebreak = true

local headings = require("markdown_headings")
local opts = { buffer = true, silent = true }

vim.keymap.set("n", ">>", function() headings.change(1, ">>") end,
    vim.tbl_extend("force", opts, { desc = "Demote heading" }))
vim.keymap.set("n", "<<", function() headings.change(-1, "<<") end,
    vim.tbl_extend("force", opts, { desc = "Promote heading" }))
vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>",
    vim.tbl_extend("force", opts, { desc = "Paste image from clipboard" }))
