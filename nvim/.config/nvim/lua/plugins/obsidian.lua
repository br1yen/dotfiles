vim.pack.add({ "https://github.com/obsidian-nvim/obsidian.nvim" })

require("obsidian").setup({
  workspaces = {
    { name = "notes", path = "~/sync/notes" },
  },
  picker = { name = "telescope.nvim" },
  ui = { enable = false },
  legacy_commands = false,
  notes_subdir = nil,
  daily_notes = { folder = "daily" },
  note_id_func = function(title)
    local slug = ""
    if title ~= nil then
      slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", ""):gsub("%-+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
    end
    if slug == "" then
      slug = "untitled"
    end
    return os.date("%Y-%m-%d") .. "-" .. slug
  end,
})

vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<CR>", { desc = "New note" })
vim.keymap.set("n", "<leader>oo", "<cmd>Obsidian quick_switch<CR>", { desc = "Find note" })
vim.keymap.set("n", "<leader>os", "<cmd>Obsidian search<CR>", { desc = "Grep notes" })
vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian tags<CR>", { desc = "Tags" })
vim.keymap.set("n", "<leader>t", function()
  vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.expand("~/sync/notes/todo.md")))
end, { desc = "Open todo" })
