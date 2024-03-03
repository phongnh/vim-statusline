function! statusline#help#Mode(...) abort
    return { 'name': 'HELP', 'plugin': expand('%:p') }
endfunction
