function! statusline#colors#Extract(name) abort
    let l:hl_id         = hlID(a:name)
    let l:guibg         = synIDattr(l:hl_id, 'bg', 'gui')
    let l:guifg         = synIDattr(l:hl_id, 'fg', 'gui')
    let l:ctermbg       = synIDattr(l:hl_id, 'bg', 'cterm')
    let l:ctermfg       = synIDattr(l:hl_id, 'fg', 'cterm')
    let l:gui_reverse   = synIDattr(l:hl_id, 'reverse', 'gui')
    let l:cterm_reverse = synIDattr(l:hl_id, 'reverse', 'cterm')
    return {
                \ 'guibg':         l:guibg,
                \ 'guifg':         l:guifg,
                \ 'ctermbg':       l:ctermbg,
                \ 'ctermfg':       l:ctermfg,
                \ 'gui_reverse':   l:gui_reverse,
                \ 'cterm_reverse': l:cterm_reverse,
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

    highlight! link TabLineClose TabLineSel

    let l:status_line = statusline#colors#Extract('StatusLine')
    call statusline#colors#Highlight('StatusLineMode', {
                \ 'ctermbg': l:status_line['cterm_reverse'] ? l:status_line['ctermfg'] : l:status_line['ctermbg'],
                \ 'ctermfg': l:status_line['cterm_reverse'] ? l:status_line['ctermbg'] : l:status_line['ctermfg'],
                \ 'guibg':   l:status_line['gui_reverse']   ? l:status_line['guifg']   : l:status_line['guibg'],
                \ 'guifg':   l:status_line['gui_reverse']   ? l:status_line['guibg']   : l:status_line['guifg'],
                \ 'cterm':   'bold',
                \ 'gui':     'bold',
                \ })

    let l:tab_line_sel = statusline#colors#Extract('TabLineSel')
    call statusline#colors#Highlight('TabLineLabel', {
                \ 'ctermbg': l:tab_line_sel['cterm_reverse'] ? l:tab_line_sel['ctermfg'] : l:tab_line_sel['ctermbg'],
                \ 'ctermfg': l:tab_line_sel['cterm_reverse'] ? l:tab_line_sel['ctermbg'] : l:tab_line_sel['ctermfg'],
                \ 'guibg':   l:tab_line_sel['gui_reverse']   ? l:tab_line_sel['guifg']   : l:tab_line_sel['guibg'],
                \ 'guifg':   l:tab_line_sel['gui_reverse']   ? l:tab_line_sel['guibg']   : l:tab_line_sel['guifg'],
                \ 'cterm':   'bold',
                \ 'gui':     'bold',
                \ })
endfunction
