local M = {}

function M.setup()
    vim.api.nvim_set_hl(0, "MarkdownTag", { link = "Special", default = true })
end

function M.attach()
    -- matchadd is window-local, so avoid adding it twice per window
    if vim.w.markdown_tag_match then
        return
    end
    vim.w.markdown_tag_match = vim.fn.matchadd(
        "MarkdownTag",
        [[\v(^|\s)\zs#[[:alnum:]_/-]+]]
    )
end

return M
