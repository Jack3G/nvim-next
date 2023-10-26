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

-- vim.o.number = true
-- vim.o.relativenumber = true

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
            { "<leader>gsr", "<cmd>Gitsigns reset_hunk<CR>" },
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
        'stevearc/aerial.nvim',
        opts = {},
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },

    { -- :TSBufEnable highlight
        "nvim-treesitter/nvim-treesitter",
        build = function()
            vim.cmd [[TSUpdate]]
        end,
        config = function()
            require("nvim-treesitter.configs").setup {
                auto_install = true,

                highlight = {
                    enable = true,

                    disable = { "markdown", "markdown_inline" },
                },
            }
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },


    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-nvim-lua",
            "ray-x/cmp-treesitter"
        },
        config = function()
            local cmp = require("cmp")
            local select_behaviour = { behavior = require("cmp.types").cmp.SelectBehavior.Select }
            local next_func = cmp.mapping.select_next_item(select_behaviour)
            local prev_func = cmp.mapping.select_prev_item(select_behaviour)
            cmp.setup({
                sources = {
                    { name = "buffer" },
                    { name = "path" },
                    { name = "emoji" },
                    { name = "nvim_lua" },
                    { name = "treesitter" },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<C-g>"] = cmp.mapping.abort(),

                    ["<C-n>"]   = next_func,
                    ["<Down>"]  = next_func,
                    ["<Tab>"]   = next_func,
                    ["<C-p>"]   = prev_func,
                    ["<Up>"]    = prev_func,
                    ["<S-Tab>"] = prev_func,
                },
                -- snippet = -- TODO: set up a snippet engine for cmp
            })
        end,
    },

    "ollykel/v-vim",


    -- Looks --
    { "morhetz/gruvbox", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
    { "sainnhe/sonokai", lazy = false, priority = 1000 },
    {
        "karb94/neoscroll.nvim",
        config = true,
    },
})

vim.cmd [[colorscheme sonokai]]


local function daily_note()
    local vault_dir = vim.env.VAULT_DIR or vim.fn.expand("~/vault")
    local date_string = os.date("%Y-%m-%d")
    local time_string = "_"..os.date("%X").."+10:00"

    local today_file = vault_dir.."/daily/"..date_string..".md"
    local already_exists = vim.fn.filereadable(today_file)

    local template_contents = {
        "---",
        "title: Daily Note for "..date_string,
        "date: "..date_string..time_string,
        "---",
        "",
        "",
    }

    vim.cmd("edit "..today_file)
    if already_exists == 0 then
        vim.api.nvim_put(template_contents, "", false, true)
    end
end

vim.api.nvim_create_user_command("DailyNote", daily_note, {})


local function writing_width()
    local is_textwidth_on = vim.bo.textwidth > 0
    local preferred_columns = 80 -- TODO: maybe make this configurable?

    vim.bo.textwidth = is_textwidth_on and 0 or preferred_columns
    print("'textwidth' is now "..vim.bo.textwidth)
end

local function writing_conceal()
    local is_conceal_on = vim.wo.conceallevel > 0

    vim.wo.conceallevel = is_conceal_on and 0 or 2
    print("'conceallevel' is now "..vim.wo.conceallevel)
end


local map = vim.keymap.set

map("n", "<leader>", "<nop>")
map("n", "<leader>/", "<cmd>noh<CR>")
map("n", "<leader>`", "<C-^>")
map("n", "<leader>ww", writing_width)
map("n", "<leader>wc", writing_conceal)

map({ "n", "v", "o" }, "j", "gj")
map({ "n", "v", "o" }, "k", "gk")
map({ "n", "v", "o" }, "J", "6gj")
map({ "n", "v", "o" }, "K", "6gk")
map({ "n", "v", "o" }, "H", "^")
map({ "n", "v", "o" }, "L", "$")
map({ "n", "v", "o" }, "M", "J")

-- The same thing but arrow keys bc colemak
map({ "n", "v", "o" }, "<Down>", "gj")
map({ "n", "v", "o" }, "<Up>", "gk")
map({ "n", "v", "o" }, "<S-Down>", "6gj")
map({ "n", "v", "o" }, "<S-Up>", "6gk")
map({ "n", "v", "o" }, "<S-Left>", "^")
map({ "n", "v", "o" }, "<S-Right>", "$")
