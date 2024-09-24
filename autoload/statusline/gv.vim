" https://github.com/junegunn/gv.vim
function! statusline#gv#Mode(...) abort
    return {
                \ 'plugin': statusline#Concatenate([
                \   'o: open split',
                \   'O: open tab',
                \   'gb: GBrowse',
                \   'q: quit',
                \ ]),
                \ 'info': statusline#lineinfo#Simple(),
                \ }
endfunction
