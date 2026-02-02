-- Legz's Neovim Configuration
-- Ported from vim/.vimrc with modern Lua configuration

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key (SPACE)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugin configuration
require("lazy").setup({
  -- TokyoNight theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "neo-tree", "terminal", "help" },
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- Neo-tree (file explorer with git integration)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = {
          width = 30,
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added     = "∙",
              modified  = "∙",
              deleted   = "∙",
              renamed   = "∙",
              untracked = "∙",
              ignored   = "",
              unstaged  = "∙",
              staged    = "∙",
              conflict  = "∙",
            },
          },
        },
      })
      -- Auto-open neo-tree on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd("Neotree show")
        end
      })
    end,
  },

  -- Git integration
  {
    "airblade/vim-gitgutter",
    config = function()
      vim.g.gitgutter_sign_added = '∙'
      vim.g.gitgutter_sign_modified = '∙'
      vim.g.gitgutter_sign_removed = '∙'
      vim.g.gitgutter_sign_modified_removed = '∙'
      vim.g.gitgutter_realtime = 0
      vim.g.gitgutter_eager = 0
      vim.g.gitgutter_map_keys = 0
      vim.g.gitgutter_max_signs = 500
      vim.opt.signcolumn = "yes"
    end,
  },

  -- NeoGit
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua",              -- optional
      -- "nvim-mini/mini.pick",           -- optional
      -- "folke/snacks.nvim",             -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit kind=floating<cr>", desc = "Show Neogit UI" }
    }
  },

  -- Language pack
  "sheerun/vim-polyglot",

  -- JSON support
  "elzr/vim-json",

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    opts = {},
  },
})

-- Basic Neovim settings (ported from .vimrc)
local opt = vim.opt

-- Visual settings
opt.number = true
opt.ruler = true
opt.cmdheight = 1
opt.termguicolors = true
opt.background = "dark"
opt.visualbell = false
opt.shortmess:append("aIoO")
opt.wildmode = {"list:longest", "full"}
opt.laststatus = 2
opt.showcmd = true
opt.showmode = false

-- Clipboard
opt.clipboard:append({"unnamed", "unnamedplus"})

-- Behavior
opt.backup = false
opt.swapfile = false
opt.undolevels = 256
opt.history = 256
opt.scrolloff = 8
opt.autoread = true
opt.magic = true
opt.compatible = false
opt.backspace = {"eol", "start", "indent"}
opt.encoding = "utf8"
opt.ttyfast = true
opt.writebackup = false
opt.diffopt:append("vertical")
opt.updatetime = 250
opt.lazyredraw = true
opt.synmaxcol = 200
opt.regexpengine = 1

-- Brackets
opt.showmatch = true
opt.matchtime = 2

-- Searching
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation - preserve existing file formatting
opt.tabstop = 8
opt.softtabstop = 0
opt.shiftwidth = 0
opt.expandtab = false
opt.copyindent = true
opt.preserveindent = true
opt.autoindent = true
opt.textwidth = 0

-- Key mappings (ported from .vimrc)
local keymap = vim.keymap.set

-- Neo-tree toggle (was NERDTree)
keymap("n", "<C-n>", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Function keys
keymap("n", "<F5>", ":set paste<CR>", { desc = "Set paste mode" })
keymap("n", "<F7>", ":set invnumber<CR>", { desc = "Toggle line numbers" })

-- Leader key mappings
keymap("n", "<leader>ev", ":vsplit $MYVIMRC<CR>", { desc = "Edit vimrc" })
keymap("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Source vimrc" })
keymap("n", "<leader>n", ":lnext<CR>", { desc = "Next location" })
keymap("n", "<leader>E", ":lclose<CR>", { desc = "Close location list" })
keymap("n", "<leader>p", ":lprev<CR>", { desc = "Previous location" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>qq", ":q!<CR>", { desc = "Force quit" })
keymap("n", "<leader>wa", ":wa<CR>", { desc = "Write all" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Write" })
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Insert mode mappings
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Command aliases
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})

-- Filetype configurations
vim.api.nvim_create_autocmd({"BufNewFile", "BufReadPost"}, {
  pattern = "*.junos",
  command = "set filetype=junos"
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*/configs/*",
  command = "set filetype=junos"
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufReadPost"}, {
  pattern = "*.py",
  command = "set filetype=python"
})

-- Systemd files
local systemd_patterns = {"*.automount", "*.mount", "*.path", "*.service", "*.socket", "*.swap", "*.target", "*.timer"}
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = systemd_patterns,
  command = "set filetype=systemd"
})

-- Nginx files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"/opt/nginx/*", "/etc/nginx/*", "/usr/local/nginx/conf/*", "/usr/local/nginx/conf.d/*"},
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.filetype = "nginx"
    end
  end
})

-- Ansible files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*/playbooks/*.yml",
  command = "set filetype=ansible"
})

-- Open file at last edited position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end
})

-- Auto-detect indentation style
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local has_leading_tabs = vim.fn.search("^\\t", "nw") ~= 0
    local has_leading_spaces = vim.fn.search("^ \\{2,}", "nw") ~= 0
    
    if has_leading_tabs and not has_leading_spaces then
      vim.bo.expandtab = false
    elseif has_leading_spaces and not has_leading_tabs then
      local spaces_line = vim.fn.getline(vim.fn.search("^ \\+", "nw"))
      local spaces = vim.fn.matchstr(spaces_line, "^ \\+")
      if #spaces > 0 then
        vim.bo.shiftwidth = #spaces
        vim.bo.softtabstop = #spaces
      end
      vim.bo.expandtab = true
    end
  end
})

-- Set paste toggle (deprecated in nvim, but keeping for compatibility)
if vim.fn.has('nvim-0.8') == 0 then
  opt.pastetoggle = "<F5>"
end
