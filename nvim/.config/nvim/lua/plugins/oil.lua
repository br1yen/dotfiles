vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
  default_file_explorer = true,
  view_options = { show_hidden = true },
  skip_confirm_for_simple_edits = true,
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
