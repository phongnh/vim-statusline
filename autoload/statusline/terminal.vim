function! statusline#terminal#Mode(...) abort
    return { 'name': 'TERMINAL', 'plugin': expand('%') }
endfunction
