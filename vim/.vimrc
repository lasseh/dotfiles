" __              __   __  __
"/\ \            /\ \ /\ \/\ \  __
"\ \ \         __\ \\ \ \ \ \ \/\_\    ___ ___
" \ \ \  __  /'__`\//  \ \ \ \ \/\ \ /' __` __`\
"  \ \ \L\ \/\  __/     \ \ \_/ \ \ \/\ \/\ \/\ \
"   \ \____/\ \____\     \ `\___/\ \_\ \_\ \_\ \_\
"    \/___/  \/____/      `\/__/  \/_/\/_/\/_/\/_/
"
" Legz's Everyday Vim Config File
" - Used mostly for Golang, Perl, Shell
"
" 1. Plugins
"	- vundle
"	- see plugin list
"
" 2. Hotkeys
"       2.1 Leader Hotkeys (SPACE)
"		r:	Save and run Go program.
"		ev:	Open .vimrc in a split.
"		sv:	Reload vim with the new changes in .vimrc.
"		=:	Auto-indent the whole file.
"		R:	Globaly rename the variable name.
"		q:	Quit vim.
"		qq:	Really quit vim.
"		h:	hide search highligt
"
"	2.2 Other Hotkeys
"		C^n	Toggle NERDTree
"		F5	Toggle Paste-Mode
"		F6	Toggle Tagbar
"		F7	Toggle linenumbers
"		^x^o 	Toggle omnicomplete
"
"	2.2.1 Nerdtree Hotkeys
"		o 	open folder
"		O	recursively open folder
"		go	preview file
"		t	open in new tab
"		i	open in vertical split
"		s	open in horizontal split
"		:e somefile	create a new file
"
" ====================================================================
" Enable syntax highlight
" ====================================================================
syntax on

" ====================================================================
" Be (Vim)proved, required from Vundle
" ====================================================================
set nocompatible
filetype off

" ====================================================================
" Set the runtime path to initialize vundle
" ====================================================================
set rtp+=~/.vim/bundle/Vundle.vim

" ====================================================================
" Begin of Plugins section
" To install plugins on new machines
" :PluginInstall
" ====================================================================

" ====================================================================
" Start vundle. Keep plugin commands between vundle#begin/end
" Alternatively, pass a path where Vundle should install plugins
" Example: call vundle#begin('~/some/path/here')
" ====================================================================
call vundle#begin('~/.vim/plugins')

" ====================================================================
" Vundle:
" Let Vundle manage Vundle, required
" ====================================================================
Plugin 'VundleVim/Vundle.vim'

" ====================================================================
" The NERD Tree:
" Hierarchy Tree starting from current directory.
" ====================================================================
Plugin 'scrooloose/nerdtree'

" ====================================================================
" Themes:
Plugin 'ghifarit53/tokyonight-vim'

" ====================================================================
" Vim JSON:
" Pretty render of json
" ====================================================================
Plugin 'elzr/vim-json'

" ====================================================================
" vim-gitgutter:
" Show git diff in the gutter
" ====================================================================
Plugin 'airblade/vim-gitgutter'

" ====================================================================
" vim-polyglot:
" Language pack for vim, includes syntax highlighting and more
" ====================================================================
Plugin 'sheerun/vim-polyglot'

call vundle#end()
filetype plugin indent on
" ====================================================================
" End plugin things
" ====================================================================

" Set SPACE as the leader-key.
let mapleader = " "

" ====================================================================
" Keybindings
" ====================================================================
map <C-n> :NERDTreeToggle<CR>	" Toggle NERDTree Window
map <F5> :set paste<CR>		" Set pasta mode
map <F7> :set invnumber<CR>	" Toggle linenumbers

noremap <leader>ev :vsplit $MYVIMRC<cr>
noremap <leader>sv :source $MYVIMRC<cr>
" noremap <leader>= gg=G		" Disabled - can mess up existing formatting
noremap <leader>n :lnext<cr>
noremap <leader>E :lclose<cr>
noremap <leader>p :lprev<cr>
noremap <leader>q :q<cr>
noremap <leader>qq :q!<cr>
noremap <leader>wa :wa<cr>
noremap <leader>w :w<cr>
noremap <leader>h :nohlsearch<CR>
inoremap jk <esc>

" ====================================================================
" Colorscheme
" ====================================================================
set termguicolors
set background=dark

" TokyoNight theme settings
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1

colorscheme tokyonight

" ====================================================================
" Visual
" ====================================================================
set number 			" Enable line numbering
set ruler			" Enable ruler
set cmdheight=1			" Height of the command bar
" set cursorline			\" Disabled for performance
"set showmode			" Shows the current mode in the modeline
set t_Co=256 			" Enable 256-color mode
set t_ut=			" Disable background color erase
" Don't override terminal type when in tmux
if $TMUX == ''
    set term=xterm-256color	" 256-color mode, for windows/cygwin
endif
set visualbell t_vb=		" no visual bell
set novisualbell                " no visual bell
set shortmess=aIoO		" no welcome message
"set wildmenu            	" visual autocomplete for command menu
set wildmode=list:longest,full	" Show vim completion menu

" Statusline
set laststatus=2		" Display statusline
set showcmd     		" show command in bottom bar
set statusline=%<[%02n]\ %F%(\ %m%h%w%y%r%)\ %a%=\ %8l,%c%V/%L\ (%P)\ [%08O:%02B]
set noshowmode 			" Lightline handle this

" ====================================================================
" Clipboard
" ====================================================================
set clipboard^=unnamed
set clipboard^=unnamedplus

" ====================================================================
" Behaviour
" ====================================================================
set nobackup 			" Backup is for pussies.
set noswapfile			" Disable .swp file.
set undolevels=256 		" Undo levels.
set history=256			" How much history to save.
set scrolloff=8			" Number of line to keep above cursor when scrolling
set autoread 			" Auto read when file is changed
set magic  			    " Regular expression magic
set nocp 			    " no-compatible mode
set backspace=eol,start,indent	" Smarter backspace
set encoding=utf8 		" UTF-8 Encoding
set ttyfast			    " faster redrawing
set nowb			    " Prevents automatic write backup before overwriting file
set diffopt+=vertical	" Always use vertical diffs
set updatetime=250		" Faster update of internals
set lazyredraw			" Don't redraw during macros
set synmaxcol=200		" Don't syntax highlight long lines
set regexpengine=1		" Use old regex engine (faster)


" Brackets
set showmatch			" Show matching brackets
set mat=2 			    " Bracket matching blinking interval (1/10 sec)

" Searching
set incsearch			" Show partial matches.
set hlsearch			" Highlight search patterns.
set ignorecase			" Ignore case when searching.
set smartcase			" Dont ignore case if there is capitals in the search pattern

" Indentation - Preserve existing file formatting
set tabstop=8			" Display tabs as 8 spaces
set softtabstop=0		" Don't mix tabs and spaces
set shiftwidth=0		" Use tabstop value for shifting
set noexpandtab			" Keep tabs as tabs (don't convert to spaces)
set copyindent			" Copy the structure of existing indentation
set preserveindent		" Preserve existing indentation structure
set autoindent			" Auto-indent new lines to match current
set textwidth=0			" Don't auto-wrap lines
filetype plugin indent on	" Enable filetype-specific indentation

" Input
set pastetoggle=<F5> 		" Paste mode on F5
"set mouse=a			" Enable mouse scrolling.

" i always, ALWAYS hit ":W" instead of ":w"
command! Q q
command! W w

" ====================================================================
" Junos configuration
autocmd BufNewFile,BufReadPost *.junos set filetype=junos
autocmd BufRead,BufNewFile */configs/* set filetype=junos


" Python configuration
autocmd BufNewFile,BufReadPost *.py set filetype=python

" Systemd
au BufNewFile,BufRead *.automount set filetype=systemd
au BufNewFile,BufRead *.mount     set filetype=systemd
au BufNewFile,BufRead *.path      set filetype=systemd
au BufNewFile,BufRead *.service   set filetype=systemd
au BufNewFile,BufRead *.socket    set filetype=systemd
au BufNewFile,BufRead *.swap      set filetype=systemd
au BufNewFile,BufRead *.target    set filetype=systemd
au BufNewFile,BufRead *.timer     set filetype=systemd

" Nginx
au BufRead,BufNewFile /opt/nginx/*,/etc/nginx/*,/usr/local/nginx/conf/*,/usr/local/nginx/conf.d/* if &ft == '' | setfiletype nginx | endif

" Ansible
au BufRead,BufNewFile */playbooks/*.yml set filetype=ansible
" ====================================================================
" NERDTree settings
" ====================================================================
" Always open NERDTree when starting Vim
autocmd VimEnter * NERDTree | wincmd p

" Close NERDTree if it's the only window left
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Close Vim if NERDTree is the only window left after closing all other windows
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Basic NERDTree settings
let NERDTreeShowHidden=1        " Show hidden files
let NERDTreeMinimalUI=1         " Minimal UI
let NERDTreeDirArrows=1         " Use arrows for directories


" ====================================================================
" Open file at last edited position
" ====================================================================
au BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\   exe "normal g`\"" |
			\ endif

" ====================================================================
" Auto-detect indentation style (tabs vs spaces)
" ====================================================================
autocmd BufReadPost * call DetectIndent()
function! DetectIndent()
    let l:has_leading_tabs = search('^\t', 'nw') != 0
    let l:has_leading_spaces = search('^ \{2,}', 'nw') != 0
    
    if l:has_leading_tabs && !l:has_leading_spaces
        " File uses tabs
        setlocal noexpandtab
    elseif l:has_leading_spaces && !l:has_leading_tabs
        " File uses spaces - detect how many
        let l:spaces = matchstr(getline(search('^ \+', 'nw')), '^ \+')
        if len(l:spaces) > 0
            let &l:shiftwidth = len(l:spaces)
            let &l:softtabstop = len(l:spaces)
        endif
        setlocal expandtab
    endif
    " If mixed or no indentation found, keep current settings
endfunction

" ====================================================================
" GitGutter (optimized for performance)
" ====================================================================
let g:gitgutter_sign_added = '∙'
let g:gitgutter_sign_modified = '∙'
let g:gitgutter_sign_removed = '∙'
let g:gitgutter_sign_modified_removed = '∙'
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0
let g:gitgutter_map_keys = 0
let g:gitgutter_max_signs = 500		" Limit signs for performance
" Always display gitgutter column. (Prevents movement of the linenumber column)
if exists('&signcolumn')  " Vim 7.4.2201
	set signcolumn=yes
else
	let g:gitgutter_sign_column_always = 1
endif


" ====================================================================
" Theme Overwrites
" ====================================================================
" Search hilight color
"hi Search cterm=NONE ctermfg=black ctermbg=gray
" LineNumber Background
"highlight LineNr ctermfg=gray ctermbg=black
" GitGutter Line Color
"highlight GitGutterAdd ctermfg=green ctermbg=black
"highlight GitGutterChange ctermfg=yellow ctermbg=black
"highlight GitGutterDelete ctermfg=red ctermbg=black
"highlight GitGutterChangeDelete ctermfg=yellow ctermbg=black
