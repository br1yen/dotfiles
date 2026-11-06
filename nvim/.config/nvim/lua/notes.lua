local notes_dir = vim.fn.expand("~/Documents/notes")

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
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items or {}
  local lines = {}
  for i = info.start_idx, info.end_idx do
    local item = items[i]
    if item then
      local name = vim.fn.fnamemodify(vim.fn.bufname(item.bufnr), ":t")
      lines[#lines + 1] = name .. "  " .. vim.trim(item.text or "")
    else
      lines[#lines + 1] = ""
    end
  end
  return lines
end

vim.keymap.set("n", "<leader>nd", "<cmd>e " .. notes_dir .. "<cr>", { desc = "Notes dir" })

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

local markers = { "*", "+", "-" }

-- Re-indent bullet line `lnum` by `delta` levels and set the marker for that
-- depth. Returns the change in line length, or nil if it isn't a bullet line.
local function reindent_line(lnum, delta)
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
  local indent, marker, rest = line:match("^(%s*)([*+-])(%s.*)$")
  if not marker then
    return nil
  end
  local sw = vim.fn.shiftwidth()
  local depth = math.max(0, math.floor(#indent / sw) + delta)
  local new = string.rep(" ", depth * sw) .. markers[depth % 3 + 1] .. rest
  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { new })
  return #new - #line
end

-- Insert mode: reindent current line and keep the cursor in place.
local function reindent(delta)
  local lnum = vim.fn.line(".")
  local col = vim.fn.col(".") - 1
  local diff = reindent_line(lnum, delta)
  if not diff then
    return false
  end
  vim.api.nvim_win_set_cursor(0, { lnum, math.max(0, col + diff) })
  return true
end

-- Normal/visual mode: shift a range of lines. Non-bullet lines get the
-- regular >/< behaviour.
local function shift_range(first, last, delta)
  for lnum = first, last do
    if not reindent_line(lnum, delta) then
      vim.cmd(("silent %d%s"):format(lnum, delta > 0 and ">" or "<"))
    end
  end
end

-- operatorfunc targets (must be global for v:lua)
function _G.BulletIndentOp()
  shift_range(vim.fn.line("'["), vim.fn.line("']"), 1)
end
function _G.BulletDedentOp()
  shift_range(vim.fn.line("'["), vim.fn.line("']"), -1)
end

local function op_map(mode, lhs, func, suffix)
  vim.keymap.set(mode, lhs, function()
    vim.o.operatorfunc = "v:lua." .. func
    return "g@" .. suffix
  end, { buffer = true, expr = true, desc = "Shift bullets" })
end

-- Folding: only a top-level "* " starts a fold, everything indented under it
-- (including nested + and - bullets) stays inside.
function _G.BulletFold(lnum)
  local line = vim.fn.getline(lnum)
  if line:match("^%*%s") then
    return ">1" -- top-level bullet starts a fold
  end
  if line:match("^%s*$") or line:match("^%s") then
    return "=" -- blanks and indented lines stay in the current fold
  end
  return 0 -- anything else at column 0 ends the fold
end

-- Last non-blank line of the block under the heading at `lnum`: the heading
-- plus every indented line below it, stopping at the next column-0 line.
local function block_end(lnum)
  local stop = lnum
  for l = lnum + 1, vim.fn.line("$") do
    local text = vim.fn.getline(l)
    if text:match("^%S") then
      break
    end
    if text:match("%S") then
      stop = l
    end
  end
  return stop
end

local function jump_heading(backward)
  vim.fn.setpos("''", vim.fn.getpos(".")) -- so <C-o> returns
  for _ = 1, vim.v.count1 do
    vim.fn.search([[^\*\s]], backward and "bW" or "W")
  end
end

-- Insert a blank line and a fresh "* " heading after the block that starts at
-- heading `lnum`. Returns the new heading's line number.
local function add_heading_below(lnum)
  local stop = block_end(lnum)
  local new = { "", "* " }
  if vim.fn.getline(stop + 1):match("%S") then
    new[#new + 1] = "" -- keep a gap before the heading that follows
  end
  vim.api.nvim_buf_set_lines(0, stop, stop, false, new)
  return stop + 2
end

-- Insert a fresh "* " heading above heading `lnum`, with a blank line between
-- the two. Returns the new heading's line number.
local function add_heading_above(lnum)
  local new = { "* ", "" }
  if lnum > 1 and vim.fn.getline(lnum - 1):match("%S") then
    table.insert(new, 1, "") -- keep a gap after whatever sits above
  end
  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, new)
  return lnum + #new - 2
end

-- o / O: on a top-level heading, open a new heading (below skips the children).
-- Anywhere else, or with a count, fall back to the native o / O.
local function open_line(above)
  local lnum = vim.fn.line(".")
  if vim.v.count == 0 and vim.fn.getline(lnum):match("^%*%s+%S") then
    local row = above and add_heading_above(lnum) or add_heading_below(lnum)
    vim.api.nvim_win_set_cursor(0, { row, 2 })
    vim.cmd.startinsert({ bang = true })
  else
    vim.api.nvim_feedkeys(vim.v.count1 .. (above and "O" or "o"), "n", false)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function(ev)
    vim.bo.softtabstop = -1
    vim.bo.comments = "b:*,b:+,b:-"
    vim.cmd.setlocal("formatoptions+=ro")
    vim.cmd.setlocal("suffixesadd+=.txt") -- `learning` finds learning.txt
    vim.cmd.setlocal("path+=**") -- search subfolders of the cwd
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.BulletFold(v:lnum)"
    vim.wo.foldlevel = 0

    vim.cmd("syntax enable")

    vim.cmd([[
      " Use silent! to prevent errors if the groups don't exist yet
      silent! syntax clear txtBullet
      silent! syntax clear txtTodo
      silent! syntax clear txtDone

      " Use [-*+] so the dash is treated as a literal, not a range
      syntax match txtBullet /^\s*\zs[-*+]/
      syntax match txtTodo /^\s*[-*+]\s\+\zs\[ \]/
      syntax match txtDone /^\s*[-*+]\s\+\zs\[x\]/

      highlight default link txtBullet Title
      highlight default link txtTodo Todo
      highlight default link txtDone Comment
    ]])

    vim.keymap.set("i", "<C-t>", function()
      if not reindent(1) then
        vim.api.nvim_feedkeys(vim.keycode("<C-t>"), "n", false)
      end
    end, { buffer = ev.buf })

    vim.keymap.set("i", "<C-d>", function()
      if not reindent(-1) then
        vim.api.nvim_feedkeys(vim.keycode("<C-d>"), "n", false)
      end
    end, { buffer = ev.buf })

    -- Enter: native bullet continuation, except on an empty bullet, which
    -- dedents (or clears it at top level).
    vim.keymap.set("i", "<CR>", function()
      local lnum = vim.fn.line(".")
      local empty_indent = vim.api.nvim_get_current_line():match("^(%s*)[*+-]%s+$")
      if not empty_indent then
        vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
      elseif #empty_indent < vim.fn.shiftwidth() then
        vim.api.nvim_set_current_line("")
        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      else
        reindent(-1)
      end
    end, { buffer = ev.buf })

    vim.keymap.set({ "n", "x", "o" }, "]h", function()
      jump_heading(false)
    end, { buffer = ev.buf, desc = "Next top-level heading" })
    vim.keymap.set({ "n", "x", "o" }, "[h", function()
      jump_heading(true)
    end, { buffer = ev.buf, desc = "Previous top-level heading" })

    vim.keymap.set("n", "o", function()
      open_line(false)
    end, { buffer = ev.buf, desc = "New heading below / open line" })
    vim.keymap.set("n", "O", function()
      open_line(true)
    end, { buffer = ev.buf, desc = "New heading above / open line" })

    -- normal: >> << (with counts), > / < + motion; visual: > <
    op_map("n", ">>", "BulletIndentOp", "_")
    op_map("n", "<<", "BulletDedentOp", "_")
    op_map("n", ">", "BulletIndentOp", "")
    op_map("n", "<", "BulletDedentOp", "")
    op_map("x", ">", "BulletIndentOp", "")
    op_map("x", "<", "BulletDedentOp", "")
  end,
})

vim.keymap.set("i", "<C-f>", function()
  require("fzf-lua").files({
    cwd = notes_dir,
    prompt = "Insert Note> ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then
          return
        end

        local file = selected[1]
        -- Extract just the filename (e.g., "gdb.txt")
        local name = vim.fn.fnamemodify(file, ":t")

        -- Insert text exactly at the cursor position
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { name })

        -- Move cursor to the end of the inserted text
        vim.api.nvim_win_set_cursor(0, { row, col + #name })

        -- Force Neovim back into insert mode (fzf-lua sometimes drops you to normal)
        vim.cmd("startinsert")
      end,
    },
  })
end, { desc = "Insert note filename" })
