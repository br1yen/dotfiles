-- General
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.winborder = "rounded"
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = false
vim.opt.splitkeep = "screen"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.confirm = true
vim.opt.hidden = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.updatetime = 250
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.laststatus = 3
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

local jump_keys = { "*", "#", "{", "}", 
"<C-d>", "<C-u>", 
"<C-o>", "<C-i>",
"<C-f>", "<C-b>", "G" }

for _, key in ipairs(jump_keys) do
    vim.keymap.set("n", key, key .. "zz", { desc = key .. " (centered)" })
end

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Netrw
-- vim.g.netrw_sort_by = "name"
-- vim.g.netrw_sort_direction = "normal"
-- vim.g.netrw_sort_sequence = "[\\/]$,*"
-- vim.g.netrw_list_hide = [[^\.\.\=/\=$]]
-- vim.g.netrw_hide = 1
--
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "netrw",
--     callback = function()
--         local opts = { buffer = true, remap = true, silent = true }
--         vim.g.netrw_bufsettings = "noma nomod nu rnu nobl nowrap ro"
--         vim.keymap.set("n", "h", "-", opts)
--         vim.keymap.set("n", "l", "<CR>", opts)
--         vim.keymap.set("n", "f", "%", opts)
--     end,
-- })
--
-- vim.keymap.set("n", "<leader>e", function()
--     vim.cmd("Explore " .. vim.fn.expand("%:p:h"))
-- end, {
-- desc = "Open Netrw in current file directory",
-- })

-- Packages
vim.pack.add({
    'https://github.com/kylechui/nvim-surround',
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/neovim/nvim-lspconfig',
    { src = "https://github.com/saghen/blink.cmp", 
    version = vim.version.range("^1") },
    'https://github.com/mfussenegger/nvim-jdtls',
    'https://github.com/chomosuke/typst-preview.nvim',
    'https://github.com/vague-theme/vague.nvim',
    'https://github.com/savq/melange-nvim',
    'https://github.com/mikavilpas/yazi.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
})

-- Yazi
require("yazi").setup({
  open_for_directories = true,
})

vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", {
  desc = "Open Yazi",
})

-- Colors
vim.cmd.colorscheme("melange")

local hl = vim.api.nvim_set_hl

hl(0, "Normal", {
    bg = "#000000",
})

hl(0, "NormalNC", {
    bg = "#000000",
})

hl(0, "NormalFloat", {
    bg = "#000000",
})

hl(0, "SignColumn", {
    bg = "#000000",
})

hl(0, "EndOfBuffer", {
    bg = "#000000",
})

-- Surround
require('nvim-surround').setup()

-- Fzf
local fzf = require("fzf-lua")
fzf.setup({
  files = {
    cmd = "fd --type f --follow --exclude '.*' " ..
          "--exclude '*.png' --exclude '*.jpg' --exclude '*.jpeg' --exclude '*.gif' --exclude '*.webp' " ..
          "--exclude 'paru' --exclude 'sync/documents'"
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case " ..
              "--glob '!.*' --glob '!.*/*' " ..
              "--glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' --glob '!*.gif' --glob '!*.webp' " ..
              "--glob '!**/paru/**' --glob '!**/sync/documents/**'"
  }
})
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>g", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>r", fzf.history, { desc = "Recent files" })
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Help" })
vim.keymap.set('n', '<leader>F', function()
    fzf.files({
        cmd = "fd --type f --hidden --follow" 
    })
end, { desc = 'Find Files (Include Dotfiles & System)' })

vim.keymap.set('n', '<leader>G', function()
    fzf.live_grep({
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden"
    })
end, { desc = 'Live Grep (Include Dotfiles & System)' })

-- Treesitter
require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})
require('nvim-treesitter').install { 'markdown', 'typst', 'lua', 'java' }
vim.api.nvim_create_autocmd("FileType", {
    pattern = { 'lua', 'java', 'markdown', 'typst' },
    callback = function() vim.treesitter.start() end,
})


vim.api.nvim_set_hl(0, "BlinkCmpKind", {
    fg = "#ffffff",
    bg = "#000000",
})
vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#000000" })
vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#222222" })
vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#000000" })

require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },

    appearance = {
        nerd_font_variant = "mono",
    },

    completion = {
        trigger = {
            show_on_keyword = false,
            show_on_trigger_character = false,
        },

        documentation = {
            auto_show = true,
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

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        implementation = "prefer_rust_with_warning",
    },
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

-- Notes
vim.keymap.set("n", "<leader>nf", "<cmd>FzfLua files cwd=~/sync/notes<cr>")
vim.keymap.set("n", "<leader>ng", "<cmd>FzfLua live_grep cwd=~/sync/notes<cr>")
