function! statusline#gitcommit#Mode(...) abort
    return { 'lfill': statusline#parts#Spell() }
endfunction
