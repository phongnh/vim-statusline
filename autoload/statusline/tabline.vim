" Number of displayable tabs
let s:displayable_tab_count = 5

function! statusline#tabline#Placeholder(tab) abort
    return statusline#Hi('TabLineFill') . printf('%%%d  %s %%*', a:tab, g:statusline_symbols.ellipsis)
endfunction

function! statusline#tabline#Label(tabnr) abort
    let tabnr = a:tabnr
    let winnr = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)

    let label = '%' . tabnr . 'T'
    let label .= (tabnr == tabpagenr() ? statusline#Hi('TabLineSel') : statusline#Hi('TabLine'))
    let label .= ' ' . tabnr . ':'

    let dev_icon = ''

    if getbufvar(bufnr, 'buftype') ==# 'nofile'
        if bufname =~ '\/.'
            let bufname = substitute(bufname, '.*\/\ze.', '', '')
        endif
    else
        let bufname = fnamemodify(bufname, ':p:~:.')

        if g:statusline_show_devicons
            let dev_icon = statusline#devicons#FileType(bufname)
        endif

        if strlen(bufname) > 30
            if bufname[0] =~ '\~\|/' && g:statusline_shorten_path
                let bufname = statusline#ShortenPath(bufname)
            else
                let bufname = fnamemodify(bufname, ':t')
            endif
        endif
    endif

    if empty(bufname)
        let bufname = '[No Name]'
    endif

    let label .= ' ' . bufname . (getbufvar(bufnr, '&modified') ? '[+]' : '') . dev_icon . ' '

    return label
endfunction

function! statusline#tabline#Init() abort
    let stl = statusline#Hi('TabLineSel') . ' ' . g:statusline_symbols.tabs . ' ' . '%*'

    let tab_count = tabpagenr('$')
    let max_tab_count = s:displayable_tab_count

    if tab_count <= max_tab_count
        for i in range(1, tab_count)
            let stl .= statusline#tabline#Label(i)
        endfor
    else
        let tabs = range(1, tab_count)
        let current_tab = tabpagenr()
        let current_index = current_tab - 1

        if current_tab == 1
            let start_index = 0
            let end_index = start_index + (max_tab_count - 1)
        elseif current_tab == tab_count
            let end_index = -1
            let start_index = end_index - (max_tab_count - 1)
        else
            let start_index = current_index - (max_tab_count - 2)
            let start_index = max([start_index, 0])
            let end_index = start_index + (max_tab_count - 1)
        endif

        if current_index == (tab_count - 1)
            let stl .= statusline#tabline#Placeholder(start_index - 1)
        elseif start_index > 0
            let stl .= statusline#tabline#Placeholder(start_index + 1)
        endif

        let displayable_tabs = tabs[start_index:end_index]

        for i in displayable_tabs
            let stl .= statusline#tabline#Label(i)
        endfor

        if current_index < (tab_count - 1) && end_index < (tab_count - 1)
            let stl .= statusline#tabline#Placeholder(end_index + 1)
        endif
    endif

    let stl .= statusline#Hi('TabLineFill') . '%='

    if g:statusline_show_tab_close_button
        let stl .= statusline#Hi('TabLineSel') . '%999X  X  '
    endif

    return stl
endfunction
