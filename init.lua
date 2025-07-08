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


vim.go.background = "dark"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.go.timeoutlen = 1500

-- vim.go.number = true
-- vim.go.relativenumber = true

vim.o.tabstop = 3
vim.o.shiftwidth = 3
vim.o.expandtab = false
vim.o.linebreak = true
vim.o.foldenable = false

vim.go.termguicolors = true
vim.g.netrw_banner = 0

vim.o.spell = true
vim.g.netrw_browsex_viewer = "xdg-open"

local vault_dir = vim.env.VAULT_DIR or vim.fn.expand("~/vault")


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
         { "<leader><leader>", "<cmd>Telescope<CR>" },
         { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
         { "<leader>b", "<cmd>Telescope buffers<CR>" },

         { "<leader>vf", "<cmd>Telescope find_files search_dir={\""..
            vault_dir.. "\"} cwd="..vault_dir.."<CR>",
            desc = "Find vault file" },
         { "<leader>vg", "<cmd>Telescope live_grep search_dir={\""..
            vault_dir.. "\"} cwd="..vault_dir.."<CR>",
            desc = "Search vault"},
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
      "stevearc/aerial.nvim",
      opts = {},
      dependencies = {
         "nvim-treesitter/nvim-treesitter",
         "nvim-tree/nvim-web-devicons"
      },
      keys = {
         { "<leader>ta",  "<cmd>AerialToggle<CR>",
            desc = "Toggle Aerial" },
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

         vim.o.foldmethod = "expr"
         vim.o.foldexpr = "nvim_treesitter#foldexpr()"
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
         "hrsh7th/cmp-nvim-lsp",
         "PaterJason/cmp-conjure",
      },
      config = function()
         local cmp = require("cmp")
         local select_behaviour = { behavior = require("cmp.types").cmp.SelectBehavior.Select }
         local next_func = cmp.mapping.select_next_item(select_behaviour)
         local prev_func = cmp.mapping.select_prev_item(select_behaviour)
         cmp.setup({
            sources = {
               { name = "buffer", priority = 1 },
               { name = "path", priority = 2 },
               { name = "emoji", priority = 2 },
               { name = "nvim_lsp", priority = 3 },
               { name = "conjure", priority = 4 },
            },
            window = {
               completion = cmp.config.window.bordered(),
               documentation = cmp.config.window.bordered(),
            },
            mapping = {
               ["<CR>"] = cmp.mapping.confirm({ select = false }),
               ["<C-g>"] = cmp.mapping.abort(),

               ["<Down>"]  = next_func,
               ["<Up>"]    = prev_func,

               ["<C-b>"] = cmp.mapping.scroll_docs(-4),
               ["<C-f>"] = cmp.mapping.scroll_docs(4),
            },
            -- snippet = -- TODO: set up a snippet engine for cmp
         })
      end,
   },

   {
      "williamboman/mason.nvim",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
         "neovim/nvim-lspconfig",
         "hrsh7th/cmp-nvim-lsp", -- needed to get capabilities
      },

      config = function()
         require("mason").setup()
         require("mason-lspconfig").setup()

         local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
         for _,server in pairs(require("mason-lspconfig").get_installed_servers()) do
            require("lspconfig")[server].setup({
               capabilities = cmp_capabilities,
            })
         end

         require("lspconfig").lua_ls.setup({
            capabilities = cmp_capabilities,
            on_init = function(client)
               local path = client.workspace_folders[1].name
               if vim.loop.fs_stat(path.."/.luarc.json") or vim.loop.fs_stat(path.."/.luarc.jsonc") then
                  return
               end

               client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                  runtime = { version = "LuaJIT" },
                  workspace = {
                     checkThirdParty = false,
                     library = { vim.env.VIMRUNTIME },
                  },
               })
            end,
            settings = { Lua = {} },
         })

         vim.api.nvim_create_autocmd("LspAttach", {
            desc = "setup lsp keybinds",
            callback = function()
               local bufmap = function(mode, lhs, rhs)
                  local opts = { buffer = true, noremap = true }
                  vim.keymap.set(mode, lhs, rhs, opts)
               end

               bufmap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")

               bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
               bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
               bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")

               bufmap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>")
               bufmap("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>")
            end,
         })

         -- can't install with mason: language server is a part of the engine
         require("lspconfig").gdscript.setup({ capabilities = cmp_capabilities })
      end,
   },

   {
      "Olical/conjure",
      init = function()
         vim.g["conjure#filetype#janet"] = "conjure.client.janet.stdio"
      end,
   },

   "ollykel/v-vim",
   "janet-lang/janet.vim",


   -- Looks --
   { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
   { "morhetz/gruvbox", lazy = true },
   { "rebelot/kanagawa.nvim", lazy = true },
   { "folke/tokyonight.nvim", lazy = true },
   { "sainnhe/sonokai", lazy = true },
   {
      "karb94/neoscroll.nvim",
      config = true,
   },
})

vim.cmd [[colorscheme catppuccin-mocha]]


-- Eric Feliksik - http://lua-users.org/wiki/TimeZone
local function get_timezone_offset(ts)
   local utcdate   = os.date("!*t", ts)
   local localdate = os.date("*t", ts)
   localdate.isdst = false -- this is the trick
   return os.difftime(os.time(localdate), os.time(utcdate))
end

local function daily_note()
   local date_string = os.date("%Y-%m-%d")
   -- The ! in the date string means use UTC
   local time_string = os.date("_%X") .. os.date("!+%H:%M", get_timezone_offset())

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


local function option_cycle(option_table, option_name, values)
   assert(type(option_table) == "table")
   assert(type(values) == "table")
   assert(#values >= 1)

   local known_table_name = ""
   if option_table == vim.go then
      known_table_name = " (set globally)"
   elseif option_table == vim.bo then
      known_table_name = " (set for buffer)"
   elseif option_table == vim.wo then
      known_table_name = " (set for window)"
   end

   return function()
      -- If I can't find the value, default to the first one
      local current_value_index = 1
      for i,v in pairs(values) do
         if option_table[option_name] == v then
            current_value_index = i
            break
         end
      end

      local next_index = current_value_index + 1
      if next_index > #values then
         next_index = 1
      end

      local old_value = option_table[option_name]

      option_table[option_name] = values[next_index]
      print(string.format("'%s' set to %s (was %s)%s",
         tostring(option_name),
         tostring(option_table[option_name]),
         tostring(old_value),
         known_table_name))
   end
end


-- also see above for plugin specific mappings
local map = vim.keymap.set

map("n", "<leader>", "<nop>")
map("n", "<leader>/", "<cmd>noh<CR>")
map("n", "<leader>`", "<C-^>")

map("n", "<leader>ww", option_cycle(vim.bo, "textwidth", {0, 80}))
map("n", "<leader>wc", option_cycle(vim.wo, "conceallevel", {0, 2}))
map("n", "<leader>ws", option_cycle(vim.wo, "spell", {false, true}))
map("n", "<leader>wl", option_cycle(vim.bo, "spelllang", {"en", "eo"}))
map("n", "<leader>wv", option_cycle(vim.wo, "virtualedit", {"none", "all"}))

map("n", "<leader>iu", "\"=trim(system('date +%s'))<CR>", {
   desc = "Insert > Unix Time"})
map("n", "<leader>id", "\"=trim(system('date +\"%Y-%m-%d %H:%M:%S%z\"'))<CR>", {
   desc = "Insert > Date (RFC 3339)"})

-- map({ "n", "v", "o" }, "j", "gj")
-- map({ "n", "v", "o" }, "k", "gk")
-- map({ "n", "v", "o" }, "J", "6gj")
-- map({ "n", "v", "o" }, "K", "6gk")
-- map({ "n", "v", "o" }, "H", "^")
-- map({ "n", "v", "o" }, "L", "$")
map({ "n", "v", "o" }, "M", "J")

-- The same thing but arrow keys bc colemak
map({ "n", "v", "o" }, "<Down>", "gj")
map({ "n", "v", "o" }, "<Up>", "gk")
map({ "n", "v", "o" }, "<S-Down>", "6gj")
map({ "n", "v", "o" }, "<S-Up>", "6gk")
map({ "n", "v", "o" }, "<S-Left>", "^")
map({ "n", "v", "o" }, "<S-Right>", "$")
