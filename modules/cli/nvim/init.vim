nnoremap <F5> :UndotreeToggle <CR>
" flutter
let g:dart_format_on_save = 1
" endflutter
let g:nnn#set_default_mappings = 0
let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.6, 'highlight': 'Debug' } }
nnoremap <tab> ::NnnPicker %:p:h<CR>
imap <C-q> <C-x><C-o>
let g:UltiSnipsEditSplit = "horizontal"
let g:UltiSnipsSnippetDirectories = ["/etc/nvim/completion"]
let g:UltiSnipsExpandTrigger = "5ß52395834" " Garbage, cause it's handled by coc
let g:UltiSnipsJumpForwardTrigger = "<C-k>"
let g:UltiSnipsJumpBackwardTrigger = "<C-j>"
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
   let g:rainbow_conf = {
    \    'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    \    'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
    \    'operators': '_,_',
    \    'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \    'separately': {
    \        '*': {},
    \        'tex': {
    \            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \        },
    \        'pandoc': {
    \            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \        },
    \        'lisp': {
    \            'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
    \        },
    \        'vim': {
    \            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
    \        },
    \        'html': {
    \            'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \        },
    \        'css': 0,
    \    }
    \}


map /  <Plug>(incsearch-forward)
" COC
let g:coc_config_home = '/etc/nvim/'
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'
map ,f :CocFix<CR>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
command! -nargs=0 Prettier :CocCommand prettier.formatFile
" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"


" coc Plugins
"
if system('id -u') > 999 " stop downloading on root
  let g:coc_global_extensions = [ 'coc-markdownlint', 'coc-diagnostic', 'coc-angular', 'coc-css', 'coc-docker', 'coc-flutter-tools', 'coc-git', 'coc-homeassistant', 'coc-html', 'coc-json', 'coc-marketplace', 'coc-prettier', 'coc-pyright', 'coc-rls', 'coc-rust-analyzer', 'coc-scssmodules', 'coc-sh', 'coc-snippets', 'coc-stylelintplus', 'coc-swagger', 'coc-tabnine', 'coc-eslint', 'coc-tsserver', 'coc-ultisnips', 'coc-webpack', 'coc-yaml' ]
    
endif


"" Use <C-l> for trigger snippet expand.
"imap <C-l> <Plug>(coc-snippets-expand)
"
"" Use <C-j> for select text for visual placeholder of snippet.
"vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
set cmdheight=2

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> ,h <Plug>(coc-diagnostic-prev)
nmap <silent> ,l <Plug>(coc-diagnostic-next)
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap ,rn <Plug>(coc-rename)
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)


" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" lightline
"
set laststatus=2

let g:lightline = {
     \ 'colorscheme': 'gruvbox',
     \ }
let g:lightline.component_function = {
      \ 'gitbranch': 'fugitive#head',
      \ 'linter':    'coc#status',
      \ 'filetype': 'MyFiletype',
      \ 'fileformat': 'MyFileformat'
      \ }
let g:lightline.active = {
      \ 'left':  [
      \            [ 'mode', 'paste' ],
      \            [ 'gitbranch', 'readonly', 'filename', 'modified' ]
      \          ],
      \ 'right': [
      \            [ 'linter' ],
      \            [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype']
      \          ]
      \ }
let g:lightline.enable = {
     \ 'statusline': 1,
     \ 'tabline': 1
     \ }

  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ' '
  endfunction
  
  function! MyFileformat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ' '
  endfunction

let g:gruvbox_italic=1
colorscheme gruvbox
set termguicolors " 24bit color
set background=dark " dark gruvbox
set nocompatible
filetype plugin on
filetype indent plugin on
filetype plugin indent on
syntax on
set noshowmode " disables mode showing, unnessesary thanks to lightline
set t_ut= " disables the weird black artifacts while scrolling
set encoding=utf-8
set number
set relativenumber
set undodir=~/.local/share/nvim/undo-dir " setup undo directory
set undofile                " save undo chages even after computer restart
set showcmd                 " show (partial) command in status line
set showmatch               " show match brackets
set wildmenu                " visual autocomplete for command menu
set ttyfast
set spelllang=de_20,en_us
set hidden " steht so im wiki von coc
set spell
let mapleader = ','
let maplocalleader = '#'
" Lower Updatetime for Pandoc live preview to work better
set updatetime=250
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow
set splitright

cmap w!! w !sudo tee > /dev/null %

" indent settings
set expandtab
set shiftwidth=2
set softtabstop=2

"" Binds
noremap <F3> :call CocAction('format')<CR>

" resize binds
" Splitting (A-HJKL to resizee)
noremap <A-h> :vertical resize -5<CR>
noremap <A-l> :vertical resize +5<CR>
noremap <A-j> :resize -5<CR>
noremap <A-k> :resize +5<CR>

" cocaction
nmap ,a  <Plug>(coc-codeaction)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

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

" Make man open o
" map ,.
map ,m :GFiles<CR> 
map ,v :Vista!!<CR> 

" Make ,q close vim
map ,q :bd<CR>
map ,wq :wq<CR>
map ,b :Buffers<CR>
nnoremap <A-s> :vsp<CR>
nnoremap <C-s> :split<CR>
map <C-t> :tabnew<CR>


map ,c :Commentary<CR>

" Make Copy paste with other programs work (Needs GVim installed)
vnoremap <C-c> "+y
map <C-b> "+P

" Shortcutting split navigation, saving a keypress:
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
" C-T for new tab
" nnoremap <C-t> :tabnew<cr>
" C-R to list registers
noremap <C-p> :registers<CR>

# make terminal usable(TM)
augroup neovim_terminal
    autocmd!
    " Enter Terminal-mode (insert) automatically
    autocmd TermOpen * startinsert
    " Disables number lines on terminal buffers
    autocmd TermOpen * :set nonumber norelativenumber
    " allows you to use Ctrl-c on terminal window
    autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
augroup END

" Making Space usable outside of guides (lagreducing) (thanks
" https://www.reddit.com/r/vim/comments/97s3dd/insert_mode_space_is_slow/e4asdjy)
"set timeout ttimeout         " separate mapping and keycode timeouts
set timeoutlen=150           " mapping timeout 250ms  (adjust for preference)
"set ttimeoutlen=10           " keycode timeout 20ms

autocmd FileType pandoc map ,lp :LLPStartPreview<Enter>
autocmd Filetype pandoc let g:table_mode_corner_corner='+'
autocmd FileType pandoc set nofoldenable
let g:pandoc#hypertext#create_if_no_alternates_exists=1
" Buffers
set hidden
" set switchbuf=usetab,newtab
set showtabline=2 "Always show tab line


" yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

let g:livepreview_arguments = "--filter pandoc-plantuml --filter pandocode --listing -V pagesize=a4 --pdf-engine=pdflatex"
let g:livepreview_previewer = "zathura"
