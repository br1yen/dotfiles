return {
  'stevearc/conform.nvim',
  config = function()
    require('conform').setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        html = { 'prettier' },
        css = { 'prettier' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
    vim.keymap.set({'n', 'x'}, '<leader>fm', function()
      require('conform').format({ async = true, lsp_fallback = true })
    end, { desc = 'Format file or selection' })
  end,
}
