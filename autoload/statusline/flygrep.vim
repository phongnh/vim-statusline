" https://github.com/wsdjeg/FlyGrep.vim
function! statusline#flygrep#Mode(...) abort
    return {
                \ 'plugin':   SpaceVim#plugins#flygrep#mode(),
                \ 'filename': fnamemodify(getcwd(), ':~'),
                \ 'buffer':   SpaceVim#plugins#flygrep#lineNr(),
                \ }
endfunction
