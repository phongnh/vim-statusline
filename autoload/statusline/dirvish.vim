" https://github.com/justinmk/vim-dirvish
function! statusline#dirvish#Mode(...) abort
    return { 'lfill': expand('%:p:~:h') }
endfunction
