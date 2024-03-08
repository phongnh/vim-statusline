function! s:BufferType() abort
    return strlen(&filetype) ? &filetype : &buftype
endfunction

function! s:FileName() abort
    let fname = expand('%')
    return strlen(fname) ? fnamemodify(fname, ':~:.') : '[No Name]'
endfunction

function! s:IsClipboardEnabled() abort
    return match(&clipboard, 'unnamed') > -1
endfunction

function! s:IsCompact(...) abort
    let l:winnr = get(a:, 1, 0)
    return winwidth(l:winnr) <= g:statusline_winwidth_config.compact ||
                \ count([
                \   s:IsClipboardEnabled(),
                \   &paste,
                \   &spell,
                \   &bomb,
                \   !&eol,
                \ ], 1) > 1
endfunction

function! statusline#parts#Mode() abort
    if s:IsCompact()
        return get(g:statusline_short_mode_labels, mode(), '')
    else
        return get(g:statusline_mode_labels, mode(), '')
    endif
endfunction

function! statusline#parts#Clipboard() abort
    return s:IsClipboardEnabled() ? g:statusline_symbols.clipboard : ''
endfunction

function! statusline#parts#Paste() abort
    return &paste ? g:statusline_symbols.paste : ''
endfunction

function! statusline#parts#Spell() abort
    return &spell ? toupper(substitute(&spelllang, ',', '/', 'g')) : ''
endfunction

function! statusline#parts#Indentation(...) abort
    let l:shiftwidth = exists('*shiftwidth') ? shiftwidth() : &shiftwidth
    let compact = get(a:, 1, s:IsCompact())
    if compact
        return printf(&expandtab ? 'SPC: %d' : 'TAB: %d', l:shiftwidth)
    else
        return printf(&expandtab ? 'Spaces: %d' : 'Tab Size: %d', l:shiftwidth)
    endif
endfunction

function! s:ReadonlyStatus(...) abort
    return &readonly ? g:statusline_symbols.readonly . ' ' : ''
endfunction

function! s:ModifiedStatus(...) abort
    if &modified
        return !&modifiable ? '[+-]' : '[+]'
    else
        return !&modifiable ? '[-]' : ''
    endif
endfunction

function! s:SimpleLineInfo(...) abort
    return printf('%3d:%-3d', line('.'), col('.'))
endfunction

function! s:FullLineInfo(...) abort
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

function! statusline#parts#LineInfo() abort
    return ''
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
    return s:BufferType() . statusline#devicons#FileType(expand('%'))
endfunction

function! statusline#parts#FileName(...) abort
    return s:ReadonlyStatus() . statusline#FormatFileName(s:FileName()) . s:ModifiedStatus()
endfunction

function! statusline#parts#InactiveFileName(...) abort
    return s:ReadonlyStatus() . s:FileName() . s:ModifiedStatus()
endfunction

function! statusline#parts#Integration() abort
    let fname = expand('%:t')

    if has_key(g:statusline_filename_modes, fname)
        let result = { 'name': g:statusline_filename_modes[fname] }

        let l:plugin_modes = {
                    \ 'ControlP':          'statusline#ctrlp#Mode',
                    \ '__CtrlSF__':        'statusline#ctrlsf#Mode',
                    \ '__CtrlSFPreview__': 'statusline#ctrlsf#PreviewMode',
                    \ '__flygrep__':       'statusline#flygrep#Mode',
                    \ '__Tagbar__':        'statusline#tagbar#Mode',
                    \ }

        if has_key(l:plugin_modes, fname)
            return extend(result, function(l:plugin_modes[fname])())
        endif

        return result
    endif

    if fname =~# '^NrrwRgn_\zs.*\ze_\d\+$'
        return statusline#nrrwrgn#Mode()
    endif

    let ft = s:BufferType()
    if has_key(g:statusline_filetype_modes, ft)
        let result = { 'name': g:statusline_filetype_modes[ft] }

        if has_key(g:statusline_plugin_modes, ft)
            return extend(result, function(g:statusline_plugin_modes[ft])())
        endif

        return result
    endif

    return {}
endfunction

function! statusline#parts#GitBranch(...) abort
    return ''
endfunction

function! statusline#parts#Init() abort
    if g:statusline_show_git_branch > 0
        function! statusline#parts#GitBranch(...) abort
            return statusline#git#Branch()
        endfunction
    endif

    if g:statusline_show_linenr > 1
        function! statusline#parts#LineInfo(...) abort
            return call('s:FullLineInfo', a:000) . ' '
        endfunction
    elseif g:statusline_show_linenr > 0
        function! statusline#parts#LineInfo(...) abort
            return call('s:SimpleLineInfo', a:000) . ' '
        endfunction
    endif
endfunction
