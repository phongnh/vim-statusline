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
    highlight! StatusLineNone guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE

    let l:mode = statusline#colors#Extract('StatusLine')
    call extend(l:mode, {
                \ 'cterm': 'bold,reverse',
                \ })
    call statusline#colors#Highlight('StatusLineMode', l:mode)
endfunction
