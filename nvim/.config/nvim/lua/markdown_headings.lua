local M = {}

function M.change(delta, fallback)
    local ok, node = pcall(vim.treesitter.get_node)
    while ok and node and not node:type():match("heading") do
        node = node:parent()
    end

    if not (ok and node) then
        vim.cmd("normal! " .. fallback)
        return
    end

    local row = node:start()
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    local indent, hashes = line:match("^(%s*)(#+)%s")

    if not hashes then -- e.g. setext heading
        vim.cmd("normal! " .. fallback)
        return
    end

    local level = math.max(1, math.min(6, #hashes + delta))
    local new_line = line:gsub("^%s*#+", function()
        return indent .. string.rep("#", level)
    end, 1)

    vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
end

return M
