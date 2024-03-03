function! statusline#quickfix#Mode(...) abort
    return {
                \ 'name': getwininfo(win_getid())[0]['loclist'] ? 'Location' : 'Quickfix',
                \ 'plugin': statusline#Trim(get(w:, 'quickfix_title', '')),
                \ }
endfunction
