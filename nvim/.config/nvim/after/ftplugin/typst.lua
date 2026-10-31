vim.opt_local.textwidth = 80
vim.opt_local.formatoptions = "tcqjn"
vim.opt_local.formatlistpat = [==[^\s*\%(\d\+[\]:.)}\t ]\|[-+]\s\)\s*]==]

vim.keymap.set("n", "<leader>w", function()
  vim.cmd("write")
  vim.cmd("normal! mz")
  vim.cmd("normal! gggqG")
  vim.cmd("normal! `z")
  local res = vim.system({ "typst", "compile", vim.fn.expand("%:p") }, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify(res.stderr, vim.log.levels.ERROR)
  end
end, { buffer = true, desc = "Write and compile to PDF" })

vim.keymap.set("n", "<leader>o", function()
  vim.system({ "zathura", vim.fn.expand("%:p:r") .. ".pdf" }, { detach = true })
end, { buffer = true, desc = "Open in Zathura" })
