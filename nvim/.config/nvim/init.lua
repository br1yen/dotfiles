-- OPTIONS --
do
	-- faster startup by caching compile Lua modules
	vim.loader.enable()

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.o.mouse = "a"

	vim.o.termguicolors = true
	vim.g.have_nerd_font = false
	vim.o.winborder = "none"
	vim.o.cmdheight = 0
	vim.o.laststatus = 3
	vim.o.number = true
	vim.o.relativenumber = true
	vim.o.showmode = false
	vim.o.signcolumn = "yes"

	vim.o.expandtab = true
	vim.o.shiftwidth = 8
	vim.o.tabstop = 8
	vim.o.breakindent = true
	vim.o.smartindent = true

	vim.o.incsearch = true

	vim.o.undofile = true
	vim.o.swapfile = false

	vim.o.ignorecase = true
	vim.o.smartcase = true

	vim.o.updatetime = 250
	vim.o.timeoutlen = 300

	vim.o.splitright = true
	vim.o.splitbelow = true
	vim.o.inccommand = "split"

	vim.o.scrolloff = 16
	vim.o.smoothscroll = true
	vim.o.sidescrolloff = 4

	vim.o.confirm = true

	-- sync system clipboard
	vim.schedule(function()
		vim.o.clipboard = "unnamedplus"
	end)
	vim.opt.guicursor = "a:block"
end

-- BASIC REMAPS + AUTOCOMMANDS --
do
	vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
	vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

	vim.keymap.set({ "n", "x" }, "gl", "$")
	vim.keymap.set({ "n", "x" }, "gh", "0")
	vim.keymap.set({ "n", "x" }, "gs", "^")
	vim.keymap.set({ "n", "x" }, "<C-f>", ":<C-f>")
	vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	-- diagnostic
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "single", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },

		virtual_text = true, -- end of line warning
		virtual_lines = false, -- under the line warning

		-- auto open diagnostic warning
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({
					bufnr = bufnr,
					scope = "cursor",
					focus = false,
				})
			end,
		},
	})

	vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})

	local group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
	vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
		desc = "Update buffer when file changes",
		group = group,
		callback = function()
			if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
				vim.cmd("silent! checktime")
			end
		end,
	})
	vim.api.nvim_create_autocmd("FileChangedShellPost", {
		group = group,
		callback = function()
			vim.notify("Buffer reloaded: file changed on disk", vim.log.levels.INFO)
		end,
	})
end

-- VIM PACK BUILD STEPS --
do
	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()

		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout

			if output == "" then
				output = "No output from build command."
			end

			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	-- Run the appropriate build/update command after a plugin is installed/updated.
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind

			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end

			if name == "mdmath.nvim" then
				if not ev.data.active then
					vim.cmd.packadd("mdmath.nvim")
				end
				vim.cmd("MdMath build")
				return
			end
		end,
	})
end

-- PLUGINS --
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

-- Appearance
do
	vim.pack.add({ gh("Verf/deepwhite.nvim") })
	vim.cmd.colorscheme("deepwhite")
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "MsgArea", { bg = "NONE" })

	vim.pack.add({ gh("nvim-mini/mini.nvim") })
	require("mini.surround").setup()
	local statusline = require("mini.statusline")
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end
	statusline.setup({ use_icons = vim.g.have_nerd_font })
end

-- Files and navigation
do
	vim.pack.add({ gh("nvim-lua/plenary.nvim") })

	vim.pack.add({ gh("mikavilpas/yazi.nvim") })
	require("yazi").setup({
		open_for_directories = true,
		floating_window_scaling_factor = 0.80,
		yazi_floating_window_border = "single",
		yazi_floating_window_winblend = 0,
		highlight_hovered_buffers_in_same_directory = false,

		highlight_groups = {
			hovered_buffer = { bg = "NONE" },
		},
	})

	vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "File manager" })

	vim.pack.add({ gh("ibhagwan/fzf-lua") })
	local fzf = require("fzf-lua")
	fzf.setup({
		defaults = { formatter = "path.filename_first", git_icons = false },
		fzf_colors = true,
		winopts = {
			border = "single",
			backdrop = 100,
			preview = {
				border = "single",
				layout = "flex",
				scrollbar = false,
				title = false,
			},
		},
		fzf_opts = {
			["--info"] = "inline-right", -- match count on the prompt line
			["--no-scrollbar"] = true,
			["--ellipsis"] = "…",
		},
		files = {
			cmd = "fd --type f --follow --exclude '.*' "
				.. "--exclude '*.png' --exclude '*.jpg' --exclude '*.jpeg' "
				.. "--exclude '*.gif' --exclude '*.webp' "
				.. "--exclude 'paru' --exclude 'sync/documents'",
		},
		grep = {
			formatter = "path.filename_first",
			rg_opts = "--column --line-number --no-heading --color=always --smart-case "
				.. "--glob '!.*' --glob '!.*/*' "
				.. "--glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' "
				.. "--glob '!*.gif' --glob '!*.webp' "
				.. "--glob '!**/paru/**' --glob '!**/sync/documents/**'",
		},
	})

	vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Files" })
	vim.keymap.set("n", "<leader>g", fzf.live_grep, { desc = "Grep" })
	vim.keymap.set("n", "<leader>r", fzf.history, { desc = "History" })
	vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
	vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Help" })
	vim.keymap.set("n", "<leader>a", fzf.resume, { desc = "Resume picker" })
	vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "Grep buffer" })
	vim.keymap.set("n", "<leader>F", function()
		fzf.files({ cmd = "fd --type f --hidden --follow" })
	end, { desc = "Files (incl. hidden)" })

	vim.keymap.set("n", "<leader>G", function()
		fzf.live_grep({
			rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden",
		})
	end, { desc = "Grep (incl. hidden)" })
	vim.keymap.set("n", "grr", fzf.lsp_references, { desc = "References" })
	vim.keymap.set("n", "gri", fzf.lsp_implementations, { desc = "Implementations" })
	vim.keymap.set("n", "grd", fzf.lsp_definitions, { desc = "Definitions" })
	vim.keymap.set("n", "grt", fzf.lsp_typedefs, { desc = "Type definitions" })
	vim.keymap.set("n", "grs", fzf.lsp_document_symbols, { desc = "Symbols (document)" })
	vim.keymap.set("n", "grw", fzf.lsp_live_workspace_symbols, { desc = "Symbols (workspace)" })
	vim.keymap.set("n", "<leader>dd", fzf.diagnostics_document, { desc = "Diagnostics (buffer)" })
	vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
end

-- LSP
do
	-- vim.pack.add({ gh("j-hui/fidget.nvim") })
	-- require("fidget").setup({
	-- 	notification = {
	-- 		window = {
	-- 			align = "top",
	-- 			relative = "editor",
	-- 			y_padding = 1,
	-- 		},
	-- 		view = {
	-- 			stack_upwards = false,
	-- 		},
	-- 	},
	-- })
	--
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),

		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"

				vim.keymap.set(mode, keys, func, {
					buffer = event.buf,
					desc = "LSP: " .. desc,
				})
			end

			map("grn", vim.lsp.buf.rename, "Rename")
			map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
			map("grD", vim.lsp.buf.declaration, "Declaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)

			if client and client:supports_method("textDocument/documentHighlight", event.buf) then
				local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})

				vim.api.nvim_create_autocmd("LspDetach", {
					buffer = event.buf,
					group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					callback = function(event2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({
							group = highlight_augroup,
							buffer = event2.buf,
						})
					end,
				})
			end
		end,
	})

	---@type table<string, vim.lsp.Config>
	local servers = {
		typstyle = {}, -- format typst documents
		tinymist = {
			settings = {
				formatterMode = "typstyle",
				exportPdf = "onType",
			},
		},

		stylua = {}, -- format lua
		lua_ls = { -- recommended lua language server config
			on_init = function(client)
				client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
				client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = { "lua/?.lua", "lua/?/init.lua" },
					},
					workspace = {
						checkThirdParty = false,
						-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
						--  See https://github.com/neovim/nvim-lspconfig/issues/3189
						library = vim.api.nvim_get_runtime_file("", true),
					},
				})
			end,
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					format = { enable = false }, -- Disable formatting (formatting is done by stylua)
				},
			},
		},
	}

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})

	require("mason").setup({})
	require("mason-lspconfig").setup({ automatic_enable = false })

	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		"jdtls",
		"java-debug-adapter",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	for name, server in pairs(servers) do
		vim.lsp.config(name, server)
		vim.lsp.enable(name)
	end
end

-- DEBUGGING: Java --
do
	vim.pack.add({
		gh("mfussenegger/nvim-dap"),
		gh("rcarriga/nvim-dap-ui"),
		gh("nvim-neotest/nvim-nio"),
		gh("jay-babu/mason-nvim-dap.nvim"),
		gh("mfussenegger/nvim-jdtls"),
	})

	-- Basic debugging keymaps from Kickstart
	vim.keymap.set("n", "<F5>", function()
		require("dap").continue()
	end, { desc = "Debug: Start/Continue" })
	vim.keymap.set("n", "<F1>", function()
		require("dap").step_into()
	end, { desc = "Debug: Step Into" })
	vim.keymap.set("n", "<F2>", function()
		require("dap").step_over()
	end, { desc = "Debug: Step Over" })
	vim.keymap.set("n", "<F3>", function()
		require("dap").step_out()
	end, { desc = "Debug: Step Out" })
	vim.keymap.set("n", "<leader>db", function()
		require("dap").toggle_breakpoint()
	end, { desc = "Debug: Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>dB", function()
		require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Debug: Set Conditional Breakpoint" })
	vim.keymap.set("n", "<F7>", function()
		require("dapui").toggle()
	end, { desc = "Debug: See last session result." })

	local dap = require("dap")
	local dapui = require("dapui")

	require("mason-nvim-dap").setup({
		automatic_installation = true,
		handlers = {},
		ensure_installed = {
			-- Ensures the Java debug adapter is installed instead of Go's 'delve'
			"javadbg",
		},
	})

	-- Dap UI setup
	---@diagnostic disable-next-line: missing-fields
	dapui.setup({
		icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
		---@diagnostic disable-next-line: missing-fields
		controls = {
			icons = {
				pause = "⏸",
				play = "▶",
				step_into = "⏎",
				step_over = "⏭",
				step_out = "⏮",
				step_back = "b",
				run_last = "▶▶",
				terminate = "⏹",
				disconnect = "⏏",
			},
		},
	})

	dap.listeners.after.event_initialized["dapui_config"] = dapui.open
	dap.listeners.before.event_terminated["dapui_config"] = dapui.close
	dap.listeners.before.event_exited["dapui_config"] = dapui.close

	-- Java specific config
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			-- Locate the debugger jar downloaded by mason-nvim-dap
			local debug_jar = vim.fn.glob(
				vim.fn.stdpath("data")
					.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
				true
			)

			require("jdtls").start_or_attach({
				cmd = { "jdtls" },
				root_dir = vim.fs.dirname(
					vim.fs.find({ ".git", "mvnw", "gradlew", "build.gradle" }, { upward = true })[1]
				) or vim.fn.getcwd(),

				-- Inject the debugger into the language server
				init_options = {
					bundles = { debug_jar },
				},

				on_attach = function(client, bufnr)
					require("jdtls").setup_dap({ hotcodereplace = "auto" })
					require("jdtls.dap").setup_dap_main_class_configs()

					-- Re-apply LSP keymaps for Java files
					vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP: Rename" })
					vim.keymap.set(
						{ "n", "x" },
						"gra",
						vim.lsp.buf.code_action,
						{ buffer = bufnr, desc = "LSP: Code action" }
					)
					vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "LSP: Declaration" })
				end,
			})
		end,
	})
end

-- FORMATTING --
do
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local enabled_filetypes = {
				lua = true,
				java = true,
				typst = true,
			}
			if enabled_filetypes[vim.bo[bufnr].filetype] then
				return { timeout_ms = 1000, lsp_format = "fallback" }
			else
				return nil
			end
		end,
		default_format_opts = {
			lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
		},
		-- You can also specify external formatters in here.
		formatters_by_ft = {
			-- rust = { 'rustfmt' },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>=", function()
		require("conform").format({ async = true })
	end, { desc = "Format" })
end

-- AUTOCOMPLETE + SNIPPETS
do
	vim.pack.add({
		{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
		gh("L3MON4D3/LuaSnip"),
	})

	require("blink.cmp").setup({
		snippets = { preset = "luasnip" },
		keymap = {
			preset = "default",
			["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" },
			["<C-Space>"] = { "show", "hide", "fallback" },
		},
		appearance = { nerd_font_variant = "mono" },
		completion = {
			list = { selection = { auto_insert = false } },
			menu = {
				auto_show = false,
				border = "single",
				scrollbar = false,
				draw = {
					columns = { { "label", "label_description", gap = 1 } },
				},
			},
			documentation = {
				window = {
					border = "single",
					scrollbar = false,
				},
			},
		},
		signature = {
			enabled = true,
			window = {
				border = "single",
				scrollbar = false,
			},
		},
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	})
	vim.lsp.config("*", {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
	})
end

-- TREESITTER --
do
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

	local parsers = { "bash", "lua", "luadoc", "markdown", "markdown_inline", "typst", "java", "query" }
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		-- Check if the buffer is valid (might not be after install completes)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		-- Check if a parser exists and load it
		if not vim.treesitter.language.add(language) then
			return
		end

		-- Enable syntax highlighting and other treesitter features
		vim.treesitter.start(buf)

		-- For more info on folds see `:help folds`
		-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		-- vim.wo.foldmethod = 'expr'

		-- Check if treesitter indentation is available for this language, and if so enable it
		-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
		local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

		-- Enable treesitter based indentation
		if has_indent_query then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")

			if vim.tbl_contains(installed_parsers, language) then
				-- Enable the parser if it is already installed
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				-- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				-- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

-- TYPST --
do
	vim.pack.add({ "https://github.com/chomosuke/typst-preview.nvim" })
	require("typst-preview").setup({})
end

-- MARKDOWN NOTES --
require("notes.setup")
