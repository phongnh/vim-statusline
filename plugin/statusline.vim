" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

" Settings
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 1)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_file_size        = get(g:, 'statusline_show_file_size', 1)

" Disable NERDTree statusline
let g:NERDTreeStatusline = -1

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
let s:filename_modes = {
            \ '__Tagbar__':           'Tagbar',
            \ '__Gundo__':            'Gundo',
            \ '__Gundo_Preview__':    'Gundo Preview',
            \ '[BufExplorer]':        'BufExplorer',
            \ '[Command Line]':       'Command Line',
            \ '[Plugins]':            'Plugins',
            \ '__committia_status__': 'Committia Status',
            \ '__committia_diff__':   'Committia Diff',
            \ }

let s:filetype_modes = {
            \ 'ctrlp':             'CtrlP',
            \ 'leaderf':           'LeaderF',
            \ 'netrw':             'NetrwTree',
            \ 'nerdtree':          'NERDTree',
            \ 'startify':          'Startify',
            \ 'vim-plug':          'Plug',
            \ 'help':              'HELP',
            \ 'qf':                '%q',
            \ 'godoc':             'GoDoc',
            \ 'gedoc':             'GeDoc',
            \ 'gitcommit':         'Commit Message',
            \ 'fugitiveblame':     'FugitiveBlame',
            \ 'gitmessengerpopup': 'Git Messenger',
            \ 'agit':              'Agit',
            \ 'agit_diff':         'Agit Diff',
            \ 'agit_stat':         'Agit Stat',
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
            \ 'CtrlP':          'Character',
            \ }

if exists('*trim')
    function! s:strip(str) abort
        return trim(a:str)
    endfunction
else
    function! s:strip(str) abort
        return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endfunction
endif

function! s:HiSection(section) abort
    return printf('%%#%s#', g:statusline_colors[a:section])
endfunction

function! s:GetCurrentDir() abort
    let dir = fnamemodify(getcwd(), ':~:.')
    if empty(dir)
        let dir = getcwd()
    endif
    return dir
endfunction

function! s:IsSmallWindow(winnum) abort
    return winwidth(a:winnum) < s:small_window_width
endfunction

function! s:GetClipboardStatus() abort
    if match(&clipboard, 'unnamed') > -1
        return printf(' %s %s', s:symbols.clipboard, s:symbols.right)
    endif
    return ''
endfunction

function! s:GetBufferType(bufnum) abort
    let type = getbufvar(a:bufnum, '&filetype')

    if empty(type)
        let type = getbufvar(a:bufnum, '&buftype')
    endif

    return type
endfunction

function! s:ShortenFileName(filename) abort
    if exists('*pathshorten')
        return pathshorten(a:filename)
    else
        return substitute(a:filename, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
    endif
endfunction

function! s:GetFileName(winnum, bufnum) abort
    let name = bufname(a:bufnum)

    if empty(name)
        let name = '[No Name]'
    else
        let name = fnamemodify(name, ':~:.')

        if s:IsSmallWindow(a:winnum)
            return fnamemodify(name, ':t')
        endif

        let winwidth = winwidth(a:winnum) - 2

        if strlen(name) > winwidth && (name[0] == '~' || name[0] == '/')
            let name = s:ShortenFileName(name)
        endif

        if strlen(name) > winwidth
            let name = fnamemodify(name, ':t')
        endif

        if strlen(name) > 50
            let name = s:ShortenFileName(name)
        endif

        if strlen(name) > 50
            let name = fnamemodify(name, ':t')
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

function! s:GetFileNameAndFlags(winnum, bufnum) abort
    return s:GetFileName(a:winnum, a:bufnum) . s:GetFileFlags(a:bufnum)
endfunction

function! s:GetGitBranch() abort
    let branch = ''

    if exists('*FugitiveHead')
        let branch = FugitiveHead()

        if empty(branch) && exists('*FugitiveDetect') && !exists('b:git_dir')
            call FugitiveDetect(getcwd())
            let branch = FugitiveHead()
        endif
    elseif exists('*fugitive#head')
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

function! s:GetTabsOrSpacesStatus(bufnum) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(a:bufnum, '&shiftwidth')
    return printf(getbufvar(a:bufnum, '&expandtab') ? 'Spaces: %d' : 'Tab Size: %d', shiftwidth)
endfunction

function! s:GetTabsOrSpacesShortStatus(bufnum) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(a:bufnum, '&shiftwidth')
    return printf(getbufvar(a:bufnum, '&expandtab') ? '[S:%d]' : '[T:%d]', shiftwidth)
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

function! s:FileEncoding(bufnum) abort
    let encoding = getbufvar(a:bufnum, '&fileencoding')

    if empty(encoding)
        let encoding = getbufvar(a:bufnum, '&encoding')
    endif

    " Show encoding only if it is not utf-8
    if encoding ==# 'utf-8'
        let encoding = ''
    endif

    return encoding
endfunction

function! s:FileFormat(bufnum) abort
    let format = getbufvar(a:bufnum, '&fileformat')

    " Show format only if it is not unix
    if format ==# 'unix'
        let format = ''
    endif

    return format
endfunction

function! s:GetFileInfo(bufnum) abort
    let result = []

    " file type
    let type = s:GetBufferType(a:bufnum)
    if exists('*WebDevIconsGetFileTypeSymbol')
        call add(result, type . ' ' . WebDevIconsGetFileTypeSymbol() . ' ')
    elseif strlen(type)
        call add(result, type)
    endif

    " file encoding
    let encoding = s:FileEncoding(a:bufnum)
    if strlen(encoding)
        call add(result, encoding)
    endif

    " file format
    if exists('*WebDevIconsGetFileFormatSymbol')
        call add(result, WebDevIconsGetFileFormatSymbol() . ' ')
    else
        let format = s:FileFormat(a:bufnum)
        if strlen(format)
            call add(result, format)
        endif
    endif

    if exists('*WebDevIconsGetFileTypeSymbol') && exists('*WebDevIconsGetFileFormatSymbol')
        if len(result) == 2
            let result[0] = s:strip(result[0])
        endif
        let result = [ join(result) ]
    endif

    return result
endfunction

function! s:GetAlternativeStatus(winnum, bufnum) abort
    let type = s:GetBufferType(a:bufnum)
    if has_key(s:filetype_modes, type)
        let l:mode = get(s:filetype_modes, type)

        if type ==# 'help'
            return printf(' %s %%<%s ', l:mode, s:GetFileName(a:winnum, a:bufnum))
        endif

        if type ==# 'qf'
            let l:qf_title = get(w:, 'quickfix_title', '')
            if strlen(l:qf_title)
                return printf(' %s %%<%s ', l:mode, l:qf_title)
            endif
        endif

        return ' ' . l:mode . ' '
    endif

    let name = fnamemodify(bufname(a:bufnum), ':t')
    if has_key(s:filename_modes, name)
        return ' ' . get(s:filename_modes, name) . ' '
    endif

    return ''
endfunction

function! s:ActiveStatusLine(winnum) abort
    " clipboard status
    let stl = s:GetClipboardStatus()

    let bufnum = winbufnr(a:winnum)

    let alt_stl = s:GetAlternativeStatus(a:winnum, bufnum)
    let stl .= alt_stl

    " show only alternative status if any
    let has_no_alternative_status = empty(alt_stl)

    if has_no_alternative_status
        let left_ary = []

        " file name %f
        let filename = s:GetFileNameAndFlags(a:winnum, bufnum)
        call add(left_ary, filename)

        " git branch
        if g:statusline_show_git_branch && !s:IsSmallWindow(a:winnum)
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

    " reset highlight
    let stl .= '%*'

    " fill
    let stl .= s:HiSection('FillStatus') . ' %='

    " right side
    if has_no_alternative_status
        let stl .= s:HiSection('RightStatus') . ' %<'

        let right_ary = []

        " file size
        if g:statusline_show_file_size && !s:IsSmallWindow(a:winnum)
            let file_size = s:FileSize()
            if !empty(file_size)
                call add(right_ary, s:FileSize())
            endif
        endif

        let show_tabs_spaces = !s:IsSmallWindow(a:winnum)
        let show_short_status = show_tabs_spaces && &paste && &spell

        if show_short_status
            " paste status
            if &paste
                call add(right_ary, '[P]')
            endif

            " spell status
            if &spell
                call add(right_ary, printf('[%s]', toupper(substitute(&spelllang, ',', '/', 'g'))))
            endif

            " tabs/spaces
            call add(right_ary, s:GetTabsOrSpacesShortStatus(bufnum))
        else
            " paste status
            if &paste
                call add(right_ary, 'PASTE')
            endif

            " spell status
            if &spell
                call add(right_ary, printf('SPELL [%s]', toupper(substitute(&spelllang, ',', '/', 'g'))))
            endif

            if show_tabs_spaces
                call add(right_ary, s:GetTabsOrSpacesStatus(bufnum))
            endif
        endif

        " file info: type / encoding / format
        call extend(right_ary, s:GetFileInfo(bufnum))

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

function! StatusLine(current, winnum) abort
    if a:current
        let stl = s:HiSection('LeftStatus')
        let stl .= s:ActiveStatusLine(a:winnum)
    else
        let stl = s:HiSection('InactiveStatus')
        let stl .= s:InactiveStatusLine(a:winnum)
    endif

    return stl
endfunction

function! AutoStatusLine(current, winid)
    return StatusLine(a:current, win_id2win(a:winid))
endfunction

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
            let bufname = s:ShortenFileName(bufname)
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

        if current_index == (tab_count - 1)
            let st .= s:TabPlaceholder(start_index - 1)
        elseif start_index > 0
            let st .= s:TabPlaceholder(start_index + 1)
        endif
        
        let displayable_tabs = tabs[start_index:end_index]

        for i in displayable_tabs
            let st .= s:TabLabel(i)
        endfor

        if current_index < (tab_count - 1) && end_index < (tab_count - 1)
            let st .= s:TabPlaceholder(end_index + 1)
        endif
    endif

    let st .= s:HiSection('FillTab')
    if g:statusline_show_tab_close_button
        let st .= s:HiSection('CloseButton') . '%=%999X X '
    endif

    return st
endfunction

function! s:RefreshStatusLine() abort
    for nr in range(1, winnr('$'))
        if nr == winnr()
            call setwinvar(nr, '&statusline', '%!StatusLine(1,' . nr . ')')
        else
            call setwinvar(nr, '&statusline', '%!StatusLine(0,' . nr . ')')
        endif
    endfor
endfunction

command! RefreshStatusLine :call s:RefreshStatusLine()

function! s:Init() abort
    execute 'set statusline=%!AutoStatusLine(1,' . win_getid() . ')'
    augroup VimAutoStatusline
        autocmd!
        autocmd BufWinEnter,WinEnter * execute 'setlocal statusline=%!AutoStatusLine(1,' . win_getid('#') . ')'
        autocmd WinLeave * execute 'setlocal statusline=%!AutoStatusLine(0,' . win_getid() . ')'
        if exists('#CmdlineLeave') && exists('#CmdWinEnter') && exists('#CmdlineEnter')
            autocmd CmdlineLeave : execute 'setlocal statusline=%!AutoStatusLine(1,' . win_getid() . ')'
            autocmd CmdWinEnter  : execute 'setlocal statusline=%!AutoStatusLine(1,0)'
            autocmd CmdlineEnter : execute 'setlocal statusline=%!AutoStatusLine(0,' . win_getid() . ')'
        endif
    augroup END

    if exists('+tabline')
        set tabline=%!Tabline()
    endif
endfunction

call s:Init()

" CtrlP Integration
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPMainStatusLine',
            \ 'prog': 'CtrlPProgressStatusLine',
            \ }

function! CtrlPMainStatusLine(focus, byfname, regex, prev, item, next, marked) abort
    let focus   = s:HiSection('FillStatus') . ' ' . a:focus . ' %*'
    let byfname = s:HiSection('CtrlP') . ' ' . a:byfname . ' %*'
    let item    = s:HiSection('CtrlP') . ' ' . a:item . ' %*'
    let dir     = s:GetCurrentDir()
    return printf(' %s CtrlP %s %s %s %s %s %s %%=%s%%<%s%s %s %s ',
                \ s:HiSection('LeftStatus'),
                \ s:symbols.right,
                \ a:prev,
                \ item,
                \ a:next,
                \ a:marked,
                \ s:HiSection('FillStatus'),
                \ s:HiSection('RightStatus'),
                \ focus,
                \ byfname,
                \ s:symbols.left,
                \ dir)
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

let &cpo = s:save_cpo
unlet s:save_cpo
