vim.opt_local.textwidth = 80
vim.opt_local.autoindent = true
vim.opt_local.formatoptions = "tcqjn"
vim.opt_local.formatlistpat = [==[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\s\%(\[.\]\s\)\?\)\s*]==]
vim.opt_local.comments = ""
vim.keymap.set("n", "<leader>=", function()
  vim.cmd("normal! mz")
  vim.cmd("normal! gggqG")
  vim.cmd("normal! `z")
end, { buffer = true, desc = "Reflow whole buffer" })
