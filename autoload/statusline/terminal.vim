function! statusline#terminal#Mode(...) abort
    return { 'name': 'TERMINAL', 'lmode': expand('%') }
endfunction
