" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

call statusline#Setup()

function! StatusLine(winnum) abort
    " Goyo Integration
    if exists('#goyo')
        return statusline#Hi('StatusLineNone')
    endif

    if a:winnum == winnr()
        return join([
                    \ statusline#Hi('StatusLine'),
                    \ '%<',
                    \ statusline#Hi('StatusLineMode'),
                    \ statusline#ModeGroup(printf('statusline#sections#Mode(%d)', a:winnum)),
                    \ statusline#Hi('StatusLine'),
                    \ statusline#Group(printf('statusline#sections#Plugin(%d)', a:winnum)),
                    \ statusline#Group(printf('statusline#sections#FileName(%d)', a:winnum)),
                    \ '%=',
                    \ statusline#Group(printf('statusline#sections#Info(%d)', a:winnum)),
                    \ statusline#Group(printf('statusline#sections#Settings(%d)', a:winnum)),
                    \ statusline#Group(printf('statusline#sections#Buffer(%d)', a:winnum)),
                    \ '%<',
                    \ ], '')
    else
        return statusline#Hi('StatusLineNC') .
                    \ '%<' .
                    \ statusline#ModeGroup(printf('statusline#sections#InactiveMode(%d)', a:winnum))
    endif
endfunction

" Init statusline
augroup VimStatusLine
    autocmd!
    autocmd VimEnter * call statusline#Init()
    autocmd ColorScheme * call statusline#colors#Init()
    autocmd VimEnter,WinEnter,BufWinEnter,BufUnload * call statusline#Refresh()
augroup END

" Init tabline
if exists('+tabline')
    set tabline=%!statusline#tabline#Init()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
