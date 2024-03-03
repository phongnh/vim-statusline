function! statusline#gitcommit#Mode(...) abort
    return { 'plugin': statusline#parts#Spell() }
endfunction
