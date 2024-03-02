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
let g:statusline_powerline_fonts       = get(g:, 'statusline_powerline_fonts', 0)
let g:statusline_mode                  = get(g:, 'statusline_mode', 'default')
let g:statusline_shorten_path          = get(g:, 'statusline_shorten_path', 0)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 1)
let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 1)
let g:statusline_show_vim_logo         = get(g:, 'statusline_show_vim_logo', 1)

if g:statusline_mode ==? 'minimal'
    let g:statusline_show_git_branch = 0
    let g:statusline_show_devicons   = 0
endif

" Window width
let g:statusline_winwidth_config = extend({
            \ 'compact': 60,
            \ 'small':   80,
            \ 'normal':  120,
            \ }, get(g:, 'statusline_winwidth_config', {}))

" Disable NERDTree statusline
let g:NERDTreeStatusline = -1

" Number of displayable tabs
let s:displayable_tab_count = 5

" Symbols: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
let g:statusline_symbols = {
            \ 'dos':            '[dos]',
            \ 'mac':            '[mac]',
            \ 'unix':           '[unix]',
            \ 'tabs':           'TABS',
            \ 'linenr':         '☰',
            \ 'branch':         '⎇ ',
            \ 'readonly':       '',
            \ 'bomb':           '🅑 ',
            \ 'noeol':          '∉ ',
            \ 'clipboard':      '🅒 ',
            \ 'paste':          '🅟 ',
            \ 'ellipsis':       '…',
            \ 'left':           '»',
            \ 'left_alt':       '»',
            \ 'right':          '«',
            \ 'right_alt':      '«',
            \ 'left_fill_sep':  ' ',
            \ 'right_fill_sep': ' ',
            \ }

if g:statusline_powerline_fonts
    " Powerline Symbols
    call extend(g:statusline_symbols, {
                \ 'left':      "\ue0b0",
                \ 'right':     "\ue0b2",
                \ 'left_alt':  "\ue0b1",
                \ 'right_alt': "\ue0b3",
                \ })
endif

let g:statusline_show_devicons = g:statusline_show_devicons && statusline#devicons#Detect()

if g:statusline_show_devicons
    call extend(g:statusline_symbols, {
                \ 'bomb':  "\ue287 ",
                \ 'noeol': "\ue293 ",
                \ 'dos':   "\ue70f",
                \ 'mac':   "\ue711",
                \ 'unix':  "\ue712",
                \ })
    let g:statusline_symbols.unix = '[unix]'
endif

" Show Vim Logo in Tabline
if g:statusline_show_devicons && g:statusline_show_vim_logo
    let g:statusline_symbols.tabs = "\ue7c5 "
endif

call extend(g:statusline_symbols, {
            \ 'left_mode_sep':  ' ' . g:statusline_symbols.left_alt . ' ',
            \ 'right_mode_sep': ' ' . g:statusline_symbols.right_alt . ' ',
            \ 'left_sep':       ' ' . g:statusline_symbols.left . ' ',
            \ 'left_alt_sep':   ' ' . g:statusline_symbols.left_alt . ' ',
            \ 'right_sep':      ' ' . g:statusline_symbols.right . ' ',
            \ 'right_alt_sep':  ' ' . g:statusline_symbols.right_alt . ' ',
            \ })

" Alternate status dictionaries
let s:filename_modes = {
            \ 'ControlP':             'CtrlP',
            \ '__CtrlSF__':           'CtrlSF',
            \ '__CtrlSFPreview__':    'Preview',
            \ '__Tagbar__':           'Tagbar',
            \ '__Gundo__':            'Gundo',
            \ '__Gundo_Preview__':    'Gundo Preview',
            \ '__Mundo__':            'Mundo',
            \ '__Mundo_Preview__':    'Mundo Preview',
            \ '[BufExplorer]':        'BufExplorer',
            \ '[Command Line]':       'Command Line',
            \ '[Plugins]':            'Plugins',
            \ '__committia_status__': 'Committia Status',
            \ '__committia_diff__':   'Committia Diff',
            \ '__doc__':              'Document',
            \ '__LSP_SETTINGS__':     'LSP Settings',
            \ }

let s:filetype_modes = {
            \ 'netrw':             'NetrwTree',
            \ 'nerdtree':          'NERDTree',
            \ 'chadtree':          'CHADTree',
            \ 'LuaTree':           'LuaTree',
            \ 'NvimTree':          'NvimTree',
            \ 'neo-tree':          'NeoTree',
            \ 'carbon.explorer':   'Carbon',
            \ 'fern':              'Fern',
            \ 'vaffle':            'Vaffle',
            \ 'dirvish':           'Dirvish',
            \ 'Mundo':             'Mundo',
            \ 'MundoDiff':         'Mundo Preview',
            \ 'startify':          'Startify',
            \ 'alpha':             'Alpha',
            \ 'tagbar':            'Tagbar',
            \ 'vista':             'Vista',
            \ 'vista_kind':        'Vista',
            \ 'vim-plug':          'Plugins',
            \ 'terminal':          'TERMINAL',
            \ 'help':              'HELP',
            \ 'qf':                'Quickfix',
            \ 'godoc':             'GoDoc',
            \ 'gedoc':             'GeDoc',
            \ 'gitcommit':         'Commit Message',
            \ 'fugitiveblame':     'FugitiveBlame',
            \ 'gitmessengerpopup': 'Git Messenger',
            \ 'agit':              'Agit',
            \ 'agit_diff':         'Agit Diff',
            \ 'agit_stat':         'Agit Stat',
            \ }

function! s:HiSection(section) abort
    return printf('%%#%s#', a:section)
endfunction

function! s:Wrap(text) abort
    return printf('%s %s %s', '«', a:text, '»')
endfunction

function! s:RemoveEmptyElement(list) abort
    return filter(copy(a:list), '!empty(v:val)')
endfunction

function! s:EnsureList(list) abort
    return type(a:list) == type([]) ? deepcopy(a:list) : [a:list]
endfunction

function! s:ParseList(list, sep) abort
    let l:list = s:EnsureList(a:list)
    let l:list = map(copy(l:list), "type(v:val) == type([]) ? join(s:RemoveEmptyElement(v:val), a:sep) : v:val")
    return s:RemoveEmptyElement(l:list)
endfunction

function! s:BuildMode(parts, ...) abort
    let l:sep = get(a:, 1, g:statusline_symbols.left_mode_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightMode(parts) abort
    return s:BuildMode(a:parts, g:statusline_symbols.right_mode_sep)
endfunction

function! s:BuildFill(parts, ...) abort
    let l:sep = get(a:, 1, g:statusline_symbols.left_fill_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightFill(parts) abort
    return s:BuildFill(a:parts, g:statusline_symbols.right_fill_sep)
endfunction

function! s:BuildGroup(exp) abort
    if a:exp =~ '^%'
        return '%( ' . a:exp . ' %)'
    else
        return '%( %{' . a:exp . '} %)'
    endif
endfunction

function! StatusLineActiveMode(...) abort
    " custom status
    let l:mode = s:CustomMode()
    if len(l:mode)
        return s:BuildMode([ l:mode['name'], get(l:mode, 'lmode', '') ])
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    return s:BuildMode([
                \ g:statusline_show_git_branch ? statusline#git#Branch() : '',
                \ statusline#parts#FileName(),
                \ ])
endfunction

function! StatusLineLeftFill(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'lfill', '')
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    if l:winwidth >= g:statusline_winwidth_config.small
    endif

    return s:BuildMode([
                \ [statusline#parts#Clipboard(), statusline#parts#Paste(), statusline#parts#Spell()],
                \ ])
endfunction

function! StatusLineRightMode(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'rmode', '')
    endif

    let compact = g:statusline_show_git_branch && statusline#IsCompact(get(a:, 1, 0))
    return s:BuildRightMode([
                \ statusline#parts#Indentation(compact),
                \ statusline#parts#FileType(),
                \ ])
endfunction

function! StatusLineRightFill(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'rfill', '')
    endif
    return ''
endfunction

function! StatusLineInactiveMode(...) abort
    " show only custom mode in inactive buffer
    let l:mode = s:CustomMode()
    if len(l:mode)
        return s:BuildMode([ l:mode['name'], get(l:mode, 'lmode_inactive', '') ])
    endif

    " « plugin/statusline.vim[+] »
    return s:Wrap(statusline#parts#InactiveFileName())
endfunction


function! StatusLine(winnum) abort
    " Goyo Integration
    if exists('#goyo')
        if a:winnum == winnr()
            return ''
        else
            return s:HiSection('StNone')
        endif
    endif

    if a:winnum == winnr()
        return join([
                    \ s:HiSection('StItem'),
                    \ '%<',
                    \ s:BuildGroup(printf('StatusLineActiveMode(%d)', a:winnum)),
                    \ s:HiSection('StSep'),
                    \ s:BuildGroup(printf('StatusLineLeftFill(%d)', a:winnum)),
                    \ s:HiSection('StFill'),
                    \ '%=',
                    \ s:BuildGroup(printf('StatusLineRightFill(%d)', a:winnum)),
                    \ s:HiSection('StInfo'),
                    \ '%<',
                    \ s:BuildGroup(printf('StatusLineRightMode(%d)', a:winnum)),
                    \ ], '')
    else
        return s:HiSection('StItemNC') .
                    \ '%<' .
                    \ s:BuildGroup(printf('StatusLineInactiveMode(%d)', a:winnum))
    endif
endfunction

" Plugin Integration
" Save plugin states
let s:statusline = {}

function! s:CustomMode() abort
    let fname = expand('%:t')

    if has_key(s:filename_modes, fname)
        let result = {
                    \ 'name': s:filename_modes[fname],
                    \ 'type': 'name',
                    \ }

        if fname ==# 'ControlP'
            return extend(result, statusline#ctrlp#Mode())
        endif

        if fname ==# '__Tagbar__'
            return extend(result, s:GetTagbarMode())
        endif

        if fname ==# '__CtrlSF__'
            return extend(result, statusline#ctrlsf#Mode())
        endif

        if fname ==# '__CtrlSFPreview__'
            return extend(result, statusline#ctrlsf#PreviewMode())
        endif

        return result
    endif

    if fname =~? '^NrrwRgn'
        let nrrw_rgn_mode = s:GetNrrwRgnMode()
        if len(nrrw_rgn_mode)
            return nrrw_rgn_mode
        endif
    endif

    let ft = statusline#BufferType()
    if has_key(s:filetype_modes, ft)
        let result = {
                    \ 'name': s:filetype_modes[ft],
                    \ 'type': 'filetype',
                    \ }

        if ft ==# 'neo-tree'
            return extend(result, s:GetNeoTreeMode(expand('%')))
        endif

        if ft ==# 'carbon.explorer'
            return extend(result, s:GetCarbonMode(expand('%')))
        endif

        if ft ==# 'fern'
            return extend(result, s:GetFernMode(expand('%')))
        endif

        if ft ==# 'vaffle'
            return extend(result, s:GetVaffleMode(expand('%')))
        endif

        if ft ==# 'dirvish'
            return extend(result, s:GetDirvishMode(expand('%')))
        endif

        if ft ==# 'tagbar'
            return extend(result, s:GetTagbarMode())
        endif

        if ft ==# 'vista_kind' || ft ==# 'vista'
            return extend(result, s:GetVistaMode())
        endif

        if ft ==# 'terminal'
            return extend(result, {
                        \ 'lmode': expand('%'),
                        \ })
        endif

        if ft ==# 'help'
            let fname = expand('%:p')
            return extend(result, {
                        \ 'lmode': fname,
                        \ 'lmode_inactive': fname,
                        \ })
        endif

        if ft ==# 'qf'
            if getwininfo(win_getid())[0]['loclist']
                let result['name'] = 'Location'
            endif
            let qf_title = statusline#Trim(get(w:, 'quickfix_title', ''))
            return extend(result, {
                        \ 'lmode': qf_title,
                        \ 'lmode_inactive': qf_title,
                        \ })
        endif

        return result
    endif

    return {}
endfunction

" NeoTree Integration
function! s:GetNeoTreeMode(...) abort
    let result = { 'name': 'NeoTree' }

    if exists('b:neo_tree_source')
        let result['lfill'] = b:neo_tree_source
    endif

    return result
endfunction

" Carbon Integration
function! s:GetCarbonMode(...) abort
    let result = { 'name': 'Carbon' }

    if exists('b:carbon')
        let result['lfill'] = fnamemodify(b:carbon['path'], ':p:~:.:h')
    endif

    return result
endfunction

" Fern Integration
function! s:GetFernMode(...) abort
    let result = {}

    let fern_name = get(a:, 1, expand('%'))
    let pattern = '^fern://\(.\+\)/file://\(.\+\)\$'
    let data = matchlist(fern_name, pattern)

    if len(data)
        let fern_mode = get(data, 1, '')
        if match(fern_mode, 'drawer') > -1
            let result['name'] = 'Drawer'
        endif

        let fern_folder = get(data, 2, '')
        let fern_folder = substitute(fern_folder, ';\?\(#.\+\)\?\$\?$', '', '')
        let fern_folder = fnamemodify(fern_folder, ':p:~:.:h')

        let result['lfill'] = fern_folder
    endif

    return result
endfunction

" Vaffle Integration
function! s:GetVaffleMode(...) abort
    let result = {}

    let vaffle_name = get(a:, 1, expand('%'))
    let pattern = '^vaffle://\(\d\+\)/\(.\+\)$'
    let data = matchlist(vaffle_name, pattern)

    let vaffle_folder = get(data, 2, '')
    if strlen(vaffle_folder)
        let result['lfill'] = fnamemodify(vaffle_folder, ':p:~:h')
    endif

    return result
endfunction

function! s:GetDirvishMode(...) abort
    return { 'lfill': fnamemodify(get(a:, 1, expand('%')), ':p:h') }
endfunction

" NrrwRgn Integration
function! s:GetNrrwRgnMode(...) abort
    let result = {}

    if exists(':WidenRegion') == 2
        let result['type'] = 'nrrwrgn'

        if exists('b:nrrw_instn')
            let result['name'] = printf('%s#%d', 'NrrwRgn', b:nrrw_instn)
        else
            let l:mode = substitute(bufname('%'), '^Nrrwrgn_\zs.*\ze_\d\+$', submatch(0), '')
            let l:mode = substitute(l:mode, '__', '#', '')
            let result['name'] = l:mode
        endif

        let dict = exists('*nrrwrgn#NrrwRgnStatus()') ?  nrrwrgn#NrrwRgnStatus() : {}

        if len(dict)
            let result['lmode'] = fnamemodify(dict.fullname, ':~:.')
            let result['lmode_inactive'] = result['lmode']
        elseif get(b:, 'orig_buf', 0)
            let result['lmode'] = bufname(b:orig_buf)
            let result['lmode_inactive'] = result['lmode']
        endif
    endif

    return result
endfunction

" Tagbar Integration
let g:tagbar_status_func = 'TagbarStatusFunc'

function! s:GetTagbarMode() abort
    if empty(s:statusline.tagbar_flags)
        let lfill = ''
    else
        let lfill = printf('[%s]', join(s:statusline.tagbar_flags, ''))
    endif

    return {
                \ 'name': s:statusline.tagbar_sort,
                \ 'lmode': s:statusline.tagbar_fname,
                \ 'lfill': lfill,
                \ 'type': 'tagbar',
                \ }
endfunction

function! TagbarStatusFunc(current, sort, fname, flags, ...) abort
    let s:statusline.tagbar_sort  = a:sort
    let s:statusline.tagbar_fname = a:fname
    let s:statusline.tagbar_flags = a:flags

    return StatusLine(winnr())
endfunction

" Vista Integration
function! s:GetVistaMode() abort
    let provider = get(get(g:, 'vista', {}), 'provider', '')
    return {
                \ 'lfill': provider,
                \ 'type': 'vista',
                \ }
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

function! s:ExtractHlID(name) abort
    let l:hl_id   = hlID(a:name)
    let l:guibg   = synIDattr(l:hl_id, 'bg', 'gui')
    let l:guifg   = synIDattr(l:hl_id, 'fg', 'gui')
    let l:ctermbg = synIDattr(l:hl_id, 'bg', 'cterm')
    let l:ctermfg = synIDattr(l:hl_id, 'fg', 'cterm')
    return {
                \ 'guibg': l:guibg,
                \ 'guifg': l:guifg,
                \ 'ctermbg': l:ctermbg,
                \ 'ctermfg': l:ctermfg,
                \ }
endfunction

function! s:Highlight(group, attrs) abort
    let l:cmd = printf('highlight! %s', a:group)
    for [key, value] in items(a:attrs)
        if !empty(value)
            let l:cmd .= printf(' %s=%s', key, value)
        endif
    endfor
    silent! execute l:cmd
endfunction

" Set status colors

function! s:SetStatusColors() abort
    highlight! StNone guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE

    let l:st_item = s:ExtractHlID('StatusLine')
    call extend(l:st_item, {
                \ 'gui':   'bold',
                \ 'cterm': 'bold',
                \ })

    call s:Highlight('StItem', l:st_item)
    call s:Highlight('StStep', l:st_item)
    call s:Highlight('StFill', l:st_item)
    call s:Highlight('StInfo', l:st_item)

    let l:st_item_nc = s:ExtractHlID('LineNr')
    call s:Highlight('StItemNC', l:st_item_nc)

    call s:Highlight('StTabItem', l:st_item)
    call s:Highlight('StTabTitle', l:st_item)
    call s:Highlight('StTabFill', l:st_item)
    call s:Highlight('StTabCloseButton', l:st_item)

    let l:st_tab_item_nc = s:ExtractHlID('StatusLineNC')
    call s:Highlight('StTabItemNC', l:st_tab_item_nc)
endfunction

" Init statusline

function! s:RefreshStatusLine() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

command! RefreshStatusLine :call s:RefreshStatusLine()

augroup VimStatusLine
    autocmd!
    autocmd VimEnter * call statusline#Init()
    autocmd WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost * call <SID>RefreshStatusLine()
    if !has('patch-8.1.1715')
        autocmd FileType qf call <SID>RefreshStatusLine()
    endif
    autocmd FileType NvimTree call <SID>RefreshStatusLine()
    autocmd VimEnter,ColorScheme * call s:SetStatusColors()
    autocmd ColorScheme *
                \ if !has('vim_starting') || expand('<amatch>') !=# 'macvim'
                \   | call <SID>RefreshStatusLine() |
                \ endif
    autocmd VimResized * call <SID>RefreshStatusLine()
augroup END

let g:qf_disable_statusline = 1

" Init tabline
if exists('+tabline')
    function! s:TabPlaceholder(tab) abort
        return s:HiSection('StTabPlaceholder') . printf('%%%d  %s %%*', a:tab, g:statusline_symbols.ellipsis)
    endfunction

    function! s:TabLabel(tabnr) abort
        let tabnr = a:tabnr
        let winnr = tabpagewinnr(tabnr)
        let buflist = tabpagebuflist(tabnr)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)

        let label = '%' . tabnr . 'T'
        let label .= (tabnr == tabpagenr() ? s:HiSection('StTabItem') : s:HiSection('StTabItemNC'))
        let label .= ' ' . tabnr . ':'

        let dev_icon = ''

        if getbufvar(bufnr, 'buftype') ==# 'nofile'
            if bufname =~ '\/.'
                let bufname = substitute(bufname, '.*\/\ze.', '', '')
            endif
        else
            let bufname = fnamemodify(bufname, ':p:~:.')

            if g:statusline_show_devicons
                let dev_icon = statusline#devicons#FileType(bufname)
            endif

            if strlen(bufname) > 30
                if bufname[0] =~ '\~\|/' && g:statusline_shorten_path
                    let bufname = statusline#ShortenPath(bufname)
                else
                    let bufname = fnamemodify(bufname, ':t')
                endif
            endif
        endif

        if empty(bufname)
            let bufname = '[No Name]'
        endif

        let label .= ' ' . bufname . (getbufvar(bufnr, '&modified') ? '[+]' : '') . dev_icon . ' '

        return label
    endfunction

    function! Tabline() abort
        let stl = s:HiSection('StTabTitle') . ' ' . g:statusline_symbols.tabs . ' ' . '%*'

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

        let stl .= s:HiSection('StTabFill') . '%='

        if g:statusline_show_tab_close_button
            let stl .= s:HiSection('StTabCloseButton') . '%999X  X  '
        endif

        return stl
    endfunction

    set tabline=%!Tabline()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
