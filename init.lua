-- nvim-next: my *next* config

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


vim.o.background = "dark"
vim.g.mapleader = " "
vim.o.timeoutlen = 1500

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.termguicolors = true
vim.g.netrw_banner = 0

vim.o.spell = true


require("lazy").setup({
    -- Functional --
    {
        "lewis6991/impatient.nvim",
        priority = 500,
    },
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
            { "<leader><leader>", "<cmd>Telescope<CR>" },
            { "<leader>b", "<cmd>Telescope buffers<CR>" },
        },
        cmd = { "Telescope" },
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = true,
    },
    {
        "numToStr/Comment.nvim",
        config = true,
    },

    {
        "lewis6991/gitsigns.nvim",
        tag = "release",
        keys = {
            { "<leader>gss", "<cmd>Gitsigns stage_hunk<CR>" },
            { "<leader>gsu", "<cmd>Gitsigns undo_stage_hunk<CR>" },
            { "<leader>gsd", "<cmd>Gitsigns diffthis<CR>" },
            { "<leader>gsp", "<cmd>Gitsigns preview_hunk<CR>" },
            { "<leader>gst", "<cmd>Gitsigns toggle_signs<CR>" },
        },
        lazy = false,
        config = function()
            require("gitsigns").setup()
        end,
    },
    {
        "f-person/git-blame.nvim",
        init = function()
            vim.g.gitblame_enabled = 0
        end,
        keys = {
            { "<leader>gb", "<cmd>GitBlameToggle<CR>" },
        },
    },
    {
        "TimUntersberger/neogit",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            disable_signs = true,
            disable_hint = true,
        },
        cmd = { "Neogit" },
    },

    {
        "neovim/nvim-lspconfig",
        lazy = false,
        keys = {
            { "[d", vim.diagnostic.goto_prev },
            { "]d", vim.diagnostic.goto_next },
            { "gd", vim.lsp.buf.definition },
            { "gD", vim.lsp.buf.declaration },
            { "K", vim.lsp.buf.hover },
        },
        config = function()
            local lspconfig = require("lspconfig")

            lspconfig.rust_analyzer.setup({})
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                    },
                },
            })
            lspconfig.csharp_ls.setup({})
            lspconfig.gdscript.setup({})
        end,
    },

    {
        "simrat39/symbols-outline.nvim",
        keys = {
            { "<leader>lo", "<cmd>SymbolsOutline<CR>" },
        },
        cmd = { "SymbolsOutline" },
        config = true,
    },


    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-emoji",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local select_behaviour = { behavior = require("cmp.types").cmp.SelectBehavior.Select }
            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "emoji" },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = {
                    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-e"] = cmp.mapping.abort(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-n>"] = cmp.mapping.select_next_item(select_behaviour),
                    ["<C-p>"] = cmp.mapping.select_prev_item(select_behaviour),
                },
                formatting = {
                    format = require("lspkind").cmp_format({}),
                },
                -- snippet = -- TODO: set up a snippet engine for cmp
            })
        end,
    },


    -- Looks --
    { "morhetz/gruvbox", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
    { "folke/tokyonight.nvim", lazy = true },
    { "sainnhe/sonokai", lazy = true },
    {
        "karb94/neoscroll.nvim",
        config = true,
    },
})

vim.cmd [[colorscheme kanagawa]]


local map = vim.keymap.set

map("n", "<leader>", "<nop>")
map("n", "<leader>/", "<cmd>noh<CR>")
map("n", "j", "gj")
map("n", "k", "gk")
