local M = {}

function M.setup()
    vim.api.nvim_set_hl(0, "MarkdownTag", { fg = "#56b6c2", default = true })
    vim.api.nvim_set_hl(0, "MarkdownContext", { fg = "#cc91be", default = true })
end

function M.attach()
    -- matchadd is window-local, so avoid adding it twice per window
    if vim.w.markdown_tag_match then
        return
    end
    vim.w.markdown_tag_match = vim.fn.matchadd(
        "MarkdownTag",
        [=[\v(^|\s)\zs#[A-Za-z][A-Za-z0-9_-]*]=]
    )
    vim.w.markdown_context_match = vim.fn.matchadd(
        "MarkdownContext",
        [=[\v(^|\s)\zs\@[A-Za-z][A-Za-z0-9_-]*]=]
    )
end

return M
