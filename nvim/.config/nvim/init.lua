vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.signcolumn = "no"
vim.o.wrap = false
vim.o.scrolloff = 20
vim.o.sidescrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.swapfile = false
vim.o.confirm = true
vim.o.showmode = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.winborder = "none"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.autoread = true

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

-- Better auto read
local group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" },
  {
    group = group,
    callback = function()
      if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
        vim.cmd("silent! checktime")
      end
    end,
  }
)
-- Keep a global reference so the timer isn't garbage collected
_G.autoread_timer = _G.autoread_timer or (vim.uv or vim.loop).new_timer()
_G.autoread_timer:stop()
_G.autoread_timer:start(
  1000,
  1000,
  vim.schedule_wrap(function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end)
)
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("Buffer reloaded: file changed on disk", vim.log.levels.INFO)
  end,
})

-- MdMath build hook
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'mdmath.nvim' and (kind == 'install' or kind == 'update') then
      -- The plugin may not be loaded yet during install, so load it first
      vim.cmd.packadd('mdmath.nvim')
      vim.cmd('MdMath build')
    end
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
    'https://github.com/HakonHarnes/img-clip.nvim',
    'https://github.com/3rd/image.nvim',
    'https://github.com/Thiago4532/mdmath.nvim',
    'https://github.com/nvim-mini/mini.icons',
})

-- Icons
require("mini.icons").setup()

-- Yazi
require("yazi").setup({
    open_for_directories = true,
    floating_window_scaling_factor = 0.80,
    yazi_floating_window_border = "single",
})
vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", {
    desc = "Open Yazi",
})

-- Colors
vim.o.termguicolors = true
vim.cmd.colorscheme("default")
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "NONE" })

-- Surround
require("mini.surround").setup()

-- Autopairs
require("nvim-autopairs").setup()

-- Fzf
local fzf = require("fzf-lua")

fzf.setup({
    defaults = {
        formatter = "path.filename_first",
        git_icons = false,
    },

    fzf_colors = true,

    winopts = {
        border = "single",
        backdrop = 100,
        preview = {
            border = "single",
            layout = "flex",
            flip_columns = 140,
            vertical = "down:50%",
            horizontal = "right:55%",
            scrollbar = false,
            title = false,
        },

    },

    fzf_opts = {
        ["--info"] = "inline-right",  -- match count on the prompt line
        ["--no-scrollbar"] = true,
        ["--ellipsis"] = "…",
    },

    files = {
        cmd = "fd --type f --follow --exclude '.*' " ..
            "--exclude '*.png' --exclude '*.jpg' --exclude '*.jpeg' " ..
            "--exclude '*.gif' --exclude '*.webp' " ..
            "--exclude 'paru' --exclude 'sync/documents'",
    },

    grep = {
        formatter = "path.filename_first",
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
require('nvim-treesitter').install {
    'markdown',
    'markdown_inline',
    'yaml',
    'html',
    'typst',
    'lua',
    'java',
    'c'
}
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua", "java", "markdown", "typst", "c" },
    callback = function()
        if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
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

-- Set Blink capabilities for LSPs
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

-- Lua LSP
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = { vim.env.VIMRUNTIME },
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
vim.api.nvim_create_user_command("Notes", function()
    vim.cmd("edit ~/sync/notes")
end, {})

vim.api.nvim_create_user_command("NewNote", function(opts)
    local title = vim.trim(opts.args)
    local slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
    if slug == "" then slug = "untitled" end

    local dir = vim.fn.expand("~/sync/notes")
    vim.fn.mkdir(dir, "p")

    local path = dir .. "/" .. os.date("%Y-%m-%d") .. "-" .. slug .. ".md"
    local is_new = vim.fn.filereadable(path) == 0

    vim.cmd("edit " .. vim.fn.fnameescape(path))

    if is_new then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            "---",
            "tags: []",
            "---",
            "# " .. (title ~= "" and title or "untitled"),
            ""
        })
        vim.api.nvim_win_set_cursor(0, { 5, 0 })
    end
end, { nargs = "*" })

local function notes_live(prompt, make_pattern)
  local fzf = require("fzf-lua")

  fzf.fzf_live(function(args)
    local q = args[1] or ""

    return table.concat({
      "rg --column --line-number --no-heading --color=always --smart-case --pcre2",
      "-g '*.md' -e", vim.fn.shellescape(make_pattern(q)),
    }, " ")
  end, {
    prompt = prompt,
    cwd = vim.fn.expand("~/sync/notes"),
    previewer = "builtin",
    actions = fzf.defaults.actions.files,
    fn_transform = function(x)
      return fzf.make_entry.file(x, {
        file_icons = true,
        color_icons = true,
      })
    end,
  })
end

-- Content only:
--   * excludes `tags:` lines
--   * doesn't match when the query begins immediately after `#`
vim.keymap.set("n", "<leader>ng", function()
  notes_live("Notes> ", function(q)
    return "^(?!tags:).*?(?<!#)(" .. q .. ")"
  end)
end, { desc = "Grep note content" })

-- Tags only:
--   * inline #tag
--   * `tags:` lines
vim.keymap.set("n", "<leader>nt", function()
  notes_live("Tags> ", function(q)
    return "(?<![\\w])#[\\w/-]*(" .. q .. ")|^tags:.*(" .. q .. ")"
  end)
end, { desc = "Grep tags" })

vim.keymap.set("n", "<leader>t", "<cmd>e ~/sync/notes/todo.md<cr>")
vim.keymap.set("n", "<leader>nf", "<cmd>FzfLua files cwd=~/sync/notes<cr>")
vim.keymap.set("n", "<leader>nn", function()
    vim.ui.input({ prompt = "Note: " }, function(title)
        if title and title ~= "" then
            vim.cmd("NewNote " .. title)
        end
    end)
end, { desc = "New note" })

-- Render markdown to be pretty
require("render-markdown").setup({
    heading = {
        sign = false,
        position = "inline",
        icons = { "H1 ", "H2 ", "H3 ", "H4 ", "H5 ", "H6 " },
        width = "block",
        left_margin = { 0, 1, 2, 3, 4, 5 },
        backgrounds = { "Normal", "Normal", "Normal", "Normal", "Normal", "Normal" },
    },

    code = {
        sign = false,
        style = "language",
        language_icon = false,
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
        icons = { "•", "‣", "◦", "⁃" },
    },

    quote = {
        icon = "│",
    },

    latex = { enabled = false },

    pipe_table = {
        preset = "none",
    },
})


-- Images in notes
require("img-clip").setup({
    default = {
        dir_path = "images",
        relative_to_current_file = true,
        use_absolute_path = false,
        prompt_for_file_name = false,
        insert_mode_after_paste = false,
        file_name = function()
            return os.date("%Y-%m-%d-%H-%M-%S")
        end,
    },
})

require("image").setup({
    backend = "kitty",
    processor = "magick_cli",

    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            only_render_image_at_cursor_mode = "inline",
            floating_windows = false,
        },
    },
    window_overlap_clear_enabled = true,
})

-- MdMath rendering
require('mdmath').setup({
    filetypes = { 'markdown' },
    -- foreground = 'Normal',
    -- dynamic = true,
    -- update_interval = 400,
})
