vim.opt_local.formatoptions = "tcqjn"
vim.opt_local.textwidth = 80
vim.opt_local.formatlistpat = [[^\s*\%(\d\+\.\|[-+/]\)\s\+]]

local function compile()
  vim.cmd("silent update")
  local file = vim.fn.expand("%:p")
  vim.system(
    { "typst", "compile", file },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        vim.notify(res.stderr, vim.log.levels.ERROR)
      else
        vim.notify("Compiled " .. vim.fn.fnamemodify(file, ":t"))
      end
    end)
  )
end
vim.keymap.set("n", "<leader>c", compile, { buffer = true, desc = "Compile to PDF" })

vim.keymap.set("n", "<leader>o", function()
  vim.system({ "zathura", vim.fn.expand("%:p:r") .. ".pdf" }, { detach = true })
end, { buffer = true, desc = "Open in Zathura" })
