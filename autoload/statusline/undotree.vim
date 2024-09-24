" https://github.com/mbbill/undotree
function! statusline#undotree#Mode(...) abort
    return {
                \ 'name': 'Undo',
                \ 'plugin': exists('t:undotree') ? t:undotree.GetStatusLine() : '',
                \ }
endfunction

function! statusline#undotree#DiffStatus(...) abort
    return {
                \ 'name': 'Undo',
                \ 'plugin': exists('t:diffpanel') ? t:diffpanel.GetStatusLine() : '',
                \ }
endfunction
