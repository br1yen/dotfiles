local M = {}

-- Return the raw (...) part of the markdown link under the cursor, or nil.
-- Handles nested parentheses like [x](https://en.wikipedia.org/wiki/Foo_(bar)).
local function link_at(line, col)
	local init = 1
	while true do
		local s, open = line:find("%[.-%]%(", init)
		if not s then
			return nil
		end

		local depth, close = 1, nil
		for i = open + 1, #line do
			local c = line:sub(i, i)
			if c == "(" then
				depth = depth + 1
			elseif c == ")" then
				depth = depth - 1
				if depth == 0 then
					close = i
					break
				end
			end
		end

		if not close then
			init = open + 1
		elseif col >= s and col <= close then
			return line:sub(open + 1, close - 1)
		else
			init = close + 1
		end
	end
end

-- Strip <angle brackets> and an optional "title" from a link target.
local function clean_target(raw)
	raw = vim.trim(raw)
	local angled = raw:match("^<(.-)>")
	if angled then
		return angled
	end
	return (raw:gsub("%s+[\"'].*$", ""))
end

local function url_decode(s)
	return (s:gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end))
end

function M.smart_gf()
	local raw = link_at(vim.api.nvim_get_current_line(), vim.fn.col("."))
	if not raw then
		vim.cmd("normal! gf")
		return
	end

	local target = clean_target(raw)

	-- external links go to the system handler, untouched
	if (target:match("^%a[%w+.-]*://") and not target:match("^file://")) or target:match("^mailto:") then
		vim.ui.open(target)
		return
	end

	-- local file: now it's safe to drop fragments and decode %XX
	local file = target:gsub("^file://", ""):gsub("#.*$", "")
	file = vim.fs.normalize(url_decode(file))

	if file == "" then
		return -- pure "#heading" link, nothing to open
	end

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
end

return M
