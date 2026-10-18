--- Options
-- faster startup by caching compile Lua modules
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.mouse = "a"

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.g.have_nerd_font = true
vim.opt.winborder = "none"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.cursorlineopt = "line"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.smartindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 999
vim.opt.smoothscroll = true

vim.opt.confirm = true
vim.opt.completeopt = "menu,fuzzy,menuone,noinsert,popup,preview"
vim.opt.pumheight = 10

vim.opt.path:append("**")

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Colors
vim.pack.add({ "https://github.com/ramojus/mellifluous.nvim" })
require("mellifluous").setup({
  flat_background = {
    line_numbers = true,
    cursor_line_number = true,
  },
  highlight_overrides = {
    dark = function(highlighter, colors)
      highlighter.set("Pmenu", { fg = colors.fg })
      highlighter.set("PmenuKind", { fg = colors.fg })
      highlighter.set("PmenuExtra", { fg = colors.fg })
      highlighter.set("NormalFloat", { fg = colors.fg, bg = colors.bg })
      highlighter.set("FloatBorder", { fg = colors.fg, bg = colors.bg })
    end,
  },
})
vim.cmd.colorscheme("mellifluous")

-- Netrw
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    local opts = { buffer = true, remap = true, silent = true }
    vim.keymap.set("n", "h", "-", opts)
    vim.keymap.set("n", "l", "<CR>", opts)
    vim.keymap.set("n", "f", "%", opts)
  end,
})
vim.g.netrw_banner = 0

--- Nnn
vim.pack.add({ "https://github.com/luukvbaal/nnn.nvim" })
require("nnn").setup({
  explorer = {
    fullscreen = true,
  },
  replace_netrw = "picker",
})

--- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind

    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
      return
    end
  end,
})


--- Local functions
local function pack_clean()
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end

  local choice = vim.fn.confirm(
    "Remove unused plugins?\n" .. table.concat(unused_plugins, "\n"),
    "&Yes\n&No",
    2
  )
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end

local group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  desc = "Update buffer when file changes",
  group = group,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("Buffer reloaded: file changed on disk", vim.log.levels.INFO)
  end,
})


-- Debug
vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  {
    src = "https://github.com/igorlfs/nvim-dap-view",
    version = vim.version.range("1.*"),
  },
  "https://github.com/theHamsta/nvim-dap-virtual-text",
})
require("dap-view").setup()
require("nvim-dap-virtual-text").setup({
  commented = true,
  highlight_changed_variables = true,
})


-- Mason
vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("mason").setup()

--- LSP
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
vim.lsp.enable({ 'lua_ls' })

-- Java
vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

-- Typst
vim.lsp.config("tinymist", {
  settings = {
    formatterMode = "typstyle",
  },
})
vim.lsp.enable({ 'tinymist' })

-- Configuration
vim.lsp.inlay_hint.enable()
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  virtual_text = true,
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
        end,
      })
    end
  end,
})


-- Treesitter
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })
local parsers = { "lua", "typst", "java", "query" }
require("nvim-treesitter").install(parsers)
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false


-- Typst
vim.pack.add({ "https://github.com/chomosuke/typst-preview.nvim" })
require("typst-preview").setup({})

-- Paste images
vim.pack.add({ "https://github.com/HakonHarnes/img-clip.nvim" })
require("img-clip").setup({
  default = {
    dir_path = "assets",
    relative_to_current_file = true,
    prompt_for_file_name = false,
  },
  filetypes = {
    typst = {
      template = '#image("$FILE_PATH")',
    },
  },
})

--- Keybinds
for i = 1, 9 do vim.keymap.set("n", "<leader>" .. i, i .. "gt", { desc = "Go to tab number" }) end
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove highlights" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<space>x", ":.lua<CR>", { desc = "Execute line of lua" })
vim.keymap.set("v", "<space>x", ":lua<CR>", { desc = "Execute selection of lua" })
vim.keymap.set("n", "<leader>pc", pack_clean, { desc = "Pack: clean unused" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist, { desc = "Diagnostics (quickfix)" })
vim.keymap.set("n", "-", "<cmd>NnnPicker<CR>", { desc = "Explore current directory" })
vim.keymap.set("n", "gbb", require("dap").toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "gbc", require("dap").continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "gbn", require("dap").step_over, { desc = "Debug: Step over" })
vim.keymap.set("n", "gbi", require("dap").step_into, { desc = "Debug: Step into" })
vim.keymap.set("n", "gbo", require("dap").step_out, { desc = "Debug: Step out" })
vim.keymap.set("n", "gbt", require("dap").terminate, { desc = "Debug: Terminate" })
vim.keymap.set("n", "<leader>dr", require("dap").repl.open, { desc = "Debug: Open REPL" })
vim.keymap.set("n", "<leader>dl", require("dap").run_last, { desc = "Debug: Run last configuration" })
vim.keymap.set("n", "<leader>dv", "<cmd>DapViewToggle<CR>", { desc = "Debug: Toggle view" })
vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })
