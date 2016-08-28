" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

" Symbols
let s:symbols = {
            \ 'clipboard': '@',
            \ 'left':      '«',
            \ 'right':     '»',
            \ 'readonly':  'RO',
            \ }

" Statusline
let s:name_dict = {
            \ '__Tagbar__':        'Tagbar',
            \ '__Gundo__':         'Gundo',
            \ '__Gundo_Preview__': 'Gundo Preview',
            \ '[BufExplorer]':     'BufExplorer',
            \ 'NERD_tree':         'NERDTree',
            \ 'NERD_tree_1':       'NERDTree',
            \ '[Plugins]':         'Plugins',
            \ '[Command Line]':    'CommandLine',
            \ }

let s:type_dict = {
            \ 'netrw':         'NetrwTree',
            \ 'nerdtree':      'NERDTree',
            \ 'startify':      'Startify',
            \ 'vim-plug':      'VimPlug',
            \ 'help':          'Help',
            \ 'qf':            'QuickFix',
            \ 'quickfix':      'QuickFix',
            \ 'godoc':         'GoDoc',
            \ 'gedoc':         'GeDoc',
            \ 'gitcommit':     'Fugitive',
            \ 'fugitiveblame': 'FugitiveBlame',
            \ }

function! StatusLine(winnum) abort
    let stl = '%<'

    if a:winnum == winnr()
        if match(&clipboard, 'unnamed') > -1
            let stl .= printf(' %s %s', s:symbols.clipboard, s:symbols.right)
        endif

        let stl .= s:ActiveStatusLine(a:winnum)
    else
        let stl .= s:InactiveStatusLine(a:winnum)
    endif

    return stl
endfunction

function! s:ActiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)
    let type = s:GetBufferType(bufnum)
    let name = fnamemodify(bufname(bufnum), ':t')

    let stl = s:GetAlternativeStatus(type, name)

    if empty(stl)
        let left_ary = []

        " git branch
        if !s:IsTinyWindow() && exists('*fugitive#head')
            let head = fugitive#head()

            if empty(head) && exists('*fugitive#detect') && !exists('b:git_dir')
                call fugitive#detect(getcwd())
                let head = fugitive#head()
            endif

            if strlen(head)
                call add(left_ary, head)
            endif
        endif

        " file name %f
        call add(left_ary, s:GetFileName(bufnum))

        let stl .= ' ' . join(left_ary, printf(' %s ', s:symbols.right))
    endif

    let stl .= '%*'

    " right side
    let stl .= '%='

    if s:ShowMoreFileInfo(type, name)
        let right_ary = []

        " file encoding
        let encoding = getbufvar(bufnum, '&fileencoding')
        if empty(encoding)
            let encoding = getbufvar(bufnum, '&encoding')
        endif

        if strlen(encoding) && encoding !=# 'utf-8'
            call add(right_ary, encoding)
        endif

        " file format
        let format  = getbufvar(bufnum, '&fileformat')
        if strlen(format) && format !=# 'unix'
            call add(right_ary, format)
        endif

        " file type
        if strlen(type)
            call add(right_ary, type)
        endif

        " tabs/spaces
        " let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(bufnum, '&shiftwidth')
        " if getbufvar(bufnum, '&expandtab')
        "     call add(right_ary, 'Spaces:' . shiftwidth)
        " else
        "     call add(right_ary, 'TabSize:' . shiftwidth)
        " endif

        let stl .= join(right_ary, printf(' %s ', s:symbols.left))
    endif

    let stl .= ' '

    return stl
endfunction

function! s:InactiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)
    let type = s:GetBufferType(bufnum)
    let name = fnamemodify(bufname(bufnum), ':t')

    let stl = s:GetAlternativeStatus(type, name)

    if empty(stl)
        " file name %f
        let stl .=  printf(' %s %s %s', s:symbols.left, s:GetFileName(bufnum), s:symbols.right)
    endif

    return stl
endfunction

function! s:GetAlternativeStatus(type, name) abort
    let stl = ''

    if has_key(s:name_dict, a:name)
        let stl = ' ' . get(s:name_dict, a:name) . ' '
    elseif has_key(s:type_dict, a:type)
        let stl = ' ' . get(s:type_dict, a:type) . ' '

        if a:type ==? 'help'
            let stl .= fnamemodify(bufname('%'), ':~') . ' '
        endif
    endif

    return stl
endfunction


function! s:ShowMoreFileInfo(type, name) abort
    return !s:IsSmallWindow() && !s:HaveAlternateStatus(a:type, a:name)
endfunction

function! s:HaveAlternateStatus(type, name) abort
    return has_key(s:name_dict, a:name) || has_key(s:type_dict, a:type)
endfunction

function! s:GetFileName(bufnum) abort
    let name = bufname(a:bufnum)

    if empty(name)
        let name = '[No Name]'
    else
        let name = fnamemodify(name, ':~:.')

        if s:IsTinyWindow()
            let name = fnamemodify(name, ':t')
        elseif s:IsSmallWindow()
            let name = substitute(name, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
        endif
    endif

    " file modified and modifiable
    if getbufvar(a:bufnum, '&modified')
        if !getbufvar(a:bufnum, '&modifiable')
            let name .= '[-+]'
        else
            let name .= '[+]'
        endif
    elseif !getbufvar(a:bufnum, '&modifiable')
        let name .= '[-]'
    endif

    if getbufvar(a:bufnum, '&readonly')
        let name .= ' ' . s:symbols.readonly
    endif

    return name
endfunction

function! s:GetBufferType(bufnum) abort
    let type = getbufvar(a:bufnum, '&filetype')

    if empty(type)
        let type = getbufvar(a:bufnum, '&buftype')
    endif

    return type
endfunction

function! s:IsSmallWindow() abort
    return winwidth(0) < 50
endfunction

function! s:IsTinyWindow() abort
    return winwidth(0) < 30
endfunction

function! s:RefreshStatusLine() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

command! RefreshStatusLine :call s:RefreshStatusLine()

augroup vim-statusline
    autocmd!
    autocmd VimEnter,VimLeave,WinEnter,WinLeave,BufWinEnter,BufWinLeave * :RefreshStatusLine
augroup END

" CtrlP Integration
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPMainStatusLine',
            \ 'prog': 'CtrlPProgressStatusLine',
            \ }

function! CtrlPMainStatusLine(focus, byfname, regex, prev, item, next, marked) abort
    let focus   = '%#LineNr# ' . a:focus . ' %*'
    let byfname = '%#Character# ' . a:byfname . ' %*'
    let item    = '%#Character# ' . a:item . ' %*'
    let dir     = s:GetCurrentDir()
    return printf(' CtrlP %s %s %s %s %s %%=%%<%s%s %s ', s:symbols.right, a:prev, item, a:next, a:marked, focus, byfname, dir)
endfunction

function! CtrlPProgressStatusLine(len) abort
    return printf(' %s %%=%%< %s ', a:len, s:GetCurrentDir())
endfunction

" Tagbar Integration
let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, flags, ...) abort
    if empty(a:flags)
        return printf(' [%s] %s %s', a:sort, s:symbols.right, a:fname)
    else
        return printf(' [%s] [%s] %s %s', a:sort, join(a:flags, ''), s:symbols.right, a:fname)
    endif
endfunction

function! s:GetCurrentDir() abort
    let dir = fnamemodify(getcwd(), ':~:.')
    if empty(dir)
        let dir = getcwd()
    endif
    return dir
endfunction
