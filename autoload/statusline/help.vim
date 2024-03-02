function! statusline#help#Mode(...) abort
    return { 'name': 'HELP', 'lmode': expand('%:p'), 'lmode_inactive': expand('%:p') }
endfunction
