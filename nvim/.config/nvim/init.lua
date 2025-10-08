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
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- NERDTree
  {
    "preservim/nerdtree",
    config = function()
      -- NERDTree settings
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeDirArrows = 1
      
      -- Auto-open NERDTree when starting Neovim
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd("NERDTree")
          vim.cmd("wincmd p")
        end
      })
      
      -- Close NERDTree if it's the only window left
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if vim.fn.winnr('$') == 1 and vim.fn.exists('b:NERDTree') == 1 then
            local ok, result = pcall(vim.fn.eval, 'b:NERDTree.isTabTree()')
            if ok and result == 1 then
              vim.cmd("quit")
            end
          end
        end
      })
      
      -- Close Vim if NERDTree is the only window left after closing all other windows
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 and vim.fn.exists('b:NERDTree') == 1 then
            local ok, result = pcall(vim.fn.eval, 'b:NERDTree.isTabTree()')
            if ok and result == 1 then
              vim.cmd("quit")
            end
          end
        end
      })

      -- Auto-refresh NERDTree on file changes
      vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
        callback = function()
          if vim.fn.exists(':NERDTreeRefreshRoot') == 2 then
            vim.cmd('NERDTreeRefreshRoot')
          end
        end
      })

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          if vim.fn.exists(':NERDTreeRefreshRoot') == 2 then
            vim.cmd('NERDTreeRefreshRoot')
          end
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

-- NERDTree toggle
keymap("n", "<C-n>", ":NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })

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