--- Options
vim.loader.enable() -- faster startup by caching compile Lua modules

vim.g.mapleader = " "

vim.opt.mouse = "a"
vim.o.termguicolors = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.laststatus = 3
vim.o.showmode = false
vim.o.list = true
vim.o.cursorline = true
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
vim.o.completeopt = "menuone,noinsert,fuzzy"
vim.o.pumheight = 10

vim.opt.path:append("**")

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
      highlighter.set("@org.agenda.scheduled", { fg = colors.fg })
      highlighter.set("@org.agenda.scheduled_past", { fg = colors.fg })
      highlighter.set("Folded", { bg = colors.bg })
      highlighter.set("FoldColumn", { bg = colors.bg })
    end,
  },
})
vim.cmd.colorscheme("mellifluous")

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
    formatterPrintWidth = 80,
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
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

--- Treesitter text objects
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
})

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

-- Select
local ts_select = require("nvim-treesitter-textobjects.select")
local function sel(lhs, query)
  vim.keymap.set({ "x", "o" }, lhs, function()
    ts_select.select_textobject(query, "textobjects")
  end)
end
sel("af", "@function.outer")
sel("if", "@function.inner")
sel("ac", "@class.outer")
sel("ic", "@class.inner")
sel("aa", "@parameter.outer")
sel("ia", "@parameter.inner")

-- Move
local move = require("nvim-treesitter-textobjects.move")
local function mv(lhs, fn, query)
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    move[fn](query, "textobjects")
  end)
end
mv("]f", "goto_next_start", "@function.outer")
mv("[f", "goto_previous_start", "@function.outer")
mv("]F", "goto_next_end", "@function.outer")
mv("[F", "goto_previous_end", "@function.outer")

local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<leader>a", function()
  swap.swap_next("@parameter.inner")
end)
vim.keymap.set("n", "<leader>A", function()
  swap.swap_previous("@parameter.inner")
end)

--- Autoformat
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    java = { "google-java-format" },
    typst = { "typstyle" },
    markdown = { "prettier" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

--- Typst
vim.pack.add({ "https://github.com/chomosuke/typst-preview.nvim" })
require("typst-preview").setup({
  dependencies_bin = { tinymist = "tinymist", websocat = "websocat" },
})

--- Fzf-lua
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("fzf-lua").setup({
  winopts = { border = "none", fullscreen = true },
})
require("fzf-lua").register_ui_select()

--- Oil
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = { show_hidden = true },
})

--- Quicker
vim.pack.add({ "https://github.com/stevearc/quicker.nvim" })
require("quicker").setup({})

--- Notes
local notes_dir = vim.fn.expand("~/sync/notes")

local function create_note(title)
  if not title or title:match("^%s*$") then
    return
  end
  vim.fn.mkdir(notes_dir, "p")

  local name = vim.trim(title):lower():gsub("%.txt$", ""):gsub("%s+", "-"):gsub("[/\\]", "")
  local path = ("%s/%s.txt"):format(notes_dir, name)

  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.cmd.startinsert({ bang = true })
end

function _G.TasksQfText(info)
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
  local lines = {}
  for i = info.start_idx, info.end_idx do
    local item = items[i]
    local name = vim.fn.fnamemodify(vim.fn.bufname(item.bufnr), ":t")
    lines[#lines + 1] = name .. "  " .. vim.trim(item.text)
  end
  return lines
end

vim.keymap.set("n", "<leader>nd", "<cmd>e ~/sync/notes/<cr>", { desc = "Notes dir" })
vim.keymap.set("n", "<leader>nt", "<cmd>e ~/sync/notes/gtd/other-tasks.txt<cr>", { desc = "Open tasks" })

vim.keymap.set("n", "<leader>x", function()
  local line = vim.api.nvim_get_current_line()
  local new, n = line:gsub("%- %[ %]", "- [x]", 1)
  if n == 0 then
    new = line:gsub("%- %[x%]", "- [ ]", 1)
  end
  vim.api.nvim_set_current_line(new)
end, { desc = "Toggle task" })

vim.keymap.set("n", "<leader>ng", function()
  require("fzf-lua").live_grep({ cwd = notes_dir, prompt = "Grep Notes> " })
end, { desc = "Grep notes" })

vim.keymap.set("n", "<leader>nf", function()
  require("fzf-lua").files({
    cwd = notes_dir,
    prompt = "Find Notes> ",
    actions = {
      -- create a new note from whatever is typed in the prompt
      ["alt-enter"] = function()
        local query = require("fzf-lua").get_last_query()
        vim.schedule(function()
          create_note(query)
        end)
      end,
    },
  })
end, { desc = "Find notes" })

vim.keymap.set("n", "<leader>nq", function()
  local out = vim.fn.systemlist({ "rg", "--vimgrep", "-F", "--", "- [ ]", notes_dir })
  vim.fn.setqflist({}, " ", {
    title = "Tasks",
    lines = out,
    quickfixtextfunc = "v:lua.TasksQfText",
  })
  vim.cmd("copen")
end, { desc = "Open tasks in quickfix" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(ev)
    vim.keymap.set("n", "x", function()
      if vim.fn.getqflist({ title = 1 }).title ~= "Tasks" then
        return
      end

      local idx = vim.fn.line(".")
      local items = vim.fn.getqflist()
      local item = items[idx]
      if not item or item.bufnr == 0 then
        return
      end

      -- check it off in the source file and save
      vim.fn.bufload(item.bufnr)
      local lnum = item.lnum - 1
      local line = vim.api.nvim_buf_get_lines(item.bufnr, lnum, lnum + 1, false)[1]
      local new = (line:gsub("%[ %]", "[x]", 1))
      vim.api.nvim_buf_set_lines(item.bufnr, lnum, lnum + 1, false, { new })
      vim.api.nvim_buf_call(item.bufnr, function()
        vim.cmd("silent write")
      end)

      -- drop it from the list, keep cursor position
      table.remove(items, idx)
      vim.fn.setqflist({}, "r", { items = items, idx = math.min(idx, #items) })
    end, { buffer = ev.buf, desc = "Check off task" })
  end,
})

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
