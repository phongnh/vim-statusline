function! s:TabPlaceholder(tab) abort
    return statusline#Hi('TabLineSel') . printf('%%%d %s %%*', a:tab, g:statusline_symbols.ellipsis)
endfunction

function! s:TabNumber(n) abort
    return printf('%d: ', a:n)
endfunction

function! s:TabReadonly(bufnr) abort
    return getbufvar(a:bufnr, '&readonly') ? g:statusline_symbols.readonly . ' ' : ''
endfunction

function! s:TabModified(bufnr) abort
    if getbufvar(a:bufnr, '&modified')
        return !getbufvar(a:bufnr, '&modifiable') ? '+-' : '+'
    else
        return !getbufvar(a:bufnr, '&modifiable') ? '-' : ''
    endif
endfunction

function! s:TabBufferType(bufnr) abort
    let ft = getbufvar(a:bufnr, '&filetype')
    return strlen(ft) ? ft : getbufvar(a:bufnr, '&buftype')
endfunction

function s:TabBufferName(bufnr) abort
    let bufname = bufname(a:bufnr)
    let buftype = s:TabBufferType(a:bufnr)

    if has_key(g:statusline_filetype_modes, buftype)
        return g:statusline_filetype_modes[buftype]
    endif

    let fname = fnamemodify(bufname, ':t')
    if has_key(g:statusline_filename_modes, fname)
        return g:statusline_filename_modes[fname]
    endif

    if buftype ==# 'nofile' && bufname =~ '\/.'
        let bufname = substitute(bufname, '.*\/\ze.', '', '')
    endif

    let bufname = fnamemodify(bufname, ':p:~:.')

    if strlen(bufname) > 30
        if bufname[0] =~ '\~\|/' && g:statusline_shorten_path
            let bufname = statusline#ShortenPath(bufname)
        else
            let bufname = fnamemodify(bufname, ':t')
        endif
    endif

    if bufname =~# '^\[preview'
        return 'Preview'
    else
        return join(filter([empty(bufname) ? '[No Name]' : bufname, s:TabModified(a:bufnr)], 'v:val !=# ""'), g:statusline_symbols.space)
    endif
endfunction

function! s:TabName(tabnr) abort
    let winnr = tabpagewinnr(a:tabnr)
    let bufnr = tabpagebuflist(a:tabnr)[winnr - 1]
    let label = '%' . a:tabnr . 'T'
    let label .= (a:tabnr == tabpagenr() ? statusline#Hi('TabLineSel') : statusline#Hi('TabLine'))
    let label .= g:statusline_symbols.space . s:TabNumber(a:tabnr) . s:TabReadonly(bufnr) . s:TabBufferName(bufnr) . g:statusline_symbols.space
    return label
endfunction

function! s:GetMaxTabs() abort
    if &columns >= 120
        return &columns / 35 
    else
        return 3
    endif
endfunction

function! statusline#tabline#Init() abort
    let max_tabs = s:GetMaxTabs()
    let tab_count = tabpagenr('$')

    let tab_label = g:statusline_symbols.tabs . (tab_count > max_tabs ? printf(' [%d]', tab_count) : '')
    let stl = statusline#Hi('TabLineLabel') . ' ' . tab_label . ' ' . '%*'

    if tab_count <= max_tabs
        for i in range(1, tab_count)
            let stl .= s:TabName(i)
        endfor
    else
        let current_tab = tabpagenr()
        let current_index = current_tab - 1

        if current_tab == 1
            let start_index = 0
            let end_index = start_index + (max_tabs - 1)
        elseif current_tab == tab_count
            let end_index = -1
            let start_index = end_index - (max_tabs - 1)
        else
            let start_index = current_index - (max_tabs - 2)
            let start_index = max([start_index, 0])
            let end_index = start_index + (max_tabs - 1)
        endif

        if current_index == (tab_count - 1)
            let stl .= s:TabPlaceholder(start_index - 1)
        elseif start_index > 0
            let stl .= s:TabPlaceholder(start_index + 1)
        endif

        for i in range(1, tab_count)[start_index:end_index]
            let stl .= s:TabName(i)
        endfor

        if current_index < (tab_count - 1) && end_index < (tab_count - 1)
            let stl .= s:TabPlaceholder(end_index + 1)
        endif
    endif

    let stl .= statusline#Hi('TabLineFill') . '%='

    if g:statusline_show_tab_close_button
        " let stl .= statusline#Hi('TabLineSel') . '%999X  X  '
        let stl .= statusline#Hi('TabLineClose') . '%999X  ×  '
    endif

    return stl
endfunction
