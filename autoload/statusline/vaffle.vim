" https://github.com/cocopon/vaffle.vim
function! statusline#vaffle#Mode(...) abort
    let bufname = get(a:, 1, expand('%'))
    let dir = get(matchlist(bufname, '^vaffle://\(\d\+\)/\(.\+\)$'), 2, '')
    return { 'plugin': strlen(dir) ? fnamemodify(dir, ':p:~:.:h') : '' }
endfunction
