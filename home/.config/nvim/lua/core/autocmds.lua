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
