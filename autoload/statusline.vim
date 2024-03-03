function! statusline#Trim(str) abort
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

if exists('*trim')
    function! statusline#Trim(str) abort
        return trim(a:str)
    endfunction
endif

function! statusline#ShortenPath(filename) abort
    return substitute(a:filename, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
endfunction

if exists('*pathshorten')
    function! statusline#ShortenPath(filename) abort
        return pathshorten(a:filename)
    endfunction
endif

function! statusline#FormatFileName(fname, ...) abort
    let l:path = a:fname
    let l:maxlen = get(a:, 1, 50)

    if winwidth(0) <= g:statusline_winwidth_config.compact
        return fnamemodify(l:path, ':t')
    endif

    if strlen(l:path) > l:maxlen && g:statusline_shorten_path
        let l:path = statusline#ShortenPath(l:path)
    endif

    if strlen(l:path) > l:maxlen
        let l:path = fnamemodify(l:path, ':t')
    endif

    return l:path
endfunction

function! statusline#IsClipboardEnabled() abort
    return match(&clipboard, 'unnamed') > -1
endfunction

function! statusline#IsCompact(...) abort
    let l:winnr = get(a:, 1, 0)
    return winwidth(l:winnr) <= g:statusline_winwidth_config.compact ||
                \ count([
                \   statusline#IsClipboardEnabled(),
                \   &paste,
                \   &spell,
                \   &bomb,
                \   !&eol,
                \ ], 1) > 1
endfunction

function! statusline#Hi(section) abort
    return printf('%%#%s#', a:section)
endfunction

function! statusline#ModeGroup(exp) abort
    if a:exp =~ '^%'
        return '%( ' . a:exp . ' %)'
    else
        return '%( %{' . a:exp . '} %)'
    endif
endfunction

function! statusline#Group(exp) abort
    if a:exp =~ '^%'
        return '%(' . a:exp . ' %)'
    else
        return '%(%{' . a:exp . '} %)'
    endif
endfunction

function! statusline#Wrap(text) abort
    return empty(a:text) ? '' : printf('%s %s %s', '«', a:text, '»')
endfunction

function! statusline#Append(text, ...) abort
    let sep = get(a:, 1, 0) ? g:statusline_symbols.left : g:statusline_symbols.right
    return empty(a:text) ? '' : printf('%s %s', a:text, sep)
endfunction

function! statusline#Prepend(text, ...) abort
    let sep = get(a:, 1, 0) ? g:statusline_symbols.right : g:statusline_symbols.left
    return empty(a:text) ? '' : printf('%s %s', sep, a:text)
endfunction

function! statusline#Concatenate(parts, ...) abort
    let sep = get(a:, 1, 0) ? g:statusline_symbols.right : g:statusline_symbols.left
    return join(filter(copy(a:parts), 'v:val !=# ""'), g:statusline_symbols.space . sep . g:statusline_symbols.space)
endfunction

function! statusline#BufferType() abort
    return strlen(&filetype) ? &filetype : &buftype
endfunction

function! statusline#FileName() abort
    let fname = expand('%')
    return strlen(fname) ? fnamemodify(fname, ':~:.') : '[No Name]'
endfunction

function! statusline#Refresh() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

function! statusline#Setup() abort
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

    " Improved Model Labels
    let g:statusline_mode_labels = {
                \ 'n':  'NORMAL',
                \ 'c':  'COMMAND',
                \ 'r':  'NORMAL',
                \ '!':  'NORMAL',
                \ 'i':  'INSERT',
                \ 't':  'TERMINAL',
                \ 'v':  'VISUAL',
                \ 'V':  'V-LINE',
                \ '': 'V-BLOCK',
                \ 's':  'SELECT',
                \ 'S':  'S-LINE',
                \ '': 'S-BLOCK',
                \ 'R':  'REPLACE',
                \ '':   '',
                \ }

    let g:statusline_short_mode_labels = {
                \ 'n':  'N',
                \ 'c':  'C',
                \ 'r':  'N',
                \ '!':  'N',
                \ 'i':  'I',
                \ 't':  'T',
                \ 'v':  'V',
                \ 'V':  'L',
                \ '': 'B',
                \ 's':  'S',
                \ 'S':  'S-L',
                \ '': 'S-B',
                \ 'R':  'R ',
                \ '':   '',
                \ }

    " Max tabs
    let g:statusline_max_tabs = 5

    " Window width
    let g:statusline_winwidth_config = extend({
                \ 'compact': 60,
                \ 'small':   80,
                \ 'normal':  120,
                \ }, get(g:, 'statusline_winwidth_config', {}))

    " Disable NERDTree statusline
    let g:NERDTreeStatusline = -1

    " Symbols: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
    let g:statusline_symbols = {
                \ 'dos':       '[dos]',
                \ 'mac':       '[mac]',
                \ 'unix':      '[unix]',
                \ 'tabs':      'TABS',
                \ 'space':     ' ',
                \ 'linenr':    '☰',
                \ 'branch':    '⎇ ',
                \ 'readonly':  '',
                \ 'bomb':      '🅑 ',
                \ 'noeol':     '∉ ',
                \ 'clipboard': '🅒 ',
                \ 'paste':     '🅟 ',
                \ 'ellipsis':  '…',
                \ }

    let g:statusline_show_devicons = g:statusline_show_devicons && statusline#devicons#Detect()

    if g:statusline_powerline_fonts || g:statusline_show_devicons
        " Powerline Symbols
        call extend(g:statusline_symbols, {
                    \ 'linenr':   "\ue0a1",
                    \ 'branch':   "\ue0a0",
                    \ 'readonly': "\ue0a2",
                    \ })
    endif

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
                \ 'left':  '→',
                \ 'right': '←',
                \ })
endfunction

function! statusline#Init() abort
    " CtrlP Integration
    let g:ctrlp_status_func = {
                \ 'main': 'statusline#ctrlp#MainStatus',
                \ 'prog': 'statusline#ctrlp#ProgressStatus',
                \ }

    " Tagbar Integration
    let g:tagbar_status_func = 'statusline#tagbar#Status'

    " ZoomWin Integration
    let g:statusline_zoomwin_funcref = []

    if exists('g:ZoomWin_funcref')
        if type(g:ZoomWin_funcref) == v:t_func
            let g:statusline_zoomwin_funcref = [g:ZoomWin_funcref]
        elseif type(g:ZoomWin_funcref) == v:t_func
            let g:statusline_zoomwin_funcref = g:ZoomWin_funcref
        endif
        let g:statusline_zoomwin_funcref = uniq(copy(g:statusline_zoomwin_funcref))
    endif

    let g:ZoomWin_funcref = function('statusline#zoomwin#Status')
endfunction
