" https://github.com/preservim/tagbar
let s:statusline_tagbar = {}

function! statusline#tagbar#Status(current, sort, fname, flags, ...) abort
    let s:statusline_tagbar.sort  = a:sort
    let s:statusline_tagbar.fname = a:fname
    let s:statusline_tagbar.flags = a:flags

    return StatusLine(a:current ? winnr() : 0)
endfunction

function! statusline#tagbar#Mode(...) abort
    if empty(s:statusline_tagbar.flags)
        let flags = ''
    else
        let flags = printf('[%s]', join(s:statusline_tagbar.flags, ''))
    endif

    return {
                \ 'name': s:statusline_tagbar.sort,
                \ 'lmode': s:statusline_tagbar.fname,
                \ 'lfill': flags,
                \ }
endfunction
