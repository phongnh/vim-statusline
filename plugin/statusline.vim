" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

" Statusline
let s:name_dict = {
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
    let stl .= match(&clipboard, 'unnamed') > -1 ? ' @ ' : ''

    if a:winnum == winnr()
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

    let stl = ''

    let status = s:AlternativeStatus(type, fnamemodify(name, ':t'))
    if strlen(status)
        let stl .= ' ' . status . ' '
    endif

    if s:DisplayFileName(type, name)
        " git branch
        if exists('*fugitive#head')
            let head = fugitive#head()

            if empty(head) && exists('*fugitive#detect') && !exists('b:git_dir')
                call fugitive#detect(getcwd())
                let head = fugitive#head()
            endif

            if strlen(head)
                let stl .= ' ' . head . ' '
            endif
        endif

        " file name
        let stl .= ' %f'

        " file modified and modifiable
        let modified = getbufvar(bufnum, '&modified')
        let modifiable = getbufvar(bufnum, '&modifiable')
        let stl .= modified ? (!modifiable ? '[+-]' : '[+]') : ''

        " read only
        let readonly = getbufvar(bufnum, '&readonly')
        let stl .= readonly ? ' RO' : ''
    endif

    let stl .= '%*'

    " right side
    let stl .= '%='

    if s:DisplayFileInfo(type, name)
        " file type
        let stl .= strlen(type) ? ' ' . type . ' ' : ''

        " file encoding
        let fileencoding = getbufvar(bufnum, '&fileencoding')
        if empty(fileencoding)
            let fileencoding = getbufvar(bufnum, '&encoding')
        endif
        let stl .= empty(fileencoding) || fileencoding ==# 'utf-8' ? '' : (' ' . fileencoding . ' ')

        " file format
        let fileformat = getbufvar(bufnum, '&fileformat')
        let stl .= empty(fileformat) || fileformat ==# 'unix' ? '' : ' ' . fileformat . ' '
    endif

    if s:DisplayPercentage(type, name)
        " percentage, line number and colum number
        let stl .= ' %3p%% : %4l:%3c '
    endif

    return stl
endfunction

function! s:InactiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)
    let type = s:GetBufferType(bufnum)
    let name = fnamemodify(bufname(bufnum), ':t')

    let stl = ''

    let status = s:AlternativeStatus(type, name)
    if strlen(status)
        let stl .=  ' ' . status . ' '
    endif

    if s:DisplayFileName(type, name)
        " file name
        let stl .= ' %f'
    endif

    return stl
endfunction

function! s:AlternativeStatus(type, name) abort
    let stl = ''
    if has_key(s:name_dict, a:name)
        let stl = get(s:name_dict, a:name)
    elseif has_key(s:type_dict, a:type)
        let stl = get(s:type_dict, a:type)
        if a:type ==? 'help'
            let stl .= ' ' . a:name
        endif
    endif
    return stl
endfunction

function! s:DisplayFileName(type, name) abort
    if has_key(s:name_dict, a:name) || has_key(s:type_dict, a:type)
        return 0
    else
        return 1
    endif
endfunction

function! s:DisplayFileInfo(type, name) abort
    if winwidth(0) < 50 || has_key(s:name_dict, a:name) || has_key(s:type_dict, a:type)
        return 0
    else
        return 1
    endif
endfunction

function! s:DisplayPercentage(type, name) abort
    if winwidth(0) < 50 || has_key(s:name_dict, a:name) || a:type =~? 'netrw\|nerdtree\|startify\|vim-plug'
        return 0
    else
        return 1
    end
endfunction

function! s:GetBufferType(bufnum) abort
    let type = getbufvar(a:bufnum, '&filetype')

    if empty(type)
        let type = getbufvar(a:bufnum, '&buftype')
    endif

    return type
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
