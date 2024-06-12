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

function! statusline#Refresh() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

function! statusline#Setup() abort
    " Settings
    let g:statusline_powerline_fonts       = get(g:, 'statusline_powerline_fonts', 0)
    let g:statusline_shorten_path          = get(g:, 'statusline_shorten_path', 0)
    let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
    let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 0)
    let g:statusline_show_linenr           = get(g:, 'statusline_show_linenr', 0)
    let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 0) && statusline#devicons#Detect()

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

    " Window width
    let g:statusline_winwidth_config = extend({
                \ 'compact': 60,
                \ 'default': 90,
                \ 'normal':  120,
                \ }, get(g:, 'statusline_winwidth_config', {}))

    " Disable NERDTree statusline
    let g:NERDTreeStatusline = -1

    " Disable Quickfix statusline
    let g:qf_disable_statusline = 1

    " Symbols: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
    let g:statusline_symbols = extend({
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
                \ 'left':      '→',
                \ 'right':     '←',
                \ }, get(g:, 'statusline_symbols', {}))

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
                    \ 'tabs':  "\ue7c5 ",
                    \ 'bomb':  "\ue287 ",
                    \ 'noeol': "\ue293 ",
                    \ 'dos':   "\ue70f",
                    \ 'mac':   "\ue711",
                    \ 'unix':  "\ue712",
                    \ })
        let g:statusline_symbols.unix = '[unix]'
    endif

    " Alternate status dictionaries
    let g:statusline_filename_modes = {
                \ 'NetrwMessage':         'NetrwMessage',
                \ 'ControlP':             'CtrlP',
                \ '__CtrlSF__':           'CtrlSF',
                \ '__CtrlSFPreview__':    'Preview',
                \ '__flygrep__':          'FlyGrep',
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

    let g:statusline_filetype_modes = {
                \ 'simplebuffer':      'SimpleBuffer',
                \ 'netrw':             'Netrw',
                \ 'molder':            'Molder',
                \ 'dirvish':           'Dirvish',
                \ 'vaffle':            'Vaffle',
                \ 'nerdtree':          'NERDTree',
                \ 'fern':              'Fern',
                \ 'neo-tree':          'NeoTree',
                \ 'carbon.explorer':   'Carbon',
                \ 'oil':               'Oil',
                \ 'NvimTree':          'NvimTree',
                \ 'CHADTree':          'CHADTree',
                \ 'LuaTree':           'LuaTree',
                \ 'Mundo':             'Mundo',
                \ 'MundoDiff':         'Mundo Preview',
                \ 'undotree':          'Undo',
                \ 'diff':              'Diff',
                \ 'startify':          'Startify',
                \ 'alpha':             'Alpha',
                \ 'dashboard':         'Dashboard',
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
                \ 'GV':                'GV',
                \ 'agit':              'Agit',
                \ 'agit_diff':         'Agit Diff',
                \ 'agit_stat':         'Agit Stat',
                \ 'SpaceVimFlyGrep':   'FlyGrep',
                \ }

    let g:statusline_filename_integrations = {
                \ 'ControlP':          'statusline#ctrlp#Mode',
                \ '__CtrlSF__':        'statusline#ctrlsf#Mode',
                \ '__CtrlSFPreview__': 'statusline#ctrlsf#PreviewMode',
                \ '__flygrep__':       'statusline#flygrep#Mode',
                \ '__Tagbar__':        'statusline#tagbar#Mode',
                \ }

    let g:statusline_filetype_integrations = {
                \ 'ctrlp':           'statusline#ctrlp#Mode',
                \ 'netrw':           'statusline#netrw#Mode',
                \ 'dirvish':         'statusline#dirvish#Mode',
                \ 'molder':          'statusline#molder#Mode',
                \ 'vaffle':          'statusline#vaffle#Mode',
                \ 'fern':            'statusline#fern#Mode',
                \ 'carbon.explorer': 'statusline#carbon#Mode',
                \ 'neo-tree':        'statusline#neotree#Mode',
                \ 'oil':             'statusline#oil#Mode',
                \ 'tagbar':          'statusline#tagbar#Mode',
                \ 'vista_kind':      'statusline#vista#Mode',
                \ 'vista':           'statusline#vista#Mode',
                \ 'gitcommit':       'statusline#gitcommit#Mode',
                \ 'terminal':        'statusline#terminal#Mode',
                \ 'help':            'statusline#help#Mode',
                \ 'qf':              'statusline#quickfix#Mode',
                \ 'SpaceVimFlyGrep': 'statusline#flygrep#Mode',
                \ }
endfunction

function! statusline#Init() abort
    call statusline#parts#Init()
    call statusline#colors#Init()

    " CtrlP Integration
    if exists(':CtrlP') == 2
        let g:ctrlp_status_func = {
                    \ 'main': 'statusline#ctrlp#MainStatus',
                    \ 'prog': 'statusline#ctrlp#ProgressStatus',
                    \ }
    endif

    " Tagbar Integration
    if exists(':Tagbar') == 2
        let g:tagbar_status_func = 'statusline#tagbar#Status'
    endif

    " ZoomWin Integration
    let g:statusline_zoomed = 0

    if exists(':ZoomWin') == 2
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
    endif
endfunction
