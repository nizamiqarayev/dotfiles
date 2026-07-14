-- Trailing whitespace cleanup
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local curr_pos = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_exec2(
            [[
                %s/\s\+$//e
                %s/\r\+$//e
                %s/\n\+\%$//e
            ]],
            { output = false }
        )
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local line = math.min(curr_pos[1], #lines)
        local col = math.min(curr_pos[2], #lines[line] + 1)
        vim.api.nvim_win_set_cursor(0, { line, col })
    end,
})

-- Xresources filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
    command = "set filetype=Xdefaults",
})

-- Xresources reload
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
    command = "!xrdb %",
})

-- dwmblocks recompile
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.expand("~/Projects/dwmblocks/config.h"),
    callback = function()
        vim.cmd(
            "silent !cd ~/Projects/dwmblocks && sudo make install && killall -q dwmblocks; setsid dwmblocks &"
        )
    end,
})

-- Treesitter parse on buffer read
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
        if ok then
            local bufnr = vim.api.nvim_get_current_buf()
            local lang = ts_parsers.get_buf_lang(bufnr)
            if lang then
                local parser = ts_parsers.get_parser(bufnr, lang)
                if parser then
                    parser:parse()
                end
            end
        end
    end,
})
