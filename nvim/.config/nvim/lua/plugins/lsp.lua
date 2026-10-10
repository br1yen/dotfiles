vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),

  callback = function(event)
    local builtin = require("telescope.builtin")
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, {
        buffer = event.buf,
        desc = "LSP: " .. desc,
      })
    end

    map("grd", builtin.lsp_definitions, "Definition")
    map("grr", builtin.lsp_references, "References")
    map("gri", builtin.lsp_implementations, "Implementations")
    map("grt", builtin.lsp_type_definitions, "Type definition")
    map("grD", vim.lsp.buf.declaration, "Declaration")
    map("<leader>o", builtin.lsp_document_symbols, "Symbols (document)")
    map("<leader>s", builtin.lsp_dynamic_workspace_symbols, "Symbols (workspace)")
    map("<leader>dd", function() builtin.diagnostics({ bufnr = 0 }) end, "Diagnostics (buffer)")
    map("<leader>dw", builtin.diagnostics, "Diagnostics (workspace)")
  end,
})

---@type table<string, vim.lsp.Config>
local servers = {
  tinymist = {
    settings = {
      exportPdf = "onType",
    },
  },

  lua_ls = { -- recommended lua language server config
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
        runtime = {
          version = "LuaJIT",
          path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file("", true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim', 
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
})

require("mason").setup({})
require("mason-lspconfig").setup({ automatic_enable = false })

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  "jdtls",
  "java-debug-adapter",
})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

---@type table<string, vim.lsp.Config>
local servers = {
  tinymist = {
    settings = {
      exportPdf = "onType",
    },
  },

  lua_ls = { -- recommended lua language server config
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
        runtime = {
          version = "LuaJIT",
          path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file("", true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim', 
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
})

require("mason").setup({})
require("mason-lspconfig").setup({ automatic_enable = false })

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  "jdtls",
  "java-debug-adapter",
})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
