" https://github.com/ctrlpvim/ctrlp.vim
let s:statusline_ctrlp = {}

" TODO: Move these variables and functions to autload and reuse them
function! s:Wrap(text) abort
    return printf('%s %s %s', '«', a:text, '»')
endfunction

function! s:RemoveEmptyElement(list) abort
    return filter(copy(a:list), '!empty(v:val)')
endfunction

function! s:EnsureList(list) abort
    return type(a:list) == type([]) ? deepcopy(a:list) : [a:list]
endfunction

function! s:ParseList(list, sep) abort
    let l:list = s:EnsureList(a:list)
    let l:list = map(copy(l:list), "type(v:val) == type([]) ? join(s:RemoveEmptyElement(v:val), a:sep) : v:val")
    return s:RemoveEmptyElement(l:list)
endfunction

function! s:BuildMode(parts, ...) abort
    let l:sep = get(a:, 1, g:statusline_symbols.left_mode_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightMode(parts) abort
    return s:BuildMode(a:parts, g:statusline_symbols.right_mode_sep)
endfunction

function! s:BuildFill(parts, ...) abort
    let l:sep = get(a:, 1, g:statusline_symbols.left_fill_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightFill(parts) abort
    return s:BuildFill(a:parts, g:statusline_symbols.right_fill_sep)
endfunction
function! s:GetCurrentDir() abort
    let dir = fnamemodify(getcwd(), ':~:.')
    return empty(dir) ? getcwd() : dir
endfunction

function! statusline#ctrlp#MainStatus(focus, byfname, regex, prev, item, next, marked) abort
    let s:statusline_ctrlp.main    = 1
    let s:statusline_ctrlp.focus   = a:focus
    let s:statusline_ctrlp.byfname = a:byfname
    let s:statusline_ctrlp.regex   = a:regex
    let s:statusline_ctrlp.prev    = a:prev
    let s:statusline_ctrlp.item    = a:item
    let s:statusline_ctrlp.next    = a:next
    let s:statusline_ctrlp.marked  = a:marked
    let s:statusline_ctrlp.dir     = s:GetCurrentDir()

    return StatusLine(winnr())
endfunction

function! statusline#ctrlp#ProgressStatus(len) abort
    let s:statusline_ctrlp.main = 0
    let s:statusline_ctrlp.len  = a:len
    let s:statusline_ctrlp.dir  = s:GetCurrentDir()

    return StatusLine(winnr())
endfunction

function! statusline#ctrlp#Mode(...) abort
    let result = {
                \ 'name': 'CtrlP',
                \ 'rmode': s:statusline_ctrlp.dir,
                \ }

    if s:statusline_ctrlp.main
        let lfill = s:BuildFill([
                    \ s:statusline_ctrlp.prev,
                    \ s:Wrap(s:statusline_ctrlp.item),
                    \ s:statusline_ctrlp.next,
                    \ ])

        let rfill = s:BuildRightFill([
                    \ s:statusline_ctrlp.focus,
                    \ '[' . s:statusline_ctrlp.byfname . ']',
                    \ ])

        call extend(result, {
                    \ 'lfill': lfill,
                    \ 'rfill': rfill,
                    \ })
    else
        call extend(result, {
                    \ 'lfill': s:statusline_ctrlp.len,
                    \ })
    endif

    return result
endfunction
