-- Options
-- faster startup by caching compile Lua modules
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.mouse = "a"

vim.opt.termguicolors = true
vim.g.have_nerd_font = true
vim.opt.winborder = "none"
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.colorcolumn = "0"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.smartindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.updatetime = 250

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999
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

    if name == "telescope-fzf-native.nvim" then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
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
    "marksman",
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
    formatterPrintWidth = 80,
    formatterProseWrap = true,
  },
})
vim.lsp.enable({ "tinymist" })

-- Markdown
vim.lsp.enable({ "marksman" })

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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
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

--- Telescope
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})

require("telescope").setup({
  defaults = {
    layout_strategy = "flex",
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
      width = { padding = 0 },
      height = { padding = 0 },
    },
  },
})
pcall(require("telescope").load_extension, "fzf")

--- Org
vim.pack.add({ "https://github.com/nvim-orgmode/orgmode" })
require("orgmode").setup({
  org_agenda_files = "~/sync/org/**/*",
  org_default_notes_file = "~/sync/org/inbox.org",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  callback = function()
    vim.schedule(function()
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevel = 0
    end)
  end,
})
vim.lsp.enable("org")

--- Oil
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = { show_hidden = true },
})

--- Keybinds / keymaps
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>;", "q/", { desc = "Command line window" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove highlights" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
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
vim.keymap.set("n", "<leader>f", require("telescope.builtin").find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>g", require("telescope.builtin").live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>l", require("telescope.builtin").buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>h", require("telescope.builtin").help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>r", require("telescope.builtin").oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>s", require("telescope.builtin").lsp_document_symbols, { desc = "Document symbols" })

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
  require("telescope.builtin").live_grep({ cwd = notes_dir, prompt_title = "Grep Notes" })
end)

vim.keymap.set("n", "<leader>nf", function()
  require("telescope.builtin").find_files({
    cwd = notes_dir,
    prompt_title = "Find Notes",
    attach_mappings = function(prompt_bufnr, map)
      local function new_from_prompt()
        local line = require("telescope.actions.state").get_current_line()
        require("telescope.actions").close(prompt_bufnr)
        vim.schedule(function()
          create_note(line)
        end)
      end
      map({ "i", "n" }, "<C-enter>", new_from_prompt)
      return true
    end,
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
