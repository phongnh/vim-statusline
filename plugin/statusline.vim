" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

" Settings
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 1)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_file_size        = get(g:, 'statusline_show_file_size', 1)

" Window width
let s:small_window_width = 60

" Number of displayable tabs
let s:displayable_tab_count = 5

" Symbols
let s:symbols = {
            \ 'clipboard': '@',
            \ 'left':      '«',
            \ 'right':     '»',
            \ 'readonly':  '',
            \ 'ellipsis':  '…',
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
            \ 'vim-plug':      'Plug',
            \ 'help':          'HELP',
            \ 'qf':            '%q %{get(w:, "quickfix_title", "")}',
            \ 'quickfix':      '%q %{get(w:, "quickfix_title", "")}',
            \ 'godoc':         'GoDoc',
            \ 'gedoc':         'GeDoc',
            \ 'gitcommit':     'Commit Message',
            \ 'fugitiveblame': 'FugitiveBlame',
            \ }

" Hightlight mappings
let g:statusline_colors = {
            \ 'LeftStatus':     'StatusLine',
            \ 'InactiveStatus': 'StatusLineNC',
            \ 'FillStatus':     'LineNr',
            \ 'RightStatus':    'StatusLine',
            \ 'TabTitle':       'CursorLineNr',
            \ 'TabPlaceholder': 'LineNr',
            \ 'SelectedTab':    'TabLineSel',
            \ 'NormalTab':      'TabLine',
            \ 'FillTab':        'LineNr',
            \ 'CloseButton':    'CursorLineNr',
            \ }

function! s:HiSection(section) abort
    return printf('%%#%s#', g:statusline_colors[a:section])
endfunction

function! StatusLine(winnum) abort
    if a:winnum == winnr()
        let stl = s:HiSection('LeftStatus')
        let stl .= s:GetClipboardStatus()
        let stl .= s:ActiveStatusLine(a:winnum)
    else
        let stl = s:HiSection('InactiveStatus')
        let stl .= s:InactiveStatusLine(a:winnum)
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
    return (getbufvar(a:bufnum, '&expandtab') ? 'Spaces' : 'Tab Size') . ': ' . shiftwidth
endfunction

function! s:GetTabsOrSpacesShortStatus(bufnum) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(a:bufnum, '&shiftwidth')
    return printf(getbufvar(a:bufnum, '&expandtab') ? '[S:%d]' : '[T:%d]', shiftwidth)
endfunction

function! s:GetGitBranch() abort
    let branch = ''

    if exists('*fugitive#head')
        let branch = fugitive#head()

        if empty(branch) && exists('*fugitive#detect') && !exists('b:git_dir')
            call fugitive#detect(getcwd())
            let branch = fugitive#head()
        endif
    elseif exists(':Gina') == 2
        let branch = gina#component#repo#branch()
    endif

    return branch
endfunction

function! s:IsDisplayableBranch(branch, filename, winwidth) abort
    return strlen(a:branch) < a:winwidth && (strlen(a:branch) + strlen(a:filename) + 3) < a:winwidth
endfunction

function! s:FormatBranch(branch, filename, winwidth) abort
    let branch = a:branch

    if !s:IsDisplayableBranch(branch, a:filename, a:winwidth)
        let branch = s:ShortenFileName(branch)
    endif

    if !s:IsDisplayableBranch(branch, a:filename, a:winwidth)
        let branch = split(branch, '/')[-1]
    endif

    if !s:IsDisplayableBranch(branch, a:filename, a:winwidth) && strlen(branch) > 30
        let branch = strcharpart(branch, 0, 29) . s:symbols.ellipsis
    endif

    if !s:IsDisplayableBranch(branch, a:filename, a:winwidth)
        let branch = ''
    endif

    return branch
endfunction

" Copied from https://github.com/ahmedelgabri/dotfiles/blob/master/files/vim/.vim/autoload/statusline.vim
function! s:FileSize() abort
    let l:size = getfsize(expand('%'))
    if l:size == 0 || l:size == -1 || l:size == -2
        return ''
    endif
    if l:size < 1024
        return l:size . ' bytes'
    elseif l:size < 1024 * 1024
        return printf('%.1f', l:size / 1024.0) . 'k'
    elseif l:size < 1024 * 1024 * 1024
        return printf('%.1f', l:size / 1024.0 / 1024.0) . 'm'
    else
        return printf('%.1f', l:size / 1024.0 / 1024.0 / 1024.0) . 'g'
    endif
endfunction

function! s:ActiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    let stl = s:GetAlternativeStatus(a:winnum, bufnum)

    if empty(stl)
        let left_ary = []
        let filename = s:GetFileNameAndFlags(a:winnum, bufnum)

        " file name %f
        call add(left_ary, filename)

        " git branch
        if !s:IsSmallWindow(a:winnum) && g:statusline_show_git_branch
            let branch = s:GetGitBranch()

            if strlen(branch)
                let branch = s:FormatBranch(branch, filename, winwidth(a:winnum) - 2)
            endif

            if strlen(branch)
                call add(left_ary, branch)
            endif
        endif

        let stl .= ' %<' . join(left_ary, printf(' %s ', s:symbols.right)) . ' '
    endif

    let stl .= '%*'

    " fill
    let stl .= s:HiSection('FillStatus') . ' %='

    let type = s:GetBufferType(bufnum)
    let name = s:GetBufferName(bufnum)

    " right side
    if s:ShowMoreFileInfo(type, name)
        let stl .= s:HiSection('RightStatus') . ' %<'

        let right_ary = []

        if g:statusline_show_file_size
            call add(right_ary, s:FileSize())
        endif

        let show_tabs_spaces = !s:IsSmallWindow(a:winnum)
        let is_short_status = show_tabs_spaces && &paste && &spell

        " paste status
        if &paste
            call add(right_ary, is_short_status ? '[P]' : 'PASTE')
        endif

        " spell status
        if &spell
            call add(right_ary, printf(is_short_status ? '[%s]' : 'SPELL [%s]', toupper(substitute(&spelllang, ',', '/', 'g'))))
        endif

        " tabs/spaces
        if is_short_status
            call add(right_ary, s:GetTabsOrSpacesShortStatus(bufnum))
        elseif show_tabs_spaces
            call add(right_ary, s:GetTabsOrSpacesStatus(bufnum))
        endif

        " file type
        if exists('*WebDevIconsGetFileTypeSymbol')
            call add(right_ary, WebDevIconsGetFileTypeSymbol() . ' ')
        elseif strlen(type)
            call add(right_ary, type)
        endif

        " file encoding
        let encoding = getbufvar(bufnum, '&fileencoding')
        if empty(encoding)
            let encoding = getbufvar(bufnum, '&encoding')
        endif

        if strlen(encoding) && encoding !=# 'utf-8'
            call add(right_ary, encoding)
        endif

        " file format
        if exists('*WebDevIconsGetFileFormatSymbol')
            call add(right_ary, WebDevIconsGetFileFormatSymbol() . ' ')
        else
            let format  = getbufvar(bufnum, '&fileformat')
            if strlen(format) && format !=# 'unix'
                call add(right_ary, format)
            endif
        endif

        let stl .= join(right_ary, printf(' %s ', s:symbols.left)) . ' '
    endif

    return stl
endfunction

function! s:InactiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    let stl = s:GetAlternativeStatus(a:winnum, bufnum)

    if empty(stl)
        " file name %f
        let stl .=  printf(' %%<%s %s %s ', s:symbols.left, s:GetFileNameAndFlags(a:winnum, bufnum), s:symbols.right)
    endif

    return stl
endfunction

function! s:GetAlternativeStatus(winnum, bufnum) abort
    let type = s:GetBufferType(a:bufnum)
    let name = s:GetBufferName(a:bufnum)

    let stl = ''

    if has_key(s:name_dict, name)
        let stl = ' ' . get(s:name_dict, name) . ' '
    elseif has_key(s:type_dict, type)
        let stl = ' ' . get(s:type_dict, type)

        if type ==? 'help'
            let stl .= ' %<' . s:GetFileName(a:winnum, a:bufnum)
        endif

        let stl .= ' '
    endif

    return stl
endfunction

function! s:GetFileNameAndFlags(winnum, bufnum) abort
    return s:GetFileName(a:winnum, a:bufnum) . s:GetFileFlags(a:bufnum)
endfunction

function! s:ShortenFileName(filename) abort
    " return substitute(a:filename, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
    return pathshorten(a:filename)
endfunction

function! s:GetFileName(winnum, bufnum) abort
    let name = bufname(a:bufnum)

    if empty(name)
        let name = '[No Name]'
    else
        let name = fnamemodify(name, ':~:.')
        let winwidth = winwidth(a:winnum) - 2

        if strlen(name) > winwidth
            let name = s:ShortenFileName(name)

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
        let flags .= ' ' . s:symbols.readonly . ' '
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

function! s:TabPlaceholder(tab)
    return s:HiSection('TabPlaceholder') . printf('%%%d  %s %%*', a:tab, s:symbols.ellipsis)
endfunction

function! s:TabLabel(tabnr) abort
    let tabnr = a:tabnr
    let winnr = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, '&modified')
    let buftype = getbufvar(bufnr, 'buftype')

    let label = '%' . tabnr . 'T'
    let label .= (tabnr == tabpagenr() ? s:HiSection('SelectedTab') : s:HiSection('NormalTab'))
    let label .= ' ' . tabnr . ':'

    if buftype == 'nofile'
        if bufname =~ '\/.'
            let bufname = substitute(bufname, '.*\/\ze.', '', '')
        endif
    else
        let bufname = fnamemodify(bufname, ':p:~:.')
        if bufname[0] == '~' || bufname[0] == '/'
            let bufname = pathshorten(bufname)
        elseif strlen(bufname) > 30
            let bufname = fnamemodify(bufname, ':t')
        endif

        if exists('*WebDevIconsGetFileTypeSymbol')
            let bufname .= WebDevIconsGetFileTypeSymbol() . ' '
        endif
    endif

    if bufname == ''
        let bufname = '[No Name]'
    endif

    let label .= ' ' . bufname . ' '

    if bufmodified
        let label .= '[+] '
    endif

    return label
endfunction

function! Tabline() abort
    let st = s:HiSection('TabTitle') . ' TABS %*'

    let tab_count = tabpagenr('$')
    let max_tab_count = s:displayable_tab_count

    if tab_count <= max_tab_count
        for i in range(1, tab_count)
            let st .= s:TabLabel(i)
        endfor
    else
        let tabs = range(1, tab_count)
        let current_tab = tabpagenr()
        let current_index = current_tab - 1

        if current_tab == 1
            let start_index = 0
            let end_index = start_index + (max_tab_count - 1)
        elseif current_tab == tab_count
            let end_index = -1
            let start_index = end_index - (max_tab_count - 1)
        else
            let start_index = current_index - (max_tab_count - 2)
            let start_index = max([start_index, 0])
            let end_index = start_index + (max_tab_count - 1)
        endif

        if start_index > 0
            let st .= s:TabPlaceholder(start_index + 1)
        endif
        
        let displayable_tabs = tabs[start_index:end_index]

        for i in displayable_tabs
            let st .= s:TabLabel(i)
        endfor

        if end_index < (tab_count - 1)
            let st .= s:TabPlaceholder(end_index + 1)
        endif
    endif

    let st .= s:HiSection('FillTab')
    if g:statusline_show_tab_close_button
        let st .= s:HiSection('CloseButton') . '%=%999X X '
    endif

    return st
endfunction

setglobal tabline=%!Tabline()

augroup VimStatusline
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter,CmdWinEnter,CmdlineEnter * call <SID>RefreshStatusLine()
    autocmd VimEnter * setglobal tabline=%!Tabline()
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
