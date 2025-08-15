vim.cmd [[ 

if v:version < 700 | echohl WarningMsg | echo "colemak.vim: You need Vim version 7.0 or later" | echohl None | finish | endif

" Make Alt pop up the menu for all keys, mappings in use will be overridden subsequentially
noremap <silent> <M-a> :simalt a<CR>|noremap <silent> <M-b> :simalt b<CR>|noremap <silent> <M-c> :simalt c<CR>|
noremap <silent> <M-d> :simalt d<CR>|noremap <silent> <M-e> :simalt e<CR>|noremap <silent> <M-f> :simalt f<CR>|
noremap <silent> <M-g> :simalt g<CR>|noremap <silent> <M-h> :simalt h<CR>|noremap <silent> <M-i> :simalt i<CR>|
noremap <silent> <M-j> :simalt j<CR>|noremap <silent> <M-k> :simalt k<CR>|noremap <silent> <M-l> :simalt l<CR>|
noremap <silent> <M-m> :simalt m<CR>|noremap <silent> <M-n> :simalt n<CR>|noremap <silent> <M-o> :simalt o<CR>|
noremap <silent> <M-p> :simalt p<CR>|noremap <silent> <M-q> :simalt q<CR>|noremap <silent> <M-r> :simalt r<CR>|
noremap <silent> <M-s> :simalt s<CR>|noremap <silent> <M-t> :simalt t<CR>|noremap <silent> <M-u> :simalt u<CR>|
noremap <silent> <M-v> :simalt v<CR>|noremap <silent> <M-w> :simalt w<CR>|noremap <silent> <M-x> :simalt x<CR>|
noremap <silent> <M-y> :simalt y<CR>|noremap <silent> <M-z> :simalt z<CR>|

" Turbo navigation mode
" Modified to work with counts, see :help complex-repeat
nnoremap <silent> M @='5m'<CR>|xnoremap <silent> M @='5m'<CR>|onoremap M 5h|
nnoremap <silent> E @='5e'<CR>|xnoremap <silent> E @='5e'<CR>|onoremap E 5k|
nnoremap <silent> N @='5N'<CR>|xnoremap <silent> N @='5n'<CR>|onoremap N 5j|
nnoremap <silent> I @='5i'<CR>|xnoremap <silent> I @='5i'<CR>|onoremap I 5l|
inoremap <M-M> <C-o>5h|cnoremap <M-M> <Left><Left><Left><Left><Left>|
inoremap <M-E> <C-o>5k|cnoremap <M-E> <Up><Up><Up><Up><Up>|
inoremap <M-N> <C-o>5j|cnoremap <M-N> <Down><Down><Down><Down><Down>|
inoremap <M-I> <C-o>5l|cnoremap <M-I> <Right><Right><Right><Right><Right>|

" Up/down/left/right
nnoremap m h|xnoremap m h|onoremap m h|
nnoremap e k|xnoremap e k|onoremap e k|
nnoremap n j|xnoremap n j|onoremap n j|
nnoremap i l|xnoremap i l|onoremap i l|
inoremap <M-m> <Left>|cnoremap <M-m> <Left>|
inoremap <M-e> <Up>|cnoremap <M-e> <Up>|
inoremap <M-n> <Down>|cnoremap <M-n> <Down>|
inoremap <M-i> <Right>|cnoremap <M-i> <Right>|

" PageUp/PageDown
nnoremap <silent> <expr> j (winheight(0)-1) . "\<C-u>"
nnoremap <silent> <expr> h (winheight(0)-1) . "\<C-d>"
xnoremap <silent> <expr> j (winheight(0)-1) . "\<C-u>"
xnoremap <silent> <expr> h (winheight(0)-1) . "\<C-d>"
inoremap <silent> <expr> <M-j> "\<C-o>" . (winheight(0)-1) . "\<C-u>"
inoremap <silent> <expr> <M-h> "\<C-o>" . (winheight(0)-1) . "\<C-d>"
nnoremap <silent> <expr> <PageUp> (winheight(0)-1) . "\<C-u>"
nnoremap <silent> <expr> <PageDown> (winheight(0)-1) . "\<C-d>"
vnoremap <silent> <expr> <PageUp> (winheight(0)-1) . "\<C-u>"
vnoremap <silent> <expr> <PageDown> (winheight(0)-1) . "\<C-d>"
vnoremap <silent> <expr> <S-PageUp> (winheight(0)-1) . "\<C-u>"
vnoremap <silent> <expr> <S-PageDown> (winheight(0)-1) . "\<C-d>"
cnoremap <M-j> <PageUp>|
cnoremap <M-h> <PageDown>|

" Jump to line
nnoremap - gg|xnoremap - gg|onoremap - gg|
nnoremap _ G|xnoremap _ G|onoremap _ G|

" End of word forwards/backwards
nnoremap f e|xnoremap f e|onoremap f e|
nnoremap gf ge|xnoremap gf ge|onoremap gf ge|
nnoremap F E|xnoremap F E|onoremap F E|

" Cut/copy/paste
" Undo/redo
nnoremap l u|xnoremap l :<C-u>undo<CR>|
nnoremap gl U|xnoremap gl U<C-u>undo<CR>|

" Cursor position jumplist
nnoremap ( <C-o>|
nnoremap ) <C-i>|

" Navigate help file
" Use < and > to navigate in the help file instead
au FileType help nnoremap <buffer> < <C-t>|
au FileType help nnoremap <buffer> > <C-]>|
au FileType help nnoremap <buffer> <CR> <C-]>|
au FileType help nnoremap <buffer> <Backspace> <C-t>|
au FileType help nnoremap <buffer> <silent> <expr> <Space> (winheight(0)-1) . "\<C-d>0"|
au FileType help nnoremap <buffer> <silent> <expr> <S-Space> (winheight(0)-1) . "\<C-u>0"|
nnoremap <silent> <F1> :tab help<CR>
" opens commands in a new tab
cnoreabbr <expr> h    (getcmdtype() . getcmdline() != ':h'    ? 'h'    : 'tab help')
cnoreabbr <expr> he   (getcmdtype() . getcmdline() != ':he'   ? 'he'   : 'tab help')
cnoreabbr <expr> hel  (getcmdtype() . getcmdline() != ':hel'  ? 'hel'  : 'tab help')
cnoreabbr <expr> help (getcmdtype() . getcmdline() != ':help' ? 'help' : 'tab help')
cnoreabbr <expr> e    (getcmdtype() . getcmdline() != ':e'    ? 'e'    : 'tabedit' )
cnoreabbr <expr> ed   (getcmdtype() . getcmdline() != ':ed'   ? 'ed'   : 'tabedit' )
cnoreabbr <expr> edi  (getcmdtype() . getcmdline() != ':edi'  ? 'edi'  : 'tabedit' )
cnoreabbr <expr> edit (getcmdtype() . getcmdline() != ':edit' ? 'edit' : 'tabedit' )

" (GUI) Start/end of document
nnoremap <C-S-Home> <S-Home>gg|vnoremap <C-S-Home> <S-Home>gg|inoremap <C-S-Home> <S-Home>gg|
nnoremap <C-Home> gg0|xnoremap <C-Home> gg0|snoremap <C-Home> <C-Home><Home>|inoremap <C-Home> <C-o>gg<C-o>0|
nnoremap <C-j> gg0|xnoremap <C-j> gg0|snoremap <C-j> <C-Home><Home>|
nnoremap <C-End> G$|xnoremap <C-End> G$|snoremap <C-End> <C-End><End>|inoremap <C-End> <C-o>G<C-o>$|
nnoremap <C-h> G$|xnoremap <C-h> G$|snoremap <C-h> <C-End><End>|

" (GUI) Move cursor to top/bottom of screen
nnoremap <C-PageUp> H|vnoremap <C-PageUp> H|inoremap <C-PageUp> <C-o>H|
nnoremap <C-PageDown> L|vnoremap <C-PageDown> L|inoremap <C-PageDown> <C-o>L|

" (GUI) Scroll in place
nnoremap <C-Up> <C-y>|inoremap <C-Up> <C-o><C-y>|
nnoremap <C-Down> <C-e>|inoremap <C-Down> <C-o><C-e>|

" (GUI) Live line reordering (very useful)
nnoremap <silent> <C-S-Up> :move .-2<CR>|
nnoremap <silent> <C-S-Down> :move .+1<CR>|
vnoremap <silent> <C-S-Up> :move '<-2<CR>gv|
vnoremap <silent> <C-S-Down> :move '>+1<CR>gv|
inoremap <silent> <C-S-Up> <C-o>:move .-2<CR>|
inoremap <silent> <C-S-Down> <C-o>:move .+1<CR>|

" inSert/Replace/append (T)
nnoremap u i|
nnoremap U I|
"
" Allow switching from visual line to visual block mode
vnoremap <silent> <expr> <C-b> (mode() =~# "[vV]" ? "\<C-v>0o$" : "")

" (GUI) Visual mode with mouse
noremap <C-LeftMouse> <LeftMouse><Esc><C-v>|
noremap <S-LeftMouse> <LeftMouse><Esc>V|
noremap <C-LeftDrag> <LeftDrag>|
" Insert literal
inoremap <C-b> <C-v>|cnoremap <C-b> <C-v>|

" Search
" f unchanged
" F unchanged
nnoremap t f|xnoremap t f|onoremap t f|
nnoremap T F|xnoremap T F|onoremap T F|
nnoremap j t|xnoremap j t|onoremap j t|
nnoremap J T|xnoremap J T|onoremap J T|
nnoremap k n|xnoremap k n|onoremap k n|
nnoremap K N|xnoremap K N|onoremap K N|

" (GUI) search
nnoremap <C-f> :<C-u>promptrepl<CR>|vnoremap <C-f> :<C-u>promptrepl<CR>|inoremap <C-f> <C-o>:<C-u>promptrepl<CR>
nnoremap <F3> n|vnoremap <F3> n|inoremap <F3> <C-o>n|
nnoremap <S-F3> N|vnoremap <S-F3> N|inoremap <S-F3> <C-o>N|
nnoremap <C-F3> *|vnoremap <C-F3> *|inoremap <C-F3> <C-o>*|
nnoremap <C-S-F3> #|vnoremap <C-S-F3> #|inoremap <C-S-F3> <C-o>#|
"http://xona.com/2005/08/02.html

" Redraw screen
"nnoremap <C-r> <C-l>|vnoremap <C-r> <C-l>|

" New/close/save
noremap <silent> <C-w> :<C-u>call CloseWindow()<CR>|inoremap <silent> <C-w> <C-o>:<C-u>call CloseWindow()<CR>|cnoremap <silent> <C-w> <C-c>:<C-u>call CloseWindow()<CR>|
noremap <silent> <C-t> :<C-u>tabnew<CR>|
"noremap <silent> <C-n> :<C-u>tabnew<CR>|
function! CloseWindow()
    if winheight(2) < 0 | confirm quit | else | confirm close | endif
endfunction
"nnoremap <silent> <C-s> :<C-u>update<CR>|inoremap <C-s> <C-o>:<C-u>update<CR>|

" (GUI) open
nnoremap <C-o> :<C-u>browse tabnew<CR>|vnoremap <C-o> :<C-u>browse tabnew<CR>|

" (GUI) Tabs
noremap <silent> <C-S-Tab> :<C-u>tabprev<CR>|
noremap <silent> <C-Tab> :<C-u>tabnext<CR>|

" Restore mappings
" Free mappings: ,/+/H/~

" Macros (replay the macro recorded by qq)
nnoremap Q @q|

" Duplicate line
"nnoremap Q :copy .+0<CR>|

"<C-n> <C-p>
"@

" , is reserved for your custom remapping
"

" extra alias
nnoremap gh K|xnoremap gh K| 

nnoremap <Space> i<Space><Esc><Right>|
xnoremap <silent> <Space> :<C-u>let b:tmp_var=&sw\|set sw=1\|normal! gv><CR>:<C-u>let &sw=b:tmp_var\|normal! gv<CR>
xnoremap <silent> <S-Space> :<C-u>let b:tmp_var=&sw\|set sw=1\|normal! gv<<CR>:<C-u>let &sw=b:tmp_var\|normal! gv<CR>

" Enter, open line
nnoremap <CR> i<CR><Esc>|
inoremap <S-CR> <CR>|
nnoremap <S-CR> O<Esc>|
nnoremap <C-CR> o<Esc>|inoremap <C-CR> <C-o>o|

" Delete/Backspace
" nnoremap <C-d> "_dw|vnoremap <C-d> "_d|inoremap <C-d> <Delete>|cnoremap <C-d> <Delete>|
" nnoremap <Delete> "_x|vnoremap <Delete> "_d|
" nnoremap <Backspace> a<Left><Backspace><Right><Esc>|vnoremap <Backspace> "_d|
" nnoremap <C-Backspace> a<Left><C-W><Right><Esc>|inoremap <C-Backspace> <C-w>|cnoremap <C-Backspace> <C-w>|
" nnoremap <C-Delete> "_dw|inoremap <C-Delete> <C-o>"_dw|cnoremap <C-Delete> <Delete>|
" nnoremap <S-Backspace> "_d^|inoremap <S-Backspace> <Backspace>|cnoremap <S-Backspace> <Backspace>|
" nnoremap <S-Delete> "_d$|inoremap <S-Delete> <Delete>|cnoremap <S-Delete> <Delete>|

" Local autocomplete
inoremap <M-?> <C-p>|
inoremap <M-/> <C-n>|

" Omni completion
inoremap <C-S-Space> <C-p>|
inoremap <expr> <C-Space> (&omnifunc == '' <bar><bar> pumvisible() ? "\<C-n>" : "\<C-x>\<C-o>")
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" delete in
onoremap r i
vnoremap r i 

]]
-- move selected in visual mode
vim.keymap.set("v", "N", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "E", ":m '<-2<CR>gv=gv")
-- move current line in normal mode
vim.keymap.set("n", "N", ':move .+1<CR>', { noremap = true, silent = true})
vim.keymap.set("n", "E", ':move .-2<CR>', { noremap = true, silent = true})
