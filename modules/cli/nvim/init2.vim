""" colemak dh langmap
"set langmap=mh,MH,bt,BT,dc,ek,fe,il,jy,kn,lu,nj,pr,rs,sd,tf,ui,yo,op,DC,EK,FE,IL,JY,KN,LU,NJ,PR,RS,SD,TF,UI,YO,OP
"noremap b t
"noremap c x
"noremap d c
"noremap e k
"noremap f e
"noremap h m
"noremap i l
"noremap j z
"noremap k n
"noremap l u
"noremap m h
"noremap n j
"noremap o ;
"noremap p r
"noremap r s
"noremap s d
"noremap t f
"noremap u i
"noremap x c
"noremap y o
"noremap z <
"noremap B T
"noremap C X
"noremap D C
"noremap E K
"noremap F E
"noremap H M
"noremap I L
"noremap J Z
"noremap K N
"noremap L U
"noremap M H
"noremap N J
"noremap O :
"noremap P R
"noremap R S
"noremap S D
"noremap T F
"noremap U I
"noremap X C
"noremap Y O
"noremap Z >

""" set's

" yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
" colortheme
let g:gruvbox_italic=1
colorscheme gruvbox
set termguicolors " 24bit color
set background=dark " dark gruvbox

set nocompatible
filetype plugin on
filetype indent plugin on
filetype plugin indent on
syntax on
set t_ut= " disables the weird black artifacts while scrolling
set encoding=utf-8
set number
set relativenumber
set undodir=~/.local/share/nvim/undo-dir " setup undo directory
set undofile                " save undo chages even after computer restart
set showcmd                 " show (partial) command in status line
set showmatch               " show match brackets
set wildmenu                " visual autocomplete for command menu
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow
set splitright

cmap w!! w !sudo tee > /dev/null %

" indent settings
set expandtab
set shiftwidth=2
set softtabstop=2
" buffers don't get unloaded when hidden
set hidden
" \coc Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=200
" \coc Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" \coc Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=number
""" binds
" resize binds
" Splitting (A-HJKL to resizee)
noremap <A-h> :vertical resize -5<CR>
noremap <A-l> :vertical resize +5<CR>
noremap <A-j> :resize -5<CR>
noremap <A-k> :resize +5<CR>
" buffer binds
map ,q :bd<CR>
map ,b :Buffers<CR>
nnoremap <A-s> :vsp<CR>
nnoremap <C-s> :split<CR>
map <C-t> :tabnew<CR>
" Make Copy paste with other programs work (Needs GVim installed)
vnoremap <C-c> "+y
map <C-b> "+P
cmap w!! w !sudo tee > /dev/null %

" Shortcutting split navigation, saving a keypress:
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

noremap <C-p> :registers<CR>
" make terminal usable(TM)
augroup neovim_terminal
    autocmd!
    " Enter Terminal-mode (insert) automatically
    autocmd TermOpen * startinsert
    " Disables number lines on terminal buffers
    autocmd TermOpen * :set nonumber norelativenumber
    " allows you to use Ctrl-c on terminal window
    autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
augroup END
tnoremap <C-b> <C-\><C-n>

"""" plugins

""""" lightline
set noshowmode
set laststatus=2

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'cocstatus', 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
	    \   'cocstatus': 'coc#status'
      \ },
      \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

""""" commentary
map <leader>c :Commentary<CR>
""""" vista vim
map <leader>v :Vista!!<CR> 

""""" nnn
let g:nnn#set_default_mappings = 0
let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.6, 'highlight': 'Debug' } }
nnoremap <tab> ::NnnPicker %:p:h<CR>
""""" rainbow
let g:rainbow_active = 1
"""" coc
if system('id -u') > 999 " stop downloading on root
  let g:coc_global_extensions = [ 'coc-markdownlint', 'coc-diagnostic', 'coc-angular', 'coc-css', 'coc-docker', 'coc-flutter-tools', 'coc-git', 'coc-homeassistant', 'coc-html', 'coc-json', 'coc-marketplace', 'coc-prettier', 'coc-pyright', 'coc-rls', 'coc-rust-analyzer', 'coc-scssmodules', 'coc-sh', 'coc-snippets', 'coc-stylelintplus', 'coc-swagger', 'coc-tabnine', 'coc-eslint', 'coc-tsserver', 'coc-webpack', 'coc-yaml' ]
    
endif
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" c-space to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-a> <Plug>(coc-range-select)
xmap <silent> <C-a> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
