function! statusline#netrw#Mode(...) abort
    let result = {
                \ 'buffer': printf('%s [%s]', get(g:, 'netrw_sort_by', ''), get(g:, 'netrw_sort_direction', 'n') =~ 'n' ? '+' : '-'),
                \ }

    if exists('b:netrw_curdir')
        let result['plugin'] = fnamemodify(b:netrw_curdir, ':p:~:h')
    endif

    return result
endfunction
