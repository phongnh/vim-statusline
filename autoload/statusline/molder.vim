" https://github.com/mattn/vim-molder
function! statusline#molder#Mode(...) abort
    let result = {}

    if exists('b:molder_dir')
        let result['lfill'] = fnamemodify(b:molder_dir, ':p:~:h')
    endif

    return result
endfunction
