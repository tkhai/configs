" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)
set wildmenu
set ruler
set hls
set modeline
set ls=2

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

set viminfo='20,<1000

" Add header directories to paths to allow open included files
" using standard "gf" (go back is "Ctrl+^")
if isdirectory($PWD . "/.git")
  let include_dirs=system('ls -d -1 -- ' . $PWD . '/include ' . $PWD . '/*/include')
  execute "set path^=" . substitute(include_dirs, '\n', ',', 'g')
endif

" Grep current word on "gr", "Gr" and "GR" key press combinations
nnoremap gr :let g:Ggrep_pattern='<C-R><C-W>'<CR>:Ggrep -w <C-R><C-W> -- 
nnoremap Gr :let g:Ggrep_pattern='<C-R><C-W>'<CR>:Ggrep <C-R><C-W> -- 
nnoremap GR :Ggrep <cword> <CR>

" Auto window after grep (used by Ggrep from fugitive.vim plugin)
function! QF_PostGrep()
  if exists("g:Ggrep_pattern")
    " Highlight search pattern
    call matchadd('search', expand(g:Ggrep_pattern))
    unlet g:Ggrep_pattern
  endif
  " Open QuickFix window
  cwindow
endfunction
autocmd QuickFixCmdPost *grep* call QF_PostGrep()

" Hide/show QuickFix window
function QF_Toggle()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			if winnr('$') != 1
				cclose
			endif
			return
		endif
	endfor
	copen
endfunction
command CToggle call QF_Toggle()
nnoremap q :CToggle<CR>

" Shortcut to simplify navigation using unimpaired.vim plugin:
" previous ',' and next '.' results
map , [q
map . ]q

" Tags list on <Ctrl-]> key press (<Ctrl-t> to go stack down)
nnoremap <C-]> g<C-]>

" Browse current file's directory (<Ctrl-6> to go back)
nnoremap e :e %:p:h<CR>

" Remap Debian mapping from /usr/share/vim/vim80/defaults.vim
function! VimEnter()
	unmap Q
	map Q :qa<CR>
endfunction
autocmd VimEnter * call VimEnter()

" Build on <F2> key press
function! Run_Make()
	silent !echo "\# make -j20"
	make! -j20 | silent !echo 
	"Get number of recognized error messages
	let err = len(filter(getqflist(), 'v:val.valid'))
	if err != 0
		copen
		cc
	endif
endfunction
command RunMake call Run_Make()
nnoremap <F2> :RunMake<CR>

" Spell check on <F3> key press
function Spell_Toggle()
	if (&spell != 'nospell')
		set nospell
		set spelllang=
	else
		set spell
		set spelllang=en_us,ru_ru
	endif
endfunction
command SpellToggle call Spell_Toggle()
nnoremap <F3> :SpellToggle<CR>

" git diff on <F4> key press
nnoremap <F4> :silent !echo "\# git diff"<CR>:!git diff<CR>:silent !echo<CR>:redraw!<CR>

" git log -p on <F5> key press
nnoremap <F5> :silent !echo "\# git log -p --no-merges %"<CR>:!git log -p --no-merges %<CR>:silent !echo<CR>:redraw!<CR>
nnoremap <A-S-F5> :silent !echo "\# git log -p --no-merges "<CR>:!git log -p --no-merges <CR>:silent !echo<CR>:redraw!<CR>

" git blame on <F6> key press
nnoremap <F6> :silent !echo "\# git blame %"<CR>:!git blame %<CR>:silent !echo<CR>:redraw!<CR>

" Commit SOB
nnoremap me sSigned-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
