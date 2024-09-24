" https://github.com/justinmk/vim-dirvish
function! statusline#dirvish#Mode(...) abort
    return { 'plugin': fnamemodify(expand('%'), ':p:~:.:h') }
endfunction
