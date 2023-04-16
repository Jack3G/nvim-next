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

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.termguicolors = true


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
        },
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
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
    "f-person/git-blame.nvim",

    -- Looks --
    { "morhetz/gruvbox", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
    {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup()
        end,
    },

    -- Languages --
    --"nvim-orgmode/orgmode" -- TODO: A proper setup for this
})

vim.cmd [[colorscheme kanagawa]]


local map = vim.keymap.set
