vim.opt_local.wrap = true
vim.opt_local.linebreak = true

local headings = require("markdown_headings")
local opts = { buffer = true, silent = true }

local tags = require("markdown_tags")
tags.setup()
tags.attach()

----------------------------------------------------------------------
-- due/do date highlighting
----------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace('todo_dates')

local function define_hl()
  local set = function(n, o) vim.api.nvim_set_hl(0, n, o) end
  set('DueOverdue', { fg = '#ffffff', bg = '#e06c75', bold = true })
  set('DueSoon1',   { fg = '#e06c75', bold = true })  -- today / tomorrow
  set('DueSoon3',   { fg = '#d19a66', bold = true })  -- within 3 days
  set('DueWeek',    { fg = '#e5c07b' })               -- within a week
  set('DueLater',   { fg = '#98c379' })               -- further out
  set('DoOverdue',  { fg = '#c678dd', bold = true })  -- should have started
  set('DoToday',    { fg = '#61afef', bold = true })  -- start today
  set('DoTomorrow', { fg = '#56b6c2', bold = true })  -- start tomorrow
  set('DoSoon',     { fg = '#6a9fd0' })               -- within 3 days
  set('DoLater',    { fg = '#5c6370' })               -- not yet
end
define_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('todo_dates_hl', { clear = true }),
  callback = define_hl,
})

local function days_until(y, m, d)
  local n = os.date('*t')
  local a = os.time { year = n.year, month = n.month, day = n.day, hour = 12 }
  local b = os.time { year = y, month = m, day = d, hour = 12 }
  return math.floor((b - a) / 86400 + 0.5)
end

local function due_group(n)
  if n < 0 then return 'DueOverdue'
  elseif n <= 1 then return 'DueSoon1'
  elseif n <= 3 then return 'DueSoon3'
  elseif n <= 7 then return 'DueWeek'
  else return 'DueLater' end
end

local function do_group(n)
  if n < 0 then return 'DoOverdue'
  elseif n == 0 then return 'DoToday'
  elseif n == 1 then return 'DoTomorrow'
  elseif n <= 3 then return 'DoSoon'
  else return 'DoLater' end
end

local function paint(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    for _, kind in ipairs { 'due', 'do' } do
      local s, e, y, m, d = line:find('%f[%w]' .. kind .. ':(%d%d%d%d)-(%d%d)-(%d%d)')
      if s then
        local n = days_until(tonumber(y), tonumber(m), tonumber(d))
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, {
          end_col = e,
          hl_group = (kind == 'due' and due_group or do_group)(n),
        })
      end
    end
  end
end

local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd(
  { 'BufEnter', 'FocusGained', 'TextChanged', 'TextChangedI', 'InsertLeave' },
  {
    group = vim.api.nvim_create_augroup('todo_dates_' .. buf, { clear = true }),
    buffer = buf,
    callback = function() paint(buf) end,
  }
)
paint(buf)

----------------------------------------------------------------------
-- smarter go to file
----------------------------------------------------------------------
vim.keymap.set("n", "gf", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  for s, target, e in line:gmatch("()%[.-%]%((.-)%)()") do
    if col >= s and col < e then
      local file = target:gsub("#.*$", ""):gsub("%%20", " ")

      -- external URLs go to the browser
      if file:match("^https?://") then
        vim.ui.open(file)
        return
      end

      file = file:gsub("^file://", "")
      file = vim.fn.expand(file)
      local full
      if file:sub(1, 1) == "/" then
        full = file
      else
        full = vim.fn.expand("%:p:h") .. "/" .. file
      end
      full = vim.fn.fnamemodify(full, ":p")

      if vim.fn.filereadable(full) == 0 and vim.fn.filereadable(full .. ".md") == 1 then
        full = full .. ".md"
      end
      vim.cmd.edit(vim.fn.fnameescape(full))
      return
    end
  end
  vim.cmd("normal! gf")
end, { buffer = true, desc = "Follow markdown link" })

----------------------------------------------------------------------
-- :Due <weekday> sets the line's due date to the next such day
----------------------------------------------------------------------
local days = { sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6 }

-- "tod", "tom", "+N", or a weekday name -> "YYYY-MM-DD" (nil if unrecognized)
local function resolve(arg)
  arg = arg:lower()
  local now = os.date('*t')
  local off
  if arg == 'tod' or arg == 'today' then
    off = 0
  elseif arg == 'tom' or arg == 'tomorrow' then
    off = 1
  elseif arg:match('^%+%d+$') then
    off = tonumber(arg:sub(2))
  else
    local want = days[arg:sub(1, 3)]
    if not want then return nil end
    off = (want - (now.wday - 1)) % 7
    if off == 0 then off = 7 end
  end
  now.day = now.day + off
  now.hour = 12
  return os.date('%Y-%m-%d', os.time(now))
end

local function set_date(key, arg)
  local d = resolve(arg)
  if not d then
    vim.notify(key .. ': use tod, tom, +N, or mon..sun', vim.log.levels.ERROR)
    return
  end
  local line = vim.api.nvim_get_current_line():gsub('%s*%f[%w]' .. key .. ':%S+', '')
  vim.api.nvim_set_current_line(line .. ' ' .. key .. ':' .. d)
end

vim.api.nvim_buf_create_user_command(0, 'Due', function(o) set_date('due', o.args) end, { nargs = 1 })
vim.api.nvim_buf_create_user_command(0, 'Do',  function(o) set_date('do',  o.args) end, { nargs = 1 })

-- typing due:tom / do:+2 / due:fri expands to a real date when you leave insert mode
vim.api.nvim_create_autocmd('InsertLeave', {
  group = vim.api.nvim_create_augroup('todo_expand_' .. buf, { clear = true }),
  buffer = buf,
  callback = function()
    local line = vim.api.nvim_get_current_line()
    local new = line
    for _, key in ipairs { 'due', 'do' } do
      new = new:gsub('%f[%w]' .. key .. ':(%S+)', function(arg)
        local d = resolve(arg)
        if d then return key .. ':' .. d end
      end)
    end
    if new ~= line then
      vim.api.nvim_set_current_line(new)
      paint(buf)
    end
  end,
})

-- insert-mode abbreviation: ddd -> today's date
vim.cmd([[iabbrev <buffer> <expr> ddd strftime('%F')]])

----------------------------------------------------------------------
-- key maps / binds
----------------------------------------------------------------------
vim.keymap.set("n", ">>", function() headings.change(1, ">>") end,
  vim.tbl_extend("force", opts, { desc = "Demote heading" }))
vim.keymap.set("n", "<<", function() headings.change(-1, "<<") end,
  vim.tbl_extend("force", opts, { desc = "Promote heading" }))
vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>",
  vim.tbl_extend("force", opts, { desc = "Paste image from clipboard" }))
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true })
vim.keymap.set('x', 'gs', ':sort /.*due:/<CR>',
  vim.tbl_extend('force', opts, { desc = 'Sort by due date' }))
vim.keymap.set('n', 'gs', 'vip:sort /.*due:/<CR>',
  vim.tbl_extend('force', opts, { desc = 'Sort paragraph by due date' }))
