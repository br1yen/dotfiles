-- OPTIONS --
do
	-- faster startup by caching compile Lua modules
	vim.loader.enable()

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.opt.mouse = "a"

	vim.opt.termguicolors = true
	vim.opt.background = "dark"
	vim.g.have_nerd_font = true
	vim.opt.winborder = "none"
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.signcolumn = "yes"

	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.softtabstop = 2
	vim.opt.expandtab = true
	vim.opt.breakindent = true
	vim.opt.smartindent = true
	vim.opt.linebreak = true
	vim.opt.showbreak = "↪ "

	vim.opt.ignorecase = true
	vim.opt.smartcase = true

	vim.opt.undofile = true
	vim.opt.swapfile = false

	vim.opt.updatetime = 250
	vim.opt.timeoutlen = 300

	vim.opt.splitright = true
	vim.opt.splitbelow = true

	vim.opt.scrolloff = 999
	vim.opt.sidescrolloff = 999
	vim.opt.smoothscroll = true

	vim.opt.confirm = true

	vim.schedule(function()
		vim.opt.clipboard = "unnamedplus"
	end)
end

-- BASIC REMAPS + AUTOCOMMANDS --
do
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	-- diagnostic
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "none", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },

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

	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
	vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist, { desc = "Diagnostics (quickfix)" })

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
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind

			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end

      if name == "telescope-fzf-native.nvim" then
        vim.system({ "make" }, { cwd = ev.data.path }):wait()
        return
      end
		end,
	})
end

-- Remove unused packages
local function pack_clean()
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end

  local choice = vim.fn.confirm(
    "Remove unused plugins?\n" .. table.concat(unused_plugins, "\n"),
    "&Yes\n&No",
    2
  )
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end

vim.keymap.set("n", "<leader>pc", pack_clean, { desc = "Pack: clean unused" })

require("plugins.icons")
require("plugins.obsidian")
require("plugins.lsp")
require("plugins.debug")
require("plugins.blink")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.oil")
require("plugins.mini-surround")
require("plugins.typst-preview")
