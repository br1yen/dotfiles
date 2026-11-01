vim.opt_local.formatoptions = "tcqjn"
vim.opt_local.formatlistpat = [==[^\s*\%(\d\+[\]:.)}\t ]\|[-+]\s\)\s*]==]

vim.keymap.set("n", "<leader>c", function()
  local res = vim.system({ "typst", "compile", vim.fn.expand("%:p") }, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify(res.stderr, vim.log.levels.ERROR)
  end
end, { buffer = true, desc = "Compile to PDF" })

vim.keymap.set("n", "<leader>o", function()
  vim.system({ "zathura", vim.fn.expand("%:p:r") .. ".pdf" }, { detach = true })
end, { buffer = true, desc = "Open in Zathura" })
