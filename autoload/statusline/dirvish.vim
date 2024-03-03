" https://github.com/justinmk/vim-dirvish
function! statusline#dirvish#Mode(...) abort
    return { 'plugin': expand('%:p:~:h') }
endfunction
