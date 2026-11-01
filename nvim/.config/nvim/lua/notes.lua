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
