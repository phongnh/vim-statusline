" https://github.com/liuchengxu/vista.vim
function! statusline#vista#Mode(...) abort
    let provider = get(get(g:, 'vista', {}), 'provider', '')
    return { 'plugin': provider }
endfunction
