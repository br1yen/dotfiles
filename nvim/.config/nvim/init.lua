vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 20
vim.opt.sidescrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.confirm = true
vim.opt.showmode = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.winborder = 'none'

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set({ "n", "x" }, "gl", "$")
vim.keymap.set({ "n", "x" }, "gh", "0")
vim.keymap.set({ "n", "x" }, "gs", "^")
vim.keymap.set({ "n", "x" }, "<C-f>", ":<C-f>")

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Packages
vim.pack.add({
    'https://github.com/nvim-mini/mini.surround',
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/neovim/nvim-lspconfig',
    { src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("^1") },
    'https://github.com/mfussenegger/nvim-jdtls',
    'https://github.com/chomosuke/typst-preview.nvim',
    'https://github.com/mikavilpas/yazi.nvim',
    'https://github.com/windwp/nvim-autopairs',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
})

-- Yazi
require("yazi").setup({
    open_for_directories = true,
    floating_window_scaling_factor = 0.75,
    yazi_floating_window_border = "none",
})
vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", {
    desc = "Open Yazi",
})

-- Colors
vim.o.termguicolors = true
vim.cmd.colorscheme("default")

-- Surround
require('mini.surround').setup()

-- Autopairs
require("nvim-autopairs").setup()

-- Fzf
local fzf = require("fzf-lua")

fzf.setup({
    winopts = {
        border = "single",
        backdrop = 100,
        preview = {
            border = "single",
        },

    },

    files = {
        cmd = "fd --type f --follow --exclude '.*' " ..
            "--exclude '*.png' --exclude '*.jpg' --exclude '*.jpeg' " ..
            "--exclude '*.gif' --exclude '*.webp' " ..
            "--exclude 'paru' --exclude 'sync/documents'",
    },

    grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case " ..
            "--glob '!.*' --glob '!.*/*' " ..
            "--glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' " ..
            "--glob '!*.gif' --glob '!*.webp' " ..
            "--glob '!**/paru/**' --glob '!**/sync/documents/**'",
    },
})

vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>g", fzf.live_grep)
vim.keymap.set("n", "<leader>r", fzf.history)
vim.keymap.set("n", "<leader>b", fzf.buffers)
vim.keymap.set("n", "<leader>h", fzf.help_tags)
vim.keymap.set("n", "<leader>F", function()
    fzf.files({
        cmd = "fd --type f --hidden --follow",
    })
end)
vim.keymap.set("n", "<leader>G", function()
    fzf.live_grep({
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden",
    })
end)

-- Treesitter
require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})
require('nvim-treesitter').install { 'markdown', 'typst', 'lua', 'java' }
vim.api.nvim_create_autocmd("FileType", {
    pattern = { 'lua', 'java', 'markdown', 'typst' },
    callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- Blink completion
require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },

    appearance = {
        nerd_font_variant = "mono",
    },

    completion = {
        trigger = {
            show_on_keyword = true,
            show_on_trigger_character = true,
        },

        list = {
            selection = { auto_insert = false },
        },

        documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
        },

        menu = {
            draw = {
                components = {
                    kind_icon = {
                        text = function(ctx)
                            return "[" .. ctx.kind .. "]"
                        end,

                        highlight = "BlinkCmpKind",
                    },
                },
            },
        },
    },

    signature = { enabled = true },

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        implementation = "prefer_rust_with_warning",
    },
})

-- Set Blink capabilities or LSPs
vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Typst
vim.lsp.config("tinymist", {
    settings = {
        formatterMode = "typstyle", -- lets you gq / format-on-save with typstyle
        exportPdf = "onType",       -- keeps a .pdf next to your .typ, updated as you type
    },
})
vim.lsp.enable("tinymist")
require("typst-preview").setup({})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})

-- Lua LSP
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
})
vim.lsp.enable("lua_ls")

-- LSP navigation via fzf-lua
vim.keymap.set("n", "gd", fzf.lsp_definitions)
vim.keymap.set("n", "grr", fzf.lsp_references)
vim.keymap.set("n", "<leader>s", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>S", fzf.lsp_live_workspace_symbols)
vim.keymap.set("n", "<leader>d", fzf.diagnostics_document)

-- Notes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
vim.api.nvim_create_user_command("Notes", function()
  vim.cmd("edit ~/sync/notes")
end, {})

vim.api.nvim_create_user_command("NewNote", function(opts)
  local title = opts.args
  if title == "" then
    title = "untitled"
  end

  title = title:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()

  local date = os.date("%Y-%m-%d")
  local path = vim.fn.expand("~/sync/notes/" .. date .. "-" .. title .. ".md")

  vim.cmd("edit " .. vim.fn.fnameescape(path))

  if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "# " .. title:gsub("-", " "),
      "",
    })
  end
end, { nargs = "*" })

vim.keymap.set("n", "<leader>t", "<cmd>e ~/sync/notes/todo.md<cr>")
vim.keymap.set("n", "<leader>nf", "<cmd>FzfLua files cwd=~/sync/notes<cr>")
vim.keymap.set("n", "<leader>ng", "<cmd>FzfLua live_grep cwd=~/sync/notes<cr>")
vim.keymap.set("n", "<leader>nn", function()
  vim.ui.input({ prompt = "Note: " }, function(title)
    if title and title ~= "" then
      vim.cmd("NewNote " .. title)
    end
  end)
end, { desc = "New note" })

-- Render markdown pretty
require("render-markdown").setup({
  heading = {
    enabled = true,
    sign = false,
    position = "inline",

    icons = {
      "H1 ",
      "H2 ",
      "H3 ",
      "H4 ",
      "H5 ",
      "H6 ",
    },

    width = "block",
    left_margin = { 0, 1, 2, 3, 4, 5 },
    left_pad = 0,
    right_pad = 0,

    backgrounds = {
      "Normal",
      "Normal",
      "Normal",
      "Normal",
      "Normal",
      "Normal",
    },

    border = false,
  },

  code = {
    enabled = true,
    sign = false,

    style = "language",

    language = true,
    language_icon = false,
    language_name = true,
    language_info = false,

    disable_background = true,

    left_margin = 4,
    left_pad = 1,
    right_pad = 1,

    border = "none",
    highlight_border = false,

    highlight_language = "Normal",
    highlight_info = "Normal",
    highlight_fallback = "Normal",
  },

  bullet = {
    enabled = true,
    icons = { "•", "◦", "▪", "▫" },
    left_pad = 0,
    right_pad = 0,
  },

  quote = {
    icon = "│",
    repeat_linebreak = false,
  },

  checkbox = {
    enabled = true,
  },

  pipe_table = {
    enabled = true,
    preset = "round",
  },

  link = {
    enabled = true,
  },

  anti_conceal = {
    enabled = true,
  },
})
