local M = {}

function M.smart_gf()
	local line = vim.api.nvim_get_current_line()
	local col = vim.fn.col(".")
	for s, target, e in line:gmatch("()%[.-%]%((.-)%)()") do
		if col >= s and col < e then
			local file = target:gsub("#.*$", ""):gsub("%%20", " ")

			-- external URLs go to the browser
			if file:match("^https?://") then
				vim.ui.open(file)
				return
			end

			file = file:gsub("^file://", "")
			file = vim.fn.expand(file)
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
			return
		end
	end
	vim.cmd("normal! gf")
end

return M
