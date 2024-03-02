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

function! statusline#Group(exp) abort
    if a:exp =~ '^%'
        return '%( ' . a:exp . ' %)'
    else
        return '%( %{' . a:exp . '} %)'
    endif
endfunction

function! statusline#Wrap(text) abort
    return printf('%s %s %s', '«', a:text, '»')
endfunction

function! statusline#ModeConcatenate(parts, ...) abort
    let separator = get(a:, 1, 0) ? g:crystalline_symbols.right_mode_sep : g:crystalline_symbols.left_mode_sep
    return join(filter(copy(a:parts), 'v:val !=# ""'), ' ' . separator . ' ')
endfunction

function! statusline#Concatenate(parts, ...) abort
    let separator = get(a:, 1, 0) ? g:crystalline_symbols.right_fill_sep : g:crystalline_symbols.left_fill_sep
    return join(filter(copy(a:parts), 'v:val !=# ""'), ' ' . separator . ' ')
endfunction

function! statusline#BufferType() abort
    return strlen(&filetype) ? &filetype : &buftype
endfunction

function! statusline#FileName() abort
    let fname = expand('%')
    return strlen(fname) ? fnamemodify(fname, ':~:.') : '[No Name]'
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
