" https://github.com/tpope/vim-fugitive
function! statusline#fugitive#Mode(...) abort
    return {
                \ 'plugin': statusline#git#Branch(),
                \ 'filename': exists('b:fugitive_type') ? b:fugitive_type : '',
                \ }
endfunction
