" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

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

set nocompatible	" Compatibility with VI is not needed.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set incsearch		" Incremental search.
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

" Hide "." in file browser
let g:netrw_list_hide = '^\./$'
let g:netrw_hide = 1

" Highlight of AsyncRun exit messages
hi AsyncRunFail ctermfg=124 guifg=#942f1f
hi AsyncRunOK ctermfg=LightGreen guifg=#558C00
" Do not silent AsyncRunEvents
let g:asyncrun_silent = 0
" Echo exit status of AsyncRun command
autocmd User AsyncRunStop if g:asyncrun_code != 0 | echohl AsyncRunFail | echo 'AsyncRun: [FAIL]' |
			\ else | echohl AsyncRunOK | echo 'AsyncRun: [OK]' | endif | echohl Normal

" Returns winnr() of QuickFix window
function! Get_QF_Window_Id()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			return i
		endif
	endfor
	return -1
endfunction

" Make window size a partial of full size
function! Set_Active_Window_Width()
	let c = float2nr(&columns / 5 * 4)
	execute "vertical resize" . c
endfunction
nnoremap <C-v> :call Set_Active_Window_Width()<CR>
"" Resize window on entering
"autocmd WinEnter * if winnr() != Get_QF_Window_Id() | call Set_Active_Window_Width() | endif

" Open new tab with current file's dir <t>, new tab with working dir <T>
nnoremap t :tabe %:p:h<CR>
nnoremap T :tabe .<CR>
" Goto next tab on <Alt-Right>, previous on <Alt-Left> (also <Tab> and <Shift-Tab>)
nnoremap <A-Right> gt
inoremap <A-Right> <Esc>gti
nnoremap <Tab> gt
nnoremap <A-Left> gT
inoremap <A-Left> <Esc>gTi
nnoremap <S-Tab> gT
" Move tab left <Alt-Shift-Left> or right <Alt-Shift-Right>
nnoremap <silent> <A-S-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-S-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

" Add header directories to paths to allow open included files
" using standard "gf" (go back is "Ctrl+^")
if isdirectory($PWD . "/.git")
  let include_dirs=system('ls -d -1 -- ' . $PWD . '/include ' . $PWD . '/*/include')
  execute "set path^=" . substitute(include_dirs, '\n', ',', 'g')
endif

" Grep current word on "gr", "Gr" and "GR" key press combinations
nnoremap gr :let @/=""<CR>:set hls<CR>:let g:Ggrep_pattern='\<' . '<C-R><C-W>' . '\>'<CR>:Ggrep -w <C-R><C-W> -- 
nnoremap Gr :let @/=""<CR>:set hls<CR>:let g:Ggrep_pattern='<C-R><C-W>'<CR>:Ggrep <C-R><C-W> -- 
nnoremap GR :let @/=""<CR>:set hls<CR>:let g:Ggrep_pattern='<C-R><C-W>'<CR>:Ggrep <cword><CR>

" Auto window after grep (used by Ggrep from fugitive.vim plugin)
function! QF_PostGrep()
	" Highlight search pattern
	if exists("g:Ggrep_pattern")
		" call matchadd('search', expand(g:Ggrep_pattern))
		let @/=g:Ggrep_pattern
		unlet g:Ggrep_pattern
	endif
	" Open QuickFix window
	if Get_QF_Window_Id() == -1
		copen
		wincmd p
	endif
endfunction
autocmd QuickFixCmdPost *grep* call QF_PostGrep()

" Hide/show QuickFix window
function QF_Toggle()
	if Get_QF_Window_Id() == -1
		copen
		wincmd p
	elseif winnr('$') != 1
		cclose
	endif
endfunction
command CToggle call QF_Toggle()
nnoremap q :CToggle<CR>

" Open quickfix window of full width
autocmd FileType qf wincmd J

" QuickFix window navigation: previous row ',' and next row '.'
map , :cprev<CR>
map . :cnext<CR>

" Tags list on <Ctrl-]> key press (<Ctrl-t> to go stack down)
nnoremap <C-]> g<C-]>

" Custom tag
nnoremap s :ts 

" Start and end of current function and next function
nnoremap [[ 99[{
nnoremap ]] 99]}
nnoremap [] j0[[%/{<CR>
nnoremap ][ k$][%?}<CR>

" Return current function/structure name
function! GetPrimitiveName()
  let winview = winsaveview()
  let l:belloff = &belloff
  normal $
  let row = search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW')
  let prototype = getline(row)

  if row > 0 && search("{") > 0
    set belloff=all
    keepjump normal %
    let &belloff = l:belloff
    let row = line(".")
  endif

  call winrestview(winview)

  if row < line(".")
    return ""
  endif

  let func = substitute(prototype, '^\(\|.*[ *]\)\(\w\+\)(.*[),]$', '\2()', 'g')
  if func != prototype
    return func
  endif

  let cut_struct = substitute(prototype, 'struct.*{', '', 'g')
  if (cut_struct != prototype)
    return prototype
  endif
  return ""
endfun

function! GetDefines()
  let winview = winsaveview()
  let l:belloff = &belloff
  let result = ""

  let prev_row = line(".")
  let open_bkt = 0
  while 1
     set belloff=all
     keepjump normal [#
     let &belloff = l:belloff

     let row = line(".")
     if row == prev_row
       break
     endif

     let str = getline(row)
     if str[:2] == "#if" && open_bkt == 1
       let open_bkt = 0
       let str = "(" . str
     elseif str[:2] == "#el" && open_bkt == 0
       let open_bkt = 1
       let str = str . ")"
     elseif open_bkt == 0
       let str = "(" . str . ")"
     endif

     let result = str . " " . result
     let prev_row = row
  endwhile

  call winrestview(winview)
  return result
endfun

function! GetPositionInCode()
  if &filetype != 'c' && &filetype != 'cpp'
    return ""
  endif
  set lazyredraw
  let primitive = GetPrimitiveName()
  let defines = GetDefines()
  if primitive != "" && defines != ""
    let primitive = primitive . "  "
  endif
  set nolazyredraw
  return primitive . defines
endfunc

" Standard status bar with current position in code
set statusline=%<%f\ %h%m%r\ %{GetPositionInCode()}%=%-14.(%l,%c%V%)\ %P

" Browse current file's directory (<Ctrl-6> to go back)
nnoremap <expr> e ":e " . (expand('%') != '' ? expand('%:h') : ".") . "<CR>"
nnoremap E :e .<CR>
nnoremap W :q<CR>

" Remap Debian mapping from /usr/share/vim/vim80/defaults.vim
function! VimEnter()
	unmap Q
	map Q :qa<CR>
endfunction
autocmd VimEnter * call VimEnter()

" Redefine tagfunc to show structures first in :ts output
function! TagFunc(pattern, flags, info)
	function! CompareTags(item1, item2)
		let f1 = a:item1['filename']
		let f2 = a:item2['filename']
		let k1 = a:item1['kind']
		let k2 = a:item2['kind']

		" Current file has more priority:
		if f1 != f2
			if f1 == expand("%")
				return -1
			elseif f2 == expand("%")
				return 1
			endif
		endif

		" Structures are above other kinds.
		if k1 != k2
			if k1 == 's'
				return -1
			elseif k2 == 's'
				return 1
			endif
		endif

		" Sort the rest in file name order
		return f1 > f2 ? 1 : f1 < f2 ? -1 : 0
	endfunction

	" tagfunc in insert mode (during auto-complete) is slow
	if stridx(a:flags, 'i') != -1
		return v:null
	endif

	let result = taglist('^' . a:pattern . '$')
	call sort(result, "CompareTags")

	return result
endfunc
set tagfunc=TagFunc

" Silent man pages on <K> key press
nnoremap <expr> K ":<C-u>silent !man -S " . (v:count ? v:count : "2,3,7,4,5,1,8,9") . " <cword><CR>:redraw!<CR>"

" Open QuickFix window after make finish
function! QF_PostMake()
	"Get number of recognized error messages
	let err = len(filter(getqflist(), 'v:val.valid'))
	copen
	if err != 0
		cnf
	else
		normal GG
		wincmd p
	endif
endfunction
autocmd QuickFixCmdPost *make* call QF_PostMake()

" Raise QuickFixCmdPost *make* event after async make
let g:asyncrun_auto = "make"

function! In_LinuxKernel_Dir()
	let top_str = system("head -n1 README 2>&1")
	return top_str ==# "Linux kernel\n" ? 1 : 0
endfunction

" Build on <F2> key press
nnoremap <expr> <F2> ":AsyncRun make " . (In_LinuxKernel_Dir() ? "bzImage modules" : "all") . " -j20<CR>"

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
inoremap <F3> <Esc>:SpellToggle<CR>i

" git diff on <F4> key press
nnoremap <F4> :silent !echo "\# git diff"<CR>:silent !git --no-pager diff --color=always \| less -R<CR>:silent !echo<CR>:redraw!<CR>

" git log -p on <F5> key press
function GitLog_With_Prefix(arg)
	let cmd = "git log -p --no-merges " . a:arg
	execute "silent !echo " . '\\# ' . cmd
	execute "silent !" . cmd
	execute "echo"
	redraw!
endfunction
nnoremap <F5> :call GitLog_With_Prefix("%")<CR>
nnoremap <S-F5> :call GitLog_With_Prefix("--full-diff " . "%")<CR>
nnoremap <A-S-F5> :call GitLog_With_Prefix(".")<CR>

" git blame on <F6> key press (and scroll current screen lines)
nnoremap <silent> <F6> :let y = (line(".") - screenrow() + 1)<CR>
			\ :silent !echo "\# git blame %"<CR>
			\ :exec "!paste -d ' ' <(git blame --date=short % \| sed 's/\\([0-9]*\\)).*/\\1)/') <(source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i %) \| less -R +" . y ."g"<CR>
			\ :silent !echo<CR>:redraw!<CR>
" Gblame interface
nnoremap <S-F6> :Gblame<CR>

" Commit SOB
nnoremap <C-k> oSigned-off-by: Kirill Tkhai <ktkhai@virtuozzo.com><ESC>0
inoremap <C-k> <End><CR><C-R>="Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>"<CR><Home>
