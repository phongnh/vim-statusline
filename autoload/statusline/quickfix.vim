function! statusline#quickfix#Mode(...) abort
    let result = {}
    if getwininfo(win_getid())[0]['loclist']
        let result['name'] = 'Location'
    endif
    let qf_title = statusline#Trim(get(w:, 'quickfix_title', ''))
    return extend(result, {
                \ 'lmode': qf_title,
                \ 'lmode_inactive': qf_title,
                \ })
endfunction
