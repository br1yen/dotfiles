vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    list = { selection = { auto_insert = false } },
    menu = {
      auto_show = true,
      border = "none",
      scrollbar = false,
      draw = {
        columns = { { "label", "label_description", gap = 1 } },
      },
    },
    documentation = {
      window = {
        border = "none",
        scrollbar = false,
      },
    },
  },
  signature = {
    enabled = true,
    window = {
      border = "none",
      scrollbar = false,
    },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
