" https://github.com/stevearc/oil.nvim
function! statusline#oil#Mode(...) abort
    let result = {}

    let l:oil_dir = get(a:, 1, expand('%'))
    if l:oil_dir =~# '^oil://'
        let l:oil_dir = substitute(l:oil_dir, '^oil://', '', '')
        let result['lfill'] = fnamemodify(l:oil_dir, ':p:~:.:h')
    elseif exists('b:oil_ready') && b:oil_ready
        let result['lfill'] = fnamemodify(luaeval('require("oil").get_current_dir()'), ':p:~:.:h')
    endif

    return result
endfunction
