" https://github.com/nvim-neo-tree/neo-tree.nvim
function! statusline#neotree#Mode(...) abort
    let result = {}

    if exists('b:neo_tree_source')
        let result['lfill'] = b:neo_tree_source
    endif

    return result
endfunction

