" https://github.com/SidOfc/carbon.nvim
function! statusline#carbon#Mode(...) abort
    let result = {}

    if exists('b:carbon')
        let result['plugin'] = fnamemodify(b:carbon['path'], ':p:~:.:h')
    endif

    return result
endfunction
