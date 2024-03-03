" https://github.com/ctrlpvim/ctrlp.vim
let s:statusline_ctrlp = {}

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
                \ 'buffer': s:statusline_ctrlp.dir,
                \ }

    if s:statusline_ctrlp.main
        let plugin = statusline#Concatenate([
                    \ s:statusline_ctrlp.prev,
                    \ statusline#Wrap(s:statusline_ctrlp.item),
                    \ s:statusline_ctrlp.next,
                    \ ])

        let settings = statusline#Concatenate([
                    \ s:statusline_ctrlp.focus,
                    \ '[' . s:statusline_ctrlp.byfname . ']',
                    \ ], 1)

        call extend(result, {
                    \ 'plugin': plugin,
                    \ 'settings': settings,
                    \ })
    else
        call extend(result, {
                    \ 'plugin': s:statusline_ctrlp.len,
                    \ })
    endif

    return result
endfunction
