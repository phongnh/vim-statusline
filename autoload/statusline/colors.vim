function! statusline#colors#Extract(name) abort
    let l:hl_id   = hlID(a:name)
    let l:guibg   = synIDattr(l:hl_id, 'bg', 'gui')
    let l:guifg   = synIDattr(l:hl_id, 'fg', 'gui')
    let l:ctermbg = synIDattr(l:hl_id, 'bg', 'cterm')
    let l:ctermfg = synIDattr(l:hl_id, 'fg', 'cterm')
    return {
                \ 'guibg': l:guibg,
                \ 'guifg': l:guifg,
                \ 'ctermbg': l:ctermbg,
                \ 'ctermfg': l:ctermfg,
                \ }
endfunction

function! statusline#colors#Highlight(group, attrs) abort
    let l:cmd = printf('highlight! %s', a:group)
    for [key, value] in items(a:attrs)
        if !empty(value)
            let l:cmd .= printf(' %s=%s', key, value)
        endif
    endfor
    silent! execute l:cmd
endfunction

function! statusline#colors#Init() abort
    highlight! StNone guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE

    let l:st_item = statusline#colors#Extract('StatusLine')
    call extend(l:st_item, {
                \ 'gui':   'bold',
                \ 'cterm': 'bold',
                \ })

    call statusline#colors#Highlight('StItem', l:st_item)
    call statusline#colors#Highlight('StStep', l:st_item)
    call statusline#colors#Highlight('StFill', l:st_item)
    call statusline#colors#Highlight('StInfo', l:st_item)

    let l:st_item_nc = statusline#colors#Extract('LineNr')
    call statusline#colors#Highlight('StItemNC', l:st_item_nc)

    call statusline#colors#Highlight('StTabItem', l:st_item)
    call statusline#colors#Highlight('StTabTitle', l:st_item)
    call statusline#colors#Highlight('StTabFill', l:st_item)
    call statusline#colors#Highlight('StTabCloseButton', l:st_item)

    let l:st_tab_item_nc = statusline#colors#Extract('StatusLineNC')
    call statusline#colors#Highlight('StTabItemNC', l:st_tab_item_nc)
endfunction
