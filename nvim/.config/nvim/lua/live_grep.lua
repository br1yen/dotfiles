local MiniPick = require("mini.pick")
local M = {}

local function big()
	local height = math.floor(0.9 * vim.o.lines)
	local width = math.floor(0.9 * vim.o.columns)
	return {
		anchor = "NW",
		height = height,
		width = width,
		row = math.floor(0.5 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
	}
end

---@param opts? { name?: string, cwd?: string, pattern?: fun(q: string): string, args?: string[], on_quickfix?: fun(q: string) }
function M.open(opts)
	opts = opts or {}
	local cwd = opts.cwd or vim.uv.cwd()
	local make_pattern = opts.pattern or function(q)
		return q
	end
	local extra_args = opts.args or {}

	local process
	local set_items_opts = { do_match = false }
	local spawn_opts = { cwd = cwd }

	local match = function(_, _, query)
		pcall(vim.uv.process_kill, process)
		if #query == 0 then
			return MiniPick.set_picker_items({}, set_items_opts)
		end

		local command = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--ignore-case",
		}
		vim.list_extend(command, extra_args)
		vim.list_extend(command, { "-e", make_pattern(table.concat(query)) })

		process = MiniPick.set_picker_items_from_cli(command, {
			postprocess = function(lines)
				local results = {}
				for _, line in ipairs(lines) do
					local file, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
					if file then
						local prefix = vim.fn.fnamemodify(file, ":t") .. ":" .. lnum .. ": "
						results[#results + 1] = {
							path = file,
							lnum = tonumber(lnum),
							col = tonumber(col),
							text = prefix .. text,
							prefix_len = #prefix,
						}
					end
				end
				return results
			end,
			set_items_opts = set_items_opts,
			spawn_opts = spawn_opts,
		})
	end

	local show = function(buf_id, items, query)
		MiniPick.default_show(buf_id, items, {}, { show_icons = false })

		local ns = vim.api.nvim_create_namespace("MiniPickGrepMatch")
		vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

		local pat = table.concat(query)
		if pat == "" then
			return
		end
		local needle = pat:lower()

		for i, item in ipairs(items) do
			local hay = item.text:lower()
			local start = item.prefix_len + 1
			while true do
				local s, e = hay:find(needle, start, true)
				if not s then
					break
				end
				vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, s - 1, {
					end_col = e,
					hl_group = "Search",
				})
				start = e + 1
			end
		end
	end

	local to_quickfix = {
		func = function()
			local q = table.concat(MiniPick.get_picker_query() or {})
			MiniPick.stop()
			if q ~= "" and opts.on_quickfix then
				vim.schedule(function()
					opts.on_quickfix(q)
				end)
			end
		end,
	}

	return MiniPick.start({
		source = {
			items = {},
			name = opts.name or "Grep",
			cwd = cwd,
			match = match,
			show = show,
			choose = MiniPick.default_choose,
		},
		mappings = {
			to_quickfix_ctrl = vim.tbl_extend("force", { char = "<C-q>" }, to_quickfix),
		},
		window = { config = big },
	})
end

return M
