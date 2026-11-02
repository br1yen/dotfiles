--- Options
vim.loader.enable() -- faster startup by caching compile Lua modules

vim.g.mapleader = " "

vim.opt.mouse = "a"
vim.o.termguicolors = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.laststatus = 3
vim.o.showmode = false
vim.o.cursorline = false
vim.o.winborder = "none"

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.wrap = false
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.linebreak = true
vim.o.showbreak = "↪ "
vim.o.colorcolumn = "80"

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.undofile = true
vim.o.swapfile = false

vim.o.updatetime = 250

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.scrolloff = 999
vim.o.sidescrolloff = 10
vim.o.smoothscroll = true
vim.o.confirm = true
vim.o.completeopt = "menuone,noinsert,noselect,fuzzy"
vim.o.pumheight = 10

vim.opt.path:append("**")

vim.opt.guicursor:remove({ "t:block-blinkon500-blinkoff500-TermCursor" })

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    vim.o.clipboard = "unnamedplus"
  end,
})

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

--- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.hl_op()
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

  local choice = vim.fn.confirm("Remove unused plugins?\n" .. table.concat(unused_plugins, "\n"), "&Yes\n&No", 2)
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
vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

require("mason").setup()

require("mason-tool-installer").setup({
  ensure_installed = {
    -- LSP servers
    "lua-language-server",
    "jdtls",
    "tinymist",
    -- formatters
    "stylua",
    "google-java-format",
    "typstyle",
    "prettier",
    -- debug
    "java-debug-adapter",
  },
})
--- LSP
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})
vim.lsp.enable({ "lua_ls" })

-- Java
vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

-- Typst
vim.lsp.config("tinymist", {
  settings = {
    formatterMode = "typstyle",
    -- formatterPrintWidth = 80,
    formatterProseWrap = true,
  },
})
vim.lsp.enable({ "tinymist" })

-- Configuration
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

--- Completion
vim.pack.add({ "https://github.com/nvim-mini/mini.completion" })
require("mini.completion").setup({})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function(args)
    vim.b[args.buf].minicompletion_disable = true
  end,
})

--- Treesitter
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })
local parsers = { "lua", "typst", "java", "query" }
require("nvim-treesitter").install(parsers)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "java", "typst" },
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldenable = false

--- Autoformat
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    java = { "google-java-format" },
    typst = { "typstyle" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

--- Fzf-lua
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("fzf-lua").setup({
  winopts = { border = "none", fullscreen = true },
})

--- Oil
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = { show_hidden = true },
})

--- Leap
vim.pack.add({ "https://codeberg.org/andyg/leap.nvim.git" })

--- Notes
require("notes")

--- Commands
vim.api.nvim_create_user_command("Termnew", function()
  vim.cmd.tabnew()
  vim.cmd.term()
end)
vim.cmd.cabbrev("termnew", "Termnew")

--- Keybinds / keymaps
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open file explorer" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove highlights" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>pc", pack_clean, { desc = "Pack: clean unused" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.setqflist, { desc = "Diagnostics (quickfix)" })
vim.keymap.set("n", "gbb", require("dap").toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "gbc", require("dap").continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "gbn", require("dap").step_over, { desc = "Debug: Step over" })
vim.keymap.set("n", "gbi", require("dap").step_into, { desc = "Debug: Step into" })
vim.keymap.set("n", "gbo", require("dap").step_out, { desc = "Debug: Step out" })
vim.keymap.set("n", "gbt", require("dap").terminate, { desc = "Debug: Terminate" })
vim.keymap.set("n", "<leader>br", require("dap").repl.open, { desc = "Debug: Open REPL" })
vim.keymap.set("n", "<leader>bl", require("dap").run_last, { desc = "Debug: Run last configuration" })
vim.keymap.set("n", "<leader>bv", "<cmd>DapViewToggle<CR>", { desc = "Debug: Toggle view" })
vim.keymap.set("n", "<leader>f", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>g", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>l", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>h", "<cmd>FzfLua helptags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>r", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>s", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Document symbols" })
vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")
vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap)")
vim.keymap.set("n", "gS", "<Plug>(leap-from-window)")
