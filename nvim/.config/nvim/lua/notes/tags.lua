local M = {}

local ns = vim.api.nvim_create_namespace("md_tags")

local function define_hl()
	vim.api.nvim_set_hl(0, "MarkdownTag", { fg = "#56b6c2" })
	vim.api.nvim_set_hl(0, "MarkdownContext", { fg = "#cc91be" })
end

function M.setup()
	define_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("md_tags_hl", { clear = true }),
		callback = define_hl,
	})
end

-- Return {start, end} byte ranges of inline code spans (`...` or ``...``).
local function code_spans(line)
	local spans = {}
	local i = 1
	while true do
		local s, e = line:find("`+", i)
		if not s then
			break
		end

		-- the closing run must have the same number of backticks
		local close_end
		local j = e + 1
		while true do
			local cs, ce = line:find("`+", j)
			if not cs then
				break
			end
			if ce - cs == e - s then
				close_end = ce
				break
			end
			j = ce + 1
		end

		if not close_end then
			break -- unmatched backticks, treat the rest as plain text
		end
		spans[#spans + 1] = { s, close_end }
		i = close_end + 1
	end
	return spans
end

local function in_span(pos, spans)
	for _, sp in ipairs(spans) do
		if pos >= sp[1] and pos <= sp[2] then
			return true
		end
	end
	return false
end

local function mark(buf, row, line, pat, hl, spans)
	for s, text, e in line:gmatch(pat) do
		if (s == 1 or line:sub(s - 1, s - 1):match("%s")) and not in_span(s, spans) then
			vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, {
				end_col = e - 1,
				hl_group = hl,
				priority = 200,
			})
		end
	end
end

local function paint(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local in_frontmatter = lines[1] == "---"
	local in_fence = false

	for i, line in ipairs(lines) do
		if in_frontmatter then
			if i > 1 and line == "---" then
				in_frontmatter = false
			end
		elseif line:match("^%s*```") or line:match("^%s*~~~") then
			in_fence = not in_fence
		elseif not in_fence then
			local spans = code_spans(line)
			mark(buf, i - 1, line, "()(#%a[%w_/-]*)()", "MarkdownTag", spans)
			mark(buf, i - 1, line, "()(@%a[%w_-]*)()", "MarkdownContext", spans)
		end
	end
end

function M.attach(buf)
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("md_tags_" .. buf, { clear = true }),
		buffer = buf,
		callback = function()
			paint(buf)
		end,
	})
	paint(buf)
end

return M
