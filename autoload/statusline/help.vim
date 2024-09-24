function! statusline#help#Mode(...) abort
    return {
                \ 'name': 'HELP',
                \ 'plugin': expand('%:~:.'),
                \ 'info': statusline#lineinfo#Full(),
                \ }
endfunction
