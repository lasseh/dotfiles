" General settings
set nocompatible                " Use Vim settings, rather than Vi settings
syntax enable                   " Enable syntax highlighting
set encoding=utf-8              " Set default encoding
set fileencoding=utf-8          " Set file encoding
set backspace=indent,eol,start  " Allow backspacing over everything in insert mode
set history=1000                " Keep 1000 lines of command line history
set ruler                       " Show the cursor position all the time
set showcmd                     " Display incomplete commands
set incsearch                   " Do incremental searching
set hlsearch                    " Highlight search results
set ignorecase                  " Ignore case when searching
set smartcase                   " Override ignorecase when pattern has upper case characters
set autoindent                  " Copy indent from current line when starting a new line
set smartindent                 " Do smart autoindenting when starting a new line
set nowrap                      " Don't wrap lines
set number                      " Show line numbers
set relativenumber              " Show relative line numbers
set showmatch                   " Show matching brackets
set visualbell                  " Use visual bell instead of beeping
set noerrorbells                " Don't ring the bell for error messages
set hidden                      " Allow buffers to exist in the background
set laststatus=2                " Always show status line
set wildmenu                    " Enhanced command-line completion
set wildmode=list:longest,full  " Complete files like a shell
set scrolloff=3                 " Keep 3 lines when scrolling
set sidescrolloff=5             " Keep 5 columns when scrolling horizontally
set confirm                     " Raise a dialog asking if you wish to save changed files
set mouse=a                     " Enable mouse usage in all modes

" Indentation settings (expandtab = spaces, noexpandtab = tabs)
set expandtab                   " Use spaces instead of tabs
set tabstop=4                   " Number of spaces that a <Tab> counts for
set shiftwidth=4                " Number of spaces to use for each step of (auto)indent
set softtabstop=4               " Number of spaces that a <Tab> counts for while editing
set smarttab                    " Insert tabs according to shiftwidth

" File type specific settings
filetype plugin indent on       " Enable file type detection, plugins, and indentation

" Backup, swap, and undo settings
set nobackup                    " Don't keep backup files
set nowritebackup               " Don't backup the file while editing
set noswapfile                  " Don't use a swapfile for the buffer
set undodir=~/.vim/undodir      " Set directory for persistent undo
set undofile                    " Enable persistent undo

" Create undo directory if it doesn't exist
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p", 0700)
endif

" Color and appearance
set background=dark             " Use dark background
colorscheme desert              " Set colorscheme (change to your preference)
set termguicolors               " Use GUI colors in the terminal

" Key mappings
let mapleader = " "             " Set leader key to space

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Quick save and quit
nnoremap <leader>wq :wq<CR>

" Clear search highlighting
nnoremap <leader>c :nohl<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Open vimrc in a new tab
nnoremap <leader>ev :tabedit $MYVIMRC<CR>

" Source vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" Status line
set statusline=%F%m%r%h%w\ [TYPE=%Y]\ [POS=%l,%v]\ [%p%%]\ [LEN=%L]
