function! statusline#parts#Mode() abort
    if statusline#IsCompact()
        return get(g:statusline_short_mode_labels, mode(), '')
    else
        return get(g:statusline_mode_labels, mode(), '')
    endif
endfunction

function! statusline#parts#Clipboard() abort
    return statusline#IsClipboardEnabled() ? g:statusline_symbols.clipboard : ''
endfunction

function! statusline#parts#Paste() abort
    return &paste ? g:statusline_symbols.paste : ''
endfunction

function! statusline#parts#Spell() abort
    return &spell ? toupper(substitute(&spelllang, ',', '/', 'g')) : ''
endfunction

function! statusline#parts#Indentation(...) abort
    let l:shiftwidth = exists('*shiftwidth') ? shiftwidth() : &shiftwidth
    let compact = get(a:, 1, 0)
    if compact
        return printf(&expandtab ? 'SPC: %d' : 'TAB: %d', l:shiftwidth)
    else
        return printf(&expandtab ? 'Spaces: %d' : 'Tab Size: %d', l:shiftwidth)
    endif
endfunction

function! statusline#parts#Readonly(...) abort
    return &readonly ? g:statusline_symbols.readonly . ' ' : ''
endfunction

function! statusline#parts#Modified(...) abort
    if &modified
        return !&modifiable ? '[+-]' : '[+]'
    else
        return !&modifiable ? '[-]' : ''
    endif
endfunction

function! statusline#parts#SimpleLineInfo(...) abort
    return printf('%3d:%-3d', line('.'), col('.'))
endfunction

function! statusline#parts#LineInfo(...) abort
    if line('w0') == 1 && line('w$') == line('$')
        let l:percent = 'All'
    elseif line('w0') == 1
        let l:percent = 'Top'
    elseif line('w$') == line('$')
        let l:percent = 'Bot'
    else
        let l:percent = printf('%d%%', line('.') * 100 / line('$'))
    endif

    return printf('%4d:%-3d %3s', line('.'), col('.'), l:percent)
endfunction

function! statusline#parts#FileEncodingAndFormat() abort
    let l:encoding = strlen(&fileencoding) ? &fileencoding : &encoding
    let l:encoding = (l:encoding ==# 'utf-8') ? '' : l:encoding . ' '
    let l:bomb     = &bomb ? g:statusline_symbols.bomb . ' ' : ''
    let l:noeol    = &eol ? '' : g:statusline_symbols.noeol . ' '
    let l:format   = get(g:statusline_symbols, &fileformat, '[empty]')
    let l:format   = (l:format ==# '[unix]') ? '' : l:format . ' '
    return l:encoding . l:bomb . l:noeol . l:format
endfunction

function! statusline#parts#FileType(...) abort
    return statusline#BufferType() . statusline#devicons#FileType(expand('%'))
endfunction

function! statusline#parts#FileName(...) abort
    return statusline#parts#Readonly() . statusline#FormatFileName(statusline#FileName()) . statusline#parts#Modified()
endfunction

function! statusline#parts#InactiveFileName(...) abort
    return statusline#parts#Readonly() . statusline#FileName() . statusline#parts#Modified()
endfunction

" Alternate status dictionaries
let g:statusline_filename_modes = {
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

let g:statusline_filetype_modes = {
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
            \ 'GV':                'GV',
            \ 'agit':              'Agit',
            \ 'agit_diff':         'Agit Diff',
            \ 'agit_stat':         'Agit Stat',
            \ }

let g:statusline_plugin_modes = {
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
            \ }

function! statusline#parts#Integration() abort
    let fname = expand('%:t')

    if has_key(g:statusline_filename_modes, fname)
        let result = { 'name': g:statusline_filename_modes[fname] }

        let l:plugin_modes = {
                    \ 'ControlP':          'statusline#ctrlp#Mode',
                    \ '__Tagbar__':        'statusline#tagbar#Mode',
                    \ '__CtrlSF__':        'statusline#ctrlsf#Mode',
                    \ '__CtrlSFPreview__': 'statusline#ctrlsf#PreviewMode',
                    \ }

        if has_key(l:plugin_modes, fname)
            return extend(result, function(l:plugin_modes[fname])())
        endif
    endif

    if fname =~# '^NrrwRgn_\zs.*\ze_\d\+$'
        return statusline#nrrwrgn#Mode()
    endif

    let ft = statusline#BufferType()
    if has_key(g:statusline_filetype_modes, ft)
        let result = { 'name': g:statusline_filetype_modes[ft] }

        if has_key(g:statusline_plugin_modes, ft)
            return extend(result, function(g:statusline_plugin_modes[ft])())
        endif

        return result
    endif

    return {}
endfunction
