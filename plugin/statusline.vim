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
let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 1)

" Disable NERDTree statusline
let g:NERDTreeStatusline = -1

" Window width
let s:small_window_width = 60

" Number of displayable tabs
let s:displayable_tab_count = 5

" Symbols
let s:symbols = {
            \ 'clipboard': 'ⓒ  ',
            \ 'paste':     'Ⓟ  ',
            \ 'arrow':     '←',
            \ 'left':      '»',
            \ 'right':     '«',
            \ 'readonly':  '',
            \ 'ellipsis':  '…',
            \ 'mode_sep':  ' ',
            \ 'fill_sep':  ' ',
            \ }

" Alternative Symbols
" ©: Clipboard
"Ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓟ  : Paste
"Ⓟ  : Paste
"℗  : Paste
"℗  : Paste
" Ρ: Paste
" ρ: Paste
"Ⓡ  : Readonly
"ⓡ  : Readonly
" ® : Readonly

let s:powerline = {
            \ 'left':      '',
            \ 'left_alt':  '',
            \ 'right':     '',
            \ 'right_alt': '',
            \ }

" Support DevIcons
let s:has_devicons = findfile('plugin/webdevicons.vim', &rtp) != ''
" let s:has_devicons = exists('*WebDevIconsGetFileTypeSymbol') && exists('*WebDevIconsGetFileFormatSymbol')

" Alternate status dictionaries
let s:filename_modes = {
            \ 'ControlP':             'CtrlP',
            \ '__CtrlSF__':           'CtrlSF',
            \ '__CtrlSFPreview__':    'Preview',
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
            \ 'vim-plug':          'Plugins',
            \ 'terminal':          'Terminal',
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
            \ 'ActiveStatus':    'StatusLine',
            \ 'InactiveStatus':  'StatusLineNC',
            \ 'StatusSeparator': 'LineNr',
            \ 'TabTitle':        'CursorLineNr',
            \ 'TabPlaceholder':  'LineNr',
            \ 'ActiveTab':       'TabLineSel',
            \ 'InactiveTab':     'TabLine',
            \ 'TabSeparator':    'LineNr',
            \ 'CloseButton':     'CursorLineNr',
            \ 'CtrlP':           'Character',
            \ }

function! s:HiSection(section) abort
    return printf('%%#%s#', g:statusline_colors[a:section])
endfunction

function! s:Strip(str) abort
    if exists('*trim')
        return trim(a:str)
    else
        return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

function! s:Wrap(text) abort
    return printf('%s %s %s', s:symbols.right, a:text, s:symbols.left)
endfunction

function! s:ShortenPath(filename) abort
    if exists('*pathshorten')
        return pathshorten(a:filename)
    else
        return substitute(a:filename, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
    endif
endfunction

function! s:RemoveEmptyElement(list) abort
    return filter(copy(a:list), '!empty(v:val)')
endfunction

function! s:EnsureList(list) abort
    if type(a:list) == type([])
        let l:list = deepcopy(a:list)
    else
        let l:list = [a:list]
    endif
    return l:list
endfunction

function! s:ParseList(list) abort
    let l:list = s:EnsureList(a:list)
    return s:RemoveEmptyElement(l:list)
endfunction

function! s:ParseModeList(list) abort
    let l:list = s:EnsureList(a:list)
    let l:list = map(copy(l:list), "type(v:val) == type([]) ? join(s:RemoveEmptyElement(v:val), s:symbols.mode_sep) : v:val")
    return s:RemoveEmptyElement(l:list)
endfunction

function! s:ParseFillList(list) abort
    let l:list = s:EnsureList(a:list)
    let l:list = map(copy(l:list), "type(v:val) == type([]) ? join(s:RemoveEmptyElement(v:val), s:symbols.fill_sep) : v:val")
    return s:RemoveEmptyElement(l:list)
endfunction

function! s:StatusSeparator() abort
    return s:HiSection('StatusSeparator') . '' . '%=' . ''
endfunction

function! s:BuildMode(parts, sep) abort
    let l:parts = s:ParseModeList(a:parts)
    if empty(l:parts)
        return ''
    endif
    let l:sep = empty(a:sep) ? ' ' : printf(' %s ', a:sep)
    return ' %<' . join(l:parts, l:sep) . ' '
endfunction

function! s:BuildFill(parts, ...) abort
    let l:parts = s:ParseFillList(a:parts)
    if empty(l:parts)
        return ''
    endif
    let l:sep = get(a:, 1, s:symbols.fill_sep)
    return s:HiSection('StatusSeparator') . ' ' . join(l:parts, l:sep) . ' '
endfunction

function! s:BuildLeftStatus(mode, ...) abort
    return s:BuildMode(a:mode, s:symbols.left) . '%*' . s:BuildFill(get(a:, 1, []))
endfunction

function! s:BuildRightStatus(mode, ...) abort
    return s:BuildFill(get(a:, 1, [])) . '%*' . s:BuildMode(a:mode, s:symbols.right)
endfunction

function! s:BuildStatus(left_parts, right_parts) abort
    let left_parts  = s:ParseList(a:left_parts)
    let right_parts = s:ParseList(a:right_parts)

    let stl = s:BuildLeftStatus(left_parts[0], left_parts[1:])
    let stl .= s:StatusSeparator()

    if len(right_parts) > 0
        let stl .= s:BuildRightStatus(right_parts[0], right_parts[1:])
    endif

    return stl
endfunction

function! s:CustomMode(winnum, bufnum) abort
    let ft = s:GetBufferType(a:bufnum)

    if has_key(s:filetype_modes, ft)
        return s:filetype_modes[ft]
    endif

    let bname = fnamemodify(bufname(a:bufnum), ':t')
    if has_key(s:filename_modes, bname)
        return s:filename_modes[bname]
    endif

    return ''
endfunction

function! s:CustomStatus(winnum, bufnum) abort
    let l:mode = ''

    let ft = s:GetBufferType(a:bufnum)
    if has_key(s:filetype_modes, ft)
        let l:mode = s:filetype_modes[ft]

        if ft ==# 'terminal'
            return s:BuildStatus([ [l:mode, '%f'] ], [])
        endif

        if ft ==# 'help'
            return s:BuildStatus([ [l:mode, fnamemodify(bufname(a:bufnum), ':p')] ], [])
        endif

        if ft ==# 'qf'
            let l:qf_title = s:Strip(get(w:, 'quickfix_title', ''))
            return s:BuildStatus([ [l:mode, l:qf_title] ], [])
        endif
    endif

    let bname = fnamemodify(bufname(a:bufnum), ':t')
    if has_key(s:filename_modes, bname)
        let l:mode = s:filename_modes[bname]

        if bname ==# '__CtrlSF__'
            return s:BuildStatus(
                        \ [
                        \   [
                        \       l:mode,
                        \       substitute(ctrlsf#utils#SectionB(), 'Pattern: ', '', '')
                        \   ],
                        \   ctrlsf#utils#SectionC(),
                        \ ],
                        \ ctrlsf#utils#SectionX()
                        \ )
        endif

        if bname ==# '__CtrlSFPreview__'
            return s:BuildStatus([ l:mode, ctrlsf#utils#PreviewSectionC() ], [])
        endif
    endif

    if strlen(l:mode)
        return s:BuildStatus([ l:mode ], [])
    endif

    return ''
endfunction

function! s:IsSmallWindow(winnum) abort
    return winwidth(a:winnum) < s:small_window_width
endfunction

function! s:GetCurrentDir() abort
    let dir = fnamemodify(getcwd(), ':~:.')
    if empty(dir)
        let dir = getcwd()
    endif
    return dir
endfunction

function! s:GetBufferType(bufnum) abort
    let type = getbufvar(a:bufnum, '&filetype')

    if empty(type)
        let type = getbufvar(a:bufnum, '&buftype')
    endif

    return type
endfunction

function! s:GetFileName(winnum, bufnum) abort
    let bname = bufname(a:bufnum)

    if empty(bname)
        return '[No Name]'
    endif

    let bname = fnamemodify(bname, ':~:.')

    if s:IsSmallWindow(a:winnum)
        return fnamemodify(bname, ':t')
    endif

    let winwidth = winwidth(a:winnum) - 2

    if strlen(bname) > winwidth && (bname[0] =~ '\~\|/')
        let bname = s:ShortenPath(bname)
    endif

    if strlen(bname) > winwidth
        let bname = fnamemodify(bname, ':t')
    endif

    if strlen(bname) > 50
        let bname = s:ShortenPath(bname)
    endif

    if strlen(bname) > 50
        let bname = fnamemodify(bname, ':t')
    endif

    return bname
endfunction

function! s:GetFileFlags(bufnum) abort
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
        let branch = s:ShortenPath(branch)
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

function! s:FileSizeStatus(...) abort
    if g:statusline_show_file_size
        return s:FileSize()
    endif
    return ''
endfunction

function! s:IndentationStatus(bufnum) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : getbufvar(a:bufnum, '&shiftwidth')
    return printf(getbufvar(a:bufnum, '&expandtab') ? 'Spaces: %d' : 'Tab Size: %d', shiftwidth)
endfunction

function! s:FileEncodingStatus(bufnum) abort
    let encoding = getbufvar(a:bufnum, '&fileencoding')
    if empty(encoding)
        let encoding = getbufvar(a:bufnum, '&encoding')
    endif
    " Show encoding only if it is not utf-8
    if empty(encoding) || encoding ==# 'utf-8'
        return ''
    endif
    return printf('[%s]', encoding)
endfunction

function! s:FileEncodingAndFormatStatus(bufnum) abort
    let encoding = getbufvar(a:bufnum, '&fileencoding')
    if empty(encoding)
        let encoding = getbufvar(a:bufnum, '&encoding')
    endif

    let format = getbufvar(a:bufnum, '&fileformat')

    if strlen(encoding) && strlen(format)
        let stl = printf('%s[%s]', encoding, format)
    elseif strlen(encoding)
        let stl = encoding
    else
        let stl = printf('[%s]', format)
    endif

    " Show format only if it is not utf-8[unix]
    if stl ==# 'utf-8[unix]'
        return ''
    endif

    return stl
endfunction

function! s:FileInfoStatus(bufnum) abort
    let ft = s:GetBufferType(a:bufnum)

    if g:statusline_show_devicons && s:has_devicons
        let parts = s:RemoveEmptyElement([
                    \ s:FileEncodingStatus(a:bufnum),
                    \ WebDevIconsGetFileFormatSymbol() . ' ',
                    \ ft,
                    \ WebDevIconsGetFileTypeSymbol(bufname(a:bufnum)) . ' ',
                    \ ])
    else
        let parts = s:RemoveEmptyElement([
                    \ s:FileEncodingAndFormatStatus(a:bufnum),
                    \ ft,
                    \ ])
    endif

    return join(parts, ' ')
endfunction

function! s:GitBranchStatus(winnum, filename) abort
    if g:statusline_show_git_branch && !w:is_small_window
        let branch = s:GetGitBranch()

        if strlen(branch)
            let branch = s:FormatBranch(branch, a:filename, winwidth(a:winnum) - 2)
        endif

        return branch
    endif

    return ''
endfunction

function! s:ClipboardStatus() abort
    if match(&clipboard, 'unnamed') > -1
        return s:symbols.clipboard
    endif
    return ''
endfunction

function! s:PasteStatus() abort
    if &paste
        return w:is_small_window ? s:symbols.paste : 'PASTE'
    endif
    return ''
endfunction

function! s:SpellStatus() abort
    if &spell
        return printf('%s', toupper(substitute(&spelllang, ',', '/', 'g')))
    endif
    return ''
endfunction

function! s:ActiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    " custom status
    let stl = s:CustomStatus(a:winnum, bufnum)
    if strlen(stl)
        return stl
    endif

    let filename = s:GetFileNameAndFlags(a:winnum, bufnum)

    let stl = s:BuildStatus(
                \ [
                \   [
                \       s:GitBranchStatus(a:winnum, filename),
                \       [s:ClipboardStatus(), s:PasteStatus()],
                \       filename,
                \   ],
                \   !w:is_small_window ? s:FileSizeStatus() : '',
                \ ],
                \ [
                \   [
                \       !w:is_small_window ? s:IndentationStatus(bufnum) : '',
                \       s:FileInfoStatus(bufnum),
                \   ],
                \   s:SpellStatus(),
                \ ])
    return stl
endfunction

function! s:InactiveStatusLine(winnum) abort
    let bufnum = winbufnr(a:winnum)

    " show only custom mode in inactive buffer
    let stl = s:CustomMode(a:winnum, bufnum)
    if strlen(stl)
        return ' ' . stl . ' '
    endif

    " « plugin/statusline.vim[+] »
    return s:BuildLeftStatus(s:Wrap(s:GetFileNameAndFlags(a:winnum, bufnum)))
endfunction

function! StatusLine(current, winnum) abort
    let w:is_small_window = s:IsSmallWindow(a:winnum)

    if a:current
        let stl = s:HiSection('ActiveStatus')
        let stl .= s:ActiveStatusLine(a:winnum)
    else
        let stl = s:HiSection('InactiveStatus')
        let stl .= s:InactiveStatusLine(a:winnum)
    endif

    return stl
endfunction

function! AutoStatusLine(current, winid) abort
    return StatusLine(a:current, win_id2win(a:winid))
endfunction

function! s:TabPlaceholder(tab) abort
    return s:HiSection('TabPlaceholder') . printf('%%%d  %s %%*', a:tab, s:symbols.ellipsis)
endfunction

function! s:TabLabel(tabnr) abort
    let tabnr = a:tabnr
    let winnr = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)

    let label = '%' . tabnr . 'T'
    let label .= (tabnr == tabpagenr() ? s:HiSection('ActiveTab') : s:HiSection('InactiveTab'))
    let label .= ' ' . tabnr . ':'

    let dev_icon = ''

    if getbufvar(bufnr, 'buftype') ==# 'nofile'
        if bufname =~ '\/.'
            let bufname = substitute(bufname, '.*\/\ze.', '', '')
        endif
    else
        let bufname = fnamemodify(bufname, ':p:~:.')

        if g:statusline_show_devicons && s:has_devicons
            let dev_icon = ' ' . WebDevIconsGetFileTypeSymbol(bufname) . ' '
        endif

        if bufname[0] =~ '\~\|/'
            let bufname = s:ShortenPath(bufname)
        elseif strlen(bufname) > 30
            let bufname = fnamemodify(bufname, ':t')
        endif
    endif

    if empty(bufname)
        let bufname = '[No Name]'
    endif

    let label .= ' ' . bufname . (getbufvar(bufnr, '&modified') ? '[+]' : '') . dev_icon . ' '

    return label
endfunction

function! Tabline() abort
    let stl = s:HiSection('TabTitle') . ' TABS %*'

    let tab_count = tabpagenr('$')
    let max_tab_count = s:displayable_tab_count

    if tab_count <= max_tab_count
        for i in range(1, tab_count)
            let stl .= s:TabLabel(i)
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
            let stl .= s:TabPlaceholder(start_index - 1)
        elseif start_index > 0
            let stl .= s:TabPlaceholder(start_index + 1)
        endif

        let displayable_tabs = tabs[start_index:end_index]

        for i in displayable_tabs
            let stl .= s:TabLabel(i)
        endfor

        if current_index < (tab_count - 1) && end_index < (tab_count - 1)
            let stl .= s:TabPlaceholder(end_index + 1)
        endif
    endif

    let stl .= s:HiSection('TabSeparator') . '%=' . '%*'

    if g:statusline_show_tab_close_button
        let stl .= s:HiSection('CloseButton') . '%999X  X  '
    endif

    return stl
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
    let focus   = s:HiSection('StatusSeparator') . ' ' . a:focus
    let byfname = s:HiSection('CtrlP') . ' ' . a:byfname
    let item    = s:HiSection('CtrlP') . ' ' . s:Wrap(a:item) . ' %*' . s:HiSection('StatusSeparator')
    return s:BuildStatus(
                \ [
                \   get(s:filetype_modes, 'ctrlp'),
                \   [
                \       a:prev,
                \       item,
                \       a:next,
                \       a:marked
                \   ]
                \ ],
                \ [
                \   s:GetCurrentDir(),
                \   [
                \       a:focus,
                \       byfname
                \   ]
                \ ])
endfunction

function! CtrlPProgressStatusLine(len) abort
    return s:BuildStatus([ a:len ], [ s:GetCurrentDir() ])
endfunction

" Tagbar Integration
let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, flags, ...) abort
    return s:BuildStatus(
                \ [
                \   [
                \       a:sort,
                \       a:fname
                \   ],
                \   empty(a:flags) ? '' : printf('[%s]', join(a:flags, ''))
                \ ],
                \ [])
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
let s:ZoomWin_funcref = uniq(copy(s:ZoomWin_funcref))

function! ZoomWinStatusLine(zoomstate) abort
    for F in s:ZoomWin_funcref
        if type(F) == 2 && F != function('ZoomWinStatusLine')
            call F(a:zoomstate)
        endif
    endfor

    call s:RefreshStatusLine()
endfunction

let g:ZoomWin_funcref= function('ZoomWinStatusLine')

let &cpo = s:save_cpo
unlet s:save_cpo
