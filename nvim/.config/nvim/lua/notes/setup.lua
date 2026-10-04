-- ~/.config/nvim/lua/notes/setup.lua

---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("MeanderingProgrammer/render-markdown.nvim"),
	gh("HakonHarnes/img-clip.nvim"),
	gh("3rd/image.nvim"),
	gh("Thiago4532/mdmath.nvim"),
})

-- KEYMAPS + AUTOCMDS
vim.api.nvim_create_user_command("Notes", function()
	vim.cmd("edit ~/sync/notes")
end, {})

vim.api.nvim_create_user_command("NewNote", function(opts)
	local title = vim.trim(opts.args)
	local slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
	if slug == "" then
		slug = "untitled"
	end

	local dir = vim.fn.expand("~/sync/notes")
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

local function notes_live(prompt, make_pattern)
	local fzf = require("fzf-lua")
	local config = require("fzf-lua.config")

	local opts = config.normalize_opts({
		prompt = prompt,
		cwd = vim.fn.expand("~/sync/notes"),
		previewer = "builtin",
		actions = fzf.defaults.actions.files,
		fn_transform = function(x)
			return fzf.make_entry.file(x, { file_icons = true, color_icons = true })
		end,
	}, config.globals.grep)

	fzf.fzf_live(function(args)
		local q = args[1] or ""
		return table.concat({
			"rg --column --line-number --no-heading --color=always --smart-case --pcre2",
			"-g '*.md' -e",
			vim.fn.shellescape(make_pattern(q)),
		}, " ")
	end, opts)
end

vim.keymap.set("n", "<leader>ng", function()
	notes_live("Notes> ", function(q)
		return "^(?!tags:).*?(?<!#)(" .. q .. ")"
	end)
end, { desc = "Grep note content" })

vim.keymap.set("n", "<leader>nt", function()
	notes_live("Tags> ", function(q)
		return "(?<![\\w])#[\\w/-]*(" .. q .. ")|^tags:.*(" .. q .. ")"
	end)
end, { desc = "Grep tags" })

vim.keymap.set("n", "<leader>t", "<cmd>e ~/sync/notes/todo.md<cr>")
vim.keymap.set("n", "<leader>nf", "<cmd>FzfLua files cwd=~/sync/notes<cr>")
vim.keymap.set("n", "<leader>nn", function()
	vim.ui.input({ prompt = "Note: " }, function(title)
		if title and title ~= "" then
			vim.cmd("NewNote " .. title)
		end
	end)
end, { desc = "New note" })

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
		})

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

		pcall(function()
			require("mdmath").setup({
				filetypes = { "markdown" },
			})
		end)

		-- retrigger markdown event to get setup for render-markdown
		local bufnr = vim.api.nvim_get_current_buf()
		vim.schedule(function()
			vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
		end)
	end,
})
