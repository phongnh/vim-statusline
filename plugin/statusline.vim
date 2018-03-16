" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

" Window width
let s:small_window_width = 60

" Symbols
let s:symbols = {
            \ 'clipboard': '@',
            \ 'left':      '«',
            \ 'right':     '»',
            \ 'readonly':  'RO',
            \ }

" Alternate status dictionaries
let s:name_dict = {
            \ '__Tagbar__':           'Tagbar',
            \ '__Gundo__':            'Gundo',
            \ '__Gundo_Preview__':    'Gundo Preview',
            \ '[BufExplorer]':        'BufExplorer',
            \ 'NERD_tree':            'NERDTree',
            \ 'NERD_tree_1':          'NERDTree',
            \ '__committia_status__': 'Committia Status',
            \ '__committia_diff__':   'Committia Diff',
            \ '[Plugins]':            'Plugins',
            \ '[Command Line]':       'Command Line',
            \ }

let s:type_dict = {
            \ 'netrw':         'NetrwTree',
            \ 'nerdtree':      'NERDTree',
            \ 'startify':      'Startify',
            \ 'vim-plug':      'VimPlug',
            \ 'help':          'HELP',
            \ 'qf':            '%q %{get(w:, "quickfix_title", "")}',
            \ 'quickfix':      '%q %{get(w:, "quickfix_title", "")}',
            \ 'godoc':         'GoDoc',
            \ 'gedoc':         'GeDoc',
            \ 'gitcommit':     'Commit Message',
            \ 'fugitiveblame': 'FugitiveBlame',
            \ }

function! StatusLine(winnum) abort
    if a:winnum == winnr()
        let stl = ''

        let stl .= s:GetClipboardStatus()

        let stl .= s:ActiveStatusLine(a:winnum)
    else
        let stl = s:InactiveStatusLine(a:winnum)
    endif

    return stl
endfunction

function! s:GetClipboardStatus() abort
    if match(&clipboard, 'unnamed') > -1
        return printf(' %s %s', s:symbols.clipboard, s:symbols.right)
    endif
    return ''
endfunction

function! s:GetTabsOrSpacesStatus(bufnum) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(a:bufnum, '&shiftwidth')
    if getbufvar(a:bufnum, '&expandtab')
        return 'Spaces: ' . shiftwidth
    else
        return 'Tab Size: ' . shiftwidth
    endif
endfunction

function! s:ActiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    let stl = s:GetAlternativeStatus(a:winnum, bufnum)

    if empty(stl)
        let left_ary = []
        let filename = s:GetFileNameAndFlags(a:winnum, bufnum)

        " git branch
        if !s:IsSmallWindow(a:winnum) && exists('*fugitive#head')
            let head = fugitive#head()

            if empty(head) && exists('*fugitive#detect') && !exists('b:git_dir')
                call fugitive#detect(getcwd())
                let head = fugitive#head()
            endif

            let winwidth = winwidth(a:winnum) - 2
            let len = strlen(head)
            if len > 0 && len < 51 && len < winwidth && (len + strlen(filename) + 3) < winwidth
                call add(left_ary, head)
            endif
        endif

        " file name %f
        call add(left_ary, filename)

        let stl .= ' %<' . join(left_ary, printf(' %s ', s:symbols.right))
    endif

    let stl .= '%*'

    " right side
    let stl .= ' %=%<'

    let type = s:GetBufferType(bufnum)
    let name = s:GetBufferName(bufnum)

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

        " tabs/spaces
        if !s:IsSmallWindow(a:winnum) && !(&spell && &paste)
            call add(right_ary, s:GetTabsOrSpacesStatus(bufnum))
        endif

        " file type
        if strlen(type)
            call add(right_ary, type)
        endif

        " spell status
        if &spell 
            call add(right_ary, printf('SPELL [%s]', toupper(substitute(&spelllang, ',', '/', 'g'))))
        endif

        " paste status
        if &paste
            call add(right_ary, 'PASTE')
        endif

        let stl .= join(right_ary, printf(' %s ', s:symbols.left))
    endif

    let stl .= ' '

    return stl
endfunction

function! s:InactiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    let stl = s:GetAlternativeStatus(a:winnum, bufnum)

    if empty(stl)
        " file name %f
        let stl .=  printf(' %%<%s %s %s', s:symbols.left, s:GetFileNameAndFlags(a:winnum, bufnum), s:symbols.right)
    endif

    return stl
endfunction

function! s:GetAlternativeStatus(winnum, bufnum) abort
    let type = s:GetBufferType(a:bufnum)
    let name = s:GetBufferName(a:bufnum)

    let stl = ''

    if has_key(s:name_dict, name)
        let stl = ' ' . get(s:name_dict, name)
    elseif has_key(s:type_dict, type)
        let stl = ' ' . get(s:type_dict, type)

        if type ==? 'help'
            let stl .= ' %<' . s:GetFileName(a:winnum, a:bufnum)
        endif
    endif

    return stl
endfunction

function! s:GetFileNameAndFlags(winnum, bufnum) abort
    return s:GetFileName(a:winnum, a:bufnum) . s:GetFileFlags(a:bufnum)
endfunction

function! s:GetFileName(winnum, bufnum) abort
    let name = bufname(a:bufnum)

    if empty(name)
        let name = '[No Name]'
    else
        let name = fnamemodify(name, ':~:.')
        let winwidth = winwidth(a:winnum) - 2

        if strlen(name) > winwidth
            let name = substitute(name, '\v\w\zs.{-}\ze(\\|/)', '', 'g')

            if strlen(name) > winwidth
                let name = fnamemodify(name, ':t')
            endif
        endif
    endif

    return name
endfunction

function! s:GetFileFlags(bufnum)
    let flags = ''

    " file modified and modifiable
    if getbufvar(a:bufnum, '&modified')
        if !getbufvar(a:bufnum, '&modifiable')
            let flags .= '[-+]'
        else
            let flags .= '[+]'
        endif
    elseif !getbufvar(a:bufnum, '&modifiable')
        let flags .= '[-]'
    endif

    if getbufvar(a:bufnum, '&readonly')
        let flags .= ' ' . s:symbols.readonly
    endif

    return flags
endfunction

function! s:GetBufferType(bufnum) abort
    let type = getbufvar(a:bufnum, '&filetype')

    if empty(type)
        let type = getbufvar(a:bufnum, '&buftype')
    endif

    return type
endfunction

function! s:GetBufferName(bufnum) abort
    return fnamemodify(bufname(a:bufnum), ':t')
endfunction

function! s:ShowMoreFileInfo(type, name) abort
    return !has_key(s:name_dict, a:name) && !has_key(s:type_dict, a:type)
endfunction

function! s:IsSmallWindow(winnum) abort
    return winwidth(a:winnum) < s:small_window_width
endfunction

function! s:RefreshStatusLine() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

command! RefreshStatusLine :call s:RefreshStatusLine()

augroup VimStatusline
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter,CmdWinEnter,CmdlineEnter * call <SID>RefreshStatusLine()
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

" ZoomWin Integration
let s:ZoomWin_funcref = []

if exists('g:ZoomWin_funcref')
    if type(g:ZoomWin_funcref) == 2
        let s:ZoomWin_funcref = [g:ZoomWin_funcref]
    elseif type(g:ZoomWin_funcref) == 3
        let s:ZoomWin_funcref = g:ZoomWin_funcref
    endif
endif

function! ZoomWinStatusLine(zoomstate) abort
    for f in s:ZoomWin_funcref
        if type(f) == 2
            call f(a:zoomstate)
        endif
    endfor

    call s:RefreshStatusLine()
endfunction

let g:ZoomWin_funcref= function('ZoomWinStatusLine')
