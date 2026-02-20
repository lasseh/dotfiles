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
opt.wildmode = { "list:longest", "full" }
opt.laststatus = 2
opt.showcmd = true
opt.showmode = false

-- Clipboard
opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Behavior
opt.backup = false
opt.swapfile = false
opt.undolevels = 256
opt.history = 256
opt.scrolloff = 8
opt.autoread = true
opt.magic = true
opt.compatible = false
opt.backspace = { "eol", "start", "indent" }
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
