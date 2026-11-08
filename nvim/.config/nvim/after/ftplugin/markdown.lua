vim.opt_local.conceallevel = 2
vim.keymap.set("i", "<A-c>", "``<Left>", { buffer = true, desc = "Inline code" })
vim.keymap.set("x", "<A-c>", 'c`<C-r>"`<Esc>', { buffer = true, desc = "Wrap in backticks" })
vim.keymap.set("i", "<A-f>", function()
  vim.snippet.expand("```${1:lang}\n$0\n```")
end, { buffer = true, desc = "Code fence" })
vim.keymap.set("x", "<A-f>", "<Esc>`>o```<Esc>`<O```<Esc>", { buffer = true, desc = "Wrap in fence" })
