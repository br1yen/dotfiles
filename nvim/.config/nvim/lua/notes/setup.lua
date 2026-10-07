-- ~/.config/nvim/lua/notes/setup.lua
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

local NOTES_DIR = vim.fn.expand("~/sync/notes")

local function esc(s)
	return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?{}|\\]", "\\%0"))
end

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local spec, kind = ev.data.spec, ev.data.kind
		if spec.name == "mdmath.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("mdmath.nvim")
			end
			vim.cmd("MdMath build")
		end
	end,
})

vim.pack.add({
	gh("MeanderingProgrammer/render-markdown.nvim"),
	gh("HakonHarnes/img-clip.nvim"),
	gh("3rd/image.nvim"),
	gh("Thiago4532/mdmath.nvim"),
})

-- KEYMAPS + AUTOCMDS
vim.api.nvim_create_user_command("Notes", function()
	vim.cmd("edit " .. vim.fn.fnameescape(NOTES_DIR))
end, {})

vim.api.nvim_create_user_command("NewNote", function(opts)
	local title = vim.trim(opts.args)
	local slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
	if slug == "" then
		slug = "untitled"
	end

	local dir = NOTES_DIR
	vim.fn.mkdir(dir, "p")

	local path = dir .. "/" .. os.date("%Y-%m-%d") .. "-" .. slug .. ".md"
	local is_new = vim.fn.filereadable(path) == 0

	vim.cmd("edit " .. vim.fn.fnameescape(path))

	if is_new then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {
			"---",
			"tags: []",
			"---",
			"# " .. (title ~= "" and title or "untitled"),
			"",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
	end
end, { nargs = "*" })

local notes_opts = {
	name = "Notes",
	cwd = NOTES_DIR,
	args = { "--pcre2", "-g", "*.md" },
	pattern = function(q)
		return "^(?!tags:).*?(?<!#)(" .. esc(q) .. ")"
	end,
}

local function rg_to_qf(opts, q)
	local pattern = opts.pattern and opts.pattern(q) or esc(q)
	local cmd = { "rg", "--vimgrep", "--smart-case" }
	vim.list_extend(cmd, opts.args or {})
	vim.list_extend(cmd, { "--", pattern, opts.cwd or "." })

	vim.system(
		cmd,
		{ text = true },
		vim.schedule_wrap(function(res)
			local lines = vim.split(res.stdout or "", "\n", { trimempty = true })
			if #lines == 0 then
				vim.notify("No matches for " .. q, vim.log.levels.WARN)
				return
			end
			vim.fn.setqflist({}, " ", {
				title = (opts.name or "grep") .. ": " .. q,
				lines = lines,
				efm = "%f:%l:%c:%m",
			})
			vim.cmd("copen")
		end)
	)
end

vim.keymap.set("n", "<leader>ng", function()
	require("live_grep").open(vim.tbl_extend("force", notes_opts, {
		on_quickfix = function(q)
			rg_to_qf(notes_opts, q)
		end,
	}))
end, { desc = "Grep note content" })

vim.keymap.set("n", "<leader>nq", function()
	vim.ui.input({ prompt = "Notes query: " }, function(q)
		if q and q ~= "" then
			rg_to_qf(notes_opts, q)
		end
	end)
end, { desc = "Query notes -> quickfix" })

local function collect_tags()
	local counts = {}
	local function add(t)
		t = t:gsub("^#", "")
		if t ~= "" then
			counts[t] = (counts[t] or 0) + 1
		end
	end

	-- inline #tags
	local inline = vim.system({
		"rg",
		"-o",
		"-N",
		"--no-filename",
		"--pcre2",
		"-g",
		"*.md",
		"(?<![\\w#])#[A-Za-z][\\w/-]*",
		NOTES_DIR,
	}, { text = true }):wait()
	for line in vim.gsplit(inline.stdout or "", "\n", { trimempty = true }) do
		add(line)
	end

	-- frontmatter "tags: a, b" / "tags: [a, b]"
	local fm = vim.system({
		"rg",
		"-N",
		"--no-filename",
		"-g",
		"*.md",
		"^tags:",
		NOTES_DIR,
	}, { text = true }):wait()
	for line in vim.gsplit(fm.stdout or "", "\n", { trimempty = true }) do
		line = line:gsub("^tags:%s*", ""):gsub("[%[%]\"']", "")
		for t in line:gmatch("[^,%s]+") do
			add(t)
		end
	end

	local items = {}
	for tag, n in pairs(counts) do
		table.insert(items, { text = ("%s (%d)"):format(tag, n), tag = tag })
	end
	table.sort(items, function(a, b)
		return a.tag < b.tag
	end)
	return items
end

local tag_opts = {
	name = "Tag",
	cwd = NOTES_DIR,
	args = { "--pcre2", "-g", "*.md" },
	pattern = function(tag)
		local t = esc(tag)
		return "(?<![\\w])#" .. t .. "(?![\\w/-])|^tags:.*(?<![\\w])" .. t .. "(?![\\w])"
	end,
}

vim.keymap.set("n", "<leader>nt", function()
	local items = collect_tags()
	if #items == 0 then
		vim.notify("No tags found", vim.log.levels.WARN)
		return
	end
	MiniPick.start({
		source = {
			name = "Tags",
			items = items,
			choose = function(item)
				if item then
					vim.schedule(function()
						rg_to_qf(tag_opts, item.tag)
					end)
				end
			end,
		},
	})
end, { desc = "Pick tag -> quickfix" })

vim.keymap.set("n", "<leader>nf", function()
	MiniPick.builtin.files(nil, { source = { cwd = NOTES_DIR } })
end, { desc = "Find note" })

vim.keymap.set("n", "<leader>nn", function()
	vim.ui.input({ prompt = "Note: " }, function(title)
		if title and title ~= "" then
			vim.cmd("NewNote " .. title)
		end
	end)
end, { desc = "New note" })

vim.keymap.set("n", "<leader>t", function()
	vim.cmd("edit " .. vim.fn.fnameescape(NOTES_DIR .. "/todo.md"))
end, { desc = "Open todo" })

-- render-markdown is configured eagerly; it only attaches to markdown
-- buffers itself, so there is no need to defer it.
require("render-markdown").setup({
	heading = {
		sign = false,
		position = "inline",
		icons = { "H1 ", "H2 ", "H3 ", "H4 ", "H5 ", "H6 " },
		width = "block",
		left_margin = { 0, 1, 2, 3, 4, 5 },
		backgrounds = { "Normal", "Normal", "Normal", "Normal", "Normal", "Normal" },
	},
	code = {
		sign = false,
		style = "language",
		language_icon = false,
		language_info = false,
		disable_background = true,
		left_margin = 4,
		left_pad = 1,
		right_pad = 1,
		border = "none",
		highlight_border = false,
	},
	bullet = { icons = { "•", "‣", "◦", "⁃" } },
	quote = { icon = "│" },
	latex = { enabled = false },
	pipe_table = { preset = "none" },
	overrides = {
		buftype = { nofile = { enabled = false } },
	},
})

-- LAZY-LOAD PLUGINS --
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	group = vim.api.nvim_create_augroup("lazy_load_notes", { clear = true }),
	callback = function()
		-- Ensure we only run setups once per Neovim session
		if vim.g.notes_plugins_loaded then
			return
		end
		vim.g.notes_plugins_loaded = true

		-- each setup is wrapped so one failure doesn't skip the rest
		pcall(function()
			require("img-clip").setup({
				default = {
					dir_path = "images",
					relative_to_current_file = true,
					use_absolute_path = false,
					prompt_for_file_name = false,
					insert_mode_after_paste = false,
					file_name = function()
						return os.date("%Y-%m-%d-%H-%M-%S")
					end,
				},
			})
		end)

		pcall(function()
			require("image").setup({
				backend = "kitty",
				kitty_method = "normal",
				order = 0,
				renamed = true,
				processor = "magick_cli",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = true,
						download_remote_images = true,
						only_render_image_at_cursor = true,
						only_render_image_at_cursor_mode = "inline",
						floating_windows = false,
					},
				},
				window_overlap_clear_enabled = true,
			})
		end)

		pcall(function()
			require("mdmath").setup({
				filetypes = { "markdown" },
			})
		end)

		-- Re-fire FileType for the current buffer so image.nvim and mdmath,
		-- which were only just set up, attach to the first markdown buffer.
		-- (Not needed for render-markdown anymore, but keep it for these two.)
		local bufnr = vim.api.nvim_get_current_buf()
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			vim.b[bufnr].notes_refire = true
			pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = bufnr, modeline = false })
			vim.b[bufnr].notes_refire = nil
		end)
	end,
})
