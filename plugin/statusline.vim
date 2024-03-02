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

function! StatusLineActiveMode(...) abort
    " custom status
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#ModeConcatenate([ l:mode['name'], get(l:mode, 'lmode', '') ])
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    return statusline#ModeConcatenate([
                \ g:statusline_show_git_branch ? statusline#git#Branch() : '',
                \ statusline#parts#FileName(),
                \ ])
endfunction

function! StatusLineLeftFill(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'lfill', '')
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    if l:winwidth >= g:statusline_winwidth_config.small
    endif

    return statusline#ModeConcatenate([
                \ statusline#parts#Clipboard(),
                \ statusline#parts#Paste(),
                \ statusline#parts#Spell(),
                \ ])
endfunction

function! StatusLineRightMode(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'rmode', '')
    endif

    let compact = g:statusline_show_git_branch && statusline#IsCompact(get(a:, 1, 0))
    return statusline#ModeConcatenate([
                \ statusline#parts#Indentation(compact),
                \ statusline#parts#FileType(),
                \ ], 1)
endfunction

function! StatusLineRightFill(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'rfill', '')
    endif
    return ''
endfunction

function! StatusLineInactiveMode(...) abort
    " show only custom mode in inactive buffer
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#ModeConcatenate([ l:mode['name'], get(l:mode, 'lmode_inactive', '') ])
    endif

    " « plugin/statusline.vim[+] »
    return statusline#Wrap(statusline#parts#InactiveFileName())
endfunction

function! StatusLine(winnum) abort
    " Goyo Integration
    if exists('#goyo')
        if a:winnum == winnr()
            return ''
        else
            return statusline#Hi('StNone')
        endif
    endif

    if a:winnum == winnr()
        return join([
                    \ statusline#Hi('StatusLine'),
                    \ '%<',
                    \ statusline#Group(printf('StatusLineActiveMode(%d)', a:winnum)),
                    \ statusline#Group(printf('StatusLineLeftFill(%d)', a:winnum)),
                    \ '%=',
                    \ statusline#Group(printf('StatusLineRightFill(%d)', a:winnum)),
                    \ '%<',
                    \ statusline#Group(printf('StatusLineRightMode(%d)', a:winnum)),
                    \ ], '')
    else
        return statusline#Hi('StatusLineNC') .
                    \ '%<' .
                    \ statusline#Group(printf('StatusLineInactiveMode(%d)', a:winnum))
    endif
endfunction

" Init statusline
augroup VimStatusLine
    autocmd!
    autocmd VimEnter * call statusline#Init()
    autocmd WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost * call statusline#Refresh()
    if !has('patch-8.1.1715')
        autocmd FileType qf call statusline#Refresh()
    endif
    autocmd FileType NvimTree call statusline#Refresh()
    autocmd VimEnter,ColorScheme * call statusline#colors#Init()
    autocmd ColorScheme *
                \ if !has('vim_starting') || expand('<amatch>') !=# 'macvim'
                \   | call statusline#Refresh() |
                \ endif
    autocmd VimResized * call statusline#Refresh()
augroup END

let g:qf_disable_statusline = 1

" Init tabline
if exists('+tabline')
    set tabline=%!statusline#tabline#Init()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
