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

local markers = { "*", "+", "-" }

-- Re-indent a bullet line by `delta` levels and set the marker for that depth.
local function reindent(delta)
  local line = vim.api.nvim_get_current_line()
  local indent, marker, rest = line:match("^(%s*)([*+-])(%s.*)$")
  if not marker then
    return false
  end
  local sw = vim.fn.shiftwidth()
  local depth = math.max(0, math.floor(#indent / sw) + delta)
  local new = string.rep(" ", depth * sw) .. markers[depth % 3 + 1] .. rest
  local col = vim.fn.col(".") - 1 + (#new - #line)
  vim.api.nvim_set_current_line(new)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), math.max(0, col) })
  return true
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function(ev)
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = -1
    vim.bo.expandtab = true
    vim.bo.autoindent = true
    vim.bo.comments = "b:*,b:+,b:-" -- no "f" flag, so Enter repeats the bullet
    vim.opt_local.formatoptions:append({ "r", "o" })

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
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function()
    vim.opt_local.suffixesadd:append(".txt") -- `learning` finds learning.txt
    vim.opt_local.path:append("**") -- search subfolders of the cwd
  end,
})

vim.keymap.set("i", "<C-l>", function()
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
