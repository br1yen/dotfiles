return {
  'neovim/nvim-lspconfig',
  dependencies = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  config = function()
    require('mason-lspconfig').setup({
      ensure_installed = { 'lua_ls', 'pyright', 'html', 'cssls' },
      automatic_installation = true,
    })
    vim.lsp.config('lua_ls', {})
    vim.lsp.config('pyright', {})
    vim.lsp.config('html', {})
    vim.lsp.config('cssls', {})
  end,
}
