return {
    "nvimdev/dashboard-nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    event = "VimEnter",
    config = function()
        local function SmartFiles(opts)
            opts = opts or {}
            local fzf = require("fzf-lua")
            local dir = vim.fn.expand(opts.cwd) or vim.fn.getcwd()
            if opts.cwd then
                vim.fn.chdir(dir)
            end
            local git_ok = pcall(vim.fn.system, { "git", "-C", dir, "rev-parse", "--is-inside-work-tree" })
            if git_ok and vim.v.shell_error == 0 then
                fzf.git_files(opts)
            else
                fzf.files(opts)
            end
        end
        local function PickProject(opts)
            opts = opts or {}
            local base_dir = vim.fn.expand(opts.cwd or "~")
            local fzf = require("fzf-lua")
            fzf.fzf_exec("fd --type d --max-depth 1", {
                cwd = base_dir,
                prompt = opts.prompt or "Project❯ ",
                hidden = opts.hidden or true,
                file_icons = opts.file_icons or false,
                preview = 'cd {} && eza --color=always --icons=always --no-quotes --group-directories-first -xl --git -I ".git" .',
                actions = {
                    ["default"] = function(selected)
                        local raw = selected[1]:gsub("^.%s+", "") -- removes first char + spaces
                        local dir = vim.fn.fnamemodify(base_dir .. raw, ":p")
                        if dir then
                            vim.fn.chdir(dir)
                            SmartFiles()
                        end
                    end,
                },
            })
        end
        local header = {
            " ██ ▄█▀ █    ██  ██▀███   ▒█████   ███▄    █ ▓█████  ██ ▄█▀ ▒█████  ",
            " ██▄█▒  ██  ▓██▒▓██ ▒ ██▒▒██▒  ██▒ ██ ▀█   █ ▓█   ▀  ██▄█▒ ▒██▒  ██▒",
            "▓███▄░ ▓██  ▒██░▓██ ░▄█ ▒▒██░  ██▒▓██  ▀█ ██▒▒███   ▓███▄░ ▒██░  ██▒",
            "▓██ █▄ ▓▓█  ░██░▒██▀▀█▄  ▒██   ██░▓██▒  ▐▌██▒▒▓█  ▄ ▓██ █▄ ▒██   ██░",
            "▒██▒ █▄▒▒█████▓ ░██▓ ▒██▒░ ████▓▒░▒██░   ▓██░░▒████▒▒██▒ █▄░ ████▓▒░",
            "▒ ▒▒ ▓▒░▒▓▒ ▒ ▒ ░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░   ▒ ▒ ░░ ▒░ ░▒ ▒▒ ▓▒░ ▒░▒░▒░ ",
            "░ ░▒ ▒░░░▒░ ░ ░   ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░░   ░ ▒░ ░ ░  ░░ ░▒ ▒░  ░ ▒ ▒░ ",
            "░ ░░ ░  ░░░ ░ ░   ░░   ░ ░ ░ ░ ▒     ░   ░ ░    ░   ░ ░░ ░ ░ ░ ░ ▒  ",
            "░  ░      ░        ░         ░ ░           ░    ░  ░░  ░       ░ ░  ",
            "",
            "",
        }
        local version = vim.version()
        local footer = {
            "",
            "",
            string.format("nvim %d.%d.%d", version.major, version.minor, version.patch),
        }
        vim.api.nvim_set_hl(0, "DashboardHeader", { link = "GitSignsChange" })
        vim.api.nvim_set_hl(0, "DashboardFooter", { link = "GitSignsDelete" })
        vim.api.nvim_set_hl(0, "DashboardProjectTitle", { link = "GitSignsChange" })
        vim.api.nvim_set_hl(0, "DashboardProjectTitleIcon", { link = "GitSignsChange" })
        vim.api.nvim_set_hl(0, "DashboardProjectIcon", { link = "GitSignsAdd" })
        vim.api.nvim_set_hl(0, "DashboardMruTitle", { link = "GitSignsChange" })
        vim.api.nvim_set_hl(0, "DashboardMruIcon", { link = "GitSignsChange" })
        local dashboard = require("dashboard")
        dashboard.setup({
            theme = "hyper",
            letter_list = "12345678abcdefgimnopqrstuvwxyz",
            config = {
                header = header,
                footer = footer,
                packages = {
                    enable = true,
                },
                project = {
                    enable = true,
                    limit = 8,
                    action = function(path)
                        SmartFiles({
                            cwd = path,
                            prompt = vim.fn.fnamemodify(path, ":t") .. "❯ ",
                        })
                    end,
                },
                mru = {
                    enable = true,
                    limit = 10,
                    cwd_only = false,
                },
                shortcut = {
                    {
                        desc = " New File ",
                        group = "DiagnosticOk",
                        action = "ene",
                        key = "e",
                    },
                    {
                        desc = " Search ",
                        group = "DiagnosticHint",
                        key = "s",
                        action = function()
                            require("fzf-lua").live_grep()
                        end,
                    },
                    {
                        desc = " Files ",
                        group = "DiagnosticHint",
                        key = "p",
                        action = function()
                            SmartFiles()
                        end,
                    },
                    {
                        desc = " Notes ",
                        group = "DiagnosticError",
                        action = function()
                            SmartFiles({
                                cwd = "~/Documents/Notes/",
                                hidden = true,
                                prompt = "Note❯ ",
                            })
                        end,
                        key = "n",
                    },
                    {
                        desc = " dotfiles ",
                        group = "DiagnosticError",
                        action = function()
                            SmartFiles({
                                cwd = "~/Projects/dotfiles/",
                                hidden = true,
                                prompt = "dotfiles❯ ",
                            })
                        end,
                        key = "d",
                    },
                    {
                        desc = " Repos ",
                        group = "DiagnosticWarn",
                        action = function()
                            PickProject({
                                cwd = "~/Projects/",
                                hidden = true,
                                prompt = "Repo❯ ",
                            })
                        end,
                        key = "r",
                    },
                },
            },
        })
    end,
}
