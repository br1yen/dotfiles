vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})

require('telescope').setup({
  defaults = {
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>fd', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fn', function()
  builtin.find_files {
    cwd = vim.fn.stdpath("config")
  }
end, { desc = 'Find nvim config files' })
vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fm', builtin.man_pages, { desc = 'Man pages' })
