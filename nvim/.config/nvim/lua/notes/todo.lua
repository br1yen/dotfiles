local M = {}

local ns = vim.api.nvim_create_namespace("todo_dates")
local days = { sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6 }
local full_days = {
	sunday = 0,
	monday = 1,
	tuesday = 2,
	wednesday = 3,
	thursday = 4,
	friday = 5,
	saturday = 6,
}

local function define_hl()
	local set = function(n, o)
		vim.api.nvim_set_hl(0, n, o)
	end
	set("DueOverdue", { fg = "#ffffff", bg = "#e06c75", bold = true })
	set("DueSoon1", { fg = "#e06c75", bold = true })
	set("DueSoon3", { fg = "#d19a66", bold = true })
	set("DueWeek", { fg = "#e5c07b" })
	set("DueLater", { fg = "#98c379" })
	set("DoOverdue", { fg = "#c678dd", bold = true })
	set("DoToday", { fg = "#61afef", bold = true })
	set("DoTomorrow", { fg = "#56b6c2", bold = true })
	set("DoSoon", { fg = "#6a9fd0" })
	set("DoLater", { fg = "#5c6370" })
end

local function days_until(y, m, d)
	local n = os.date("*t")
	local a = os.time({ year = n.year, month = n.month, day = n.day, hour = 12 })
	local b = os.time({ year = y, month = m, day = d, hour = 12 })
	return math.floor((b - a) / 86400 + 0.5)
end

local function due_group(n)
	if n < 0 then
		return "DueOverdue"
	elseif n <= 1 then
		return "DueSoon1"
	elseif n <= 3 then
		return "DueSoon3"
	elseif n <= 7 then
		return "DueWeek"
	else
		return "DueLater"
	end
end

local function do_group(n)
	if n < 0 then
		return "DoOverdue"
	elseif n == 0 then
		return "DoToday"
	elseif n == 1 then
		return "DoTomorrow"
	elseif n <= 3 then
		return "DoSoon"
	else
		return "DoLater"
	end
end

local function paint(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		for _, kind in ipairs({ "due", "do" }) do
			local s, e, y, m, d = line:find("%f[%w]" .. kind .. ":(%d%d%d%d)-(%d%d)-(%d%d)")
			if s then
				local n = days_until(tonumber(y), tonumber(m), tonumber(d))
				vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, {
					end_col = e,
					hl_group = (kind == "due" and due_group or do_group)(n),
				})
			end
		end
	end
end

local function resolve(arg)
	arg = arg:lower()
	local now = os.date("*t")
	local off
	if arg == "tod" or arg == "today" then
		off = 0
	elseif arg == "tom" or arg == "tomorrow" then
		off = 1
	elseif arg:match("^%+%d+$") then
		off = tonumber(arg:sub(2))
	else
		local want = days[arg] or full_days[arg]
		if not want then
			return nil
		end
		off = (want - (now.wday - 1)) % 7
		if off == 0 then
			off = 7
		end
	end
	now.day = now.day + off
	now.hour = 12
	return os.date("%Y-%m-%d", os.time(now))
end

local function set_date(key, arg)
	local d = resolve(arg)
	if not d then
		vim.notify(key .. ": use tod, tom, +N, or mon..sun", vim.log.levels.ERROR)
		return
	end
	local line = vim.api.nvim_get_current_line():gsub("%s*%f[%w]" .. key .. ":%S+", "")
	vim.api.nvim_set_current_line(line .. " " .. key .. ":" .. d)
end

-- Call this ONCE from init.lua or a global setup file
function M.setup()
	define_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("todo_dates_hl", { clear = true }),
		callback = define_hl,
	})
end

-- Call this per-buffer from ftplugin/markdown.lua
function M.attach(buf)
	-- Attach buffer-local autocmds
	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "TextChanged", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("todo_dates_" .. buf, { clear = true }),
		buffer = buf,
		callback = function()
			paint(buf)
		end,
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = vim.api.nvim_create_augroup("todo_expand_" .. buf, { clear = true }),
		buffer = buf,
		callback = function()
			local line = vim.api.nvim_get_current_line()
			local new = line
			for _, key in ipairs({ "due", "do" }) do
				new = new:gsub("%f[%w]" .. key .. ":(%S+)", function(arg)
					local d = resolve(arg)
					if d then
						return key .. ":" .. d
					end
				end)
			end
			if new ~= line then
				vim.api.nvim_set_current_line(new)
				paint(buf)
			end
		end,
	})

	-- Attach buffer-local commands
	vim.api.nvim_buf_create_user_command(buf, "Due", function(o)
		set_date("due", o.args)
	end, { nargs = 1 })
	vim.api.nvim_buf_create_user_command(buf, "Do", function(o)
		set_date("do", o.args)
	end, { nargs = 1 })

	paint(buf)
end

return M
