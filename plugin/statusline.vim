" statusline.vim
" Maintainer: Phong Nguyen
" Version:    0.1.0

if exists('g:loaded_vim_statusline')
    finish
endif

let g:loaded_vim_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

" Settings
let g:statusline_powerline_fonts       = get(g:, 'statusline_powerline_fonts', 0)
let g:statusline_mode                  = get(g:, 'statusline_mode', 'default')
let g:statusline_shorten_path          = get(g:, 'statusline_shorten_path', 0)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 1)
let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 1)
let g:statusline_show_vim_logo         = get(g:, 'statusline_show_vim_logo', 1)

if g:statusline_mode ==? 'minimal'
    let g:statusline_show_git_branch = 0
    let g:statusline_show_devicons   = 0
endif

" Window width
let g:statusline_winwidth_config = extend({
            \ 'compact': 60,
            \ 'small':   80,
            \ 'normal':  120,
            \ }, get(g:, 'statusline_winwidth_config', {}))

" Disable NERDTree statusline
let g:NERDTreeStatusline = -1

" Symbols: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
let g:statusline_symbols = {
            \ 'dos':            '[dos]',
            \ 'mac':            '[mac]',
            \ 'unix':           '[unix]',
            \ 'tabs':           'TABS',
            \ 'linenr':         '☰',
            \ 'branch':         '⎇ ',
            \ 'readonly':       '',
            \ 'bomb':           '🅑 ',
            \ 'noeol':          '∉ ',
            \ 'clipboard':      '🅒 ',
            \ 'paste':          '🅟 ',
            \ 'ellipsis':       '…',
            \ 'left':           '»',
            \ 'left_alt':       '»',
            \ 'right':          '«',
            \ 'right_alt':      '«',
            \ 'left_fill_sep':  ' ',
            \ 'right_fill_sep': ' ',
            \ }

if g:statusline_powerline_fonts
    " Powerline Symbols
    call extend(g:statusline_symbols, {
                \ 'left':      "\ue0b0",
                \ 'right':     "\ue0b2",
                \ 'left_alt':  "\ue0b1",
                \ 'right_alt': "\ue0b3",
                \ })
endif

let g:statusline_show_devicons = g:statusline_show_devicons && statusline#devicons#Detect()

if g:statusline_show_devicons
    call extend(g:statusline_symbols, {
                \ 'bomb':  "\ue287 ",
                \ 'noeol': "\ue293 ",
                \ 'dos':   "\ue70f",
                \ 'mac':   "\ue711",
                \ 'unix':  "\ue712",
                \ })
    let g:statusline_symbols.unix = '[unix]'
endif

" Show Vim Logo in Tabline
if g:statusline_show_devicons && g:statusline_show_vim_logo
    let g:statusline_symbols.tabs = "\ue7c5 "
endif

call extend(g:statusline_symbols, {
            \ 'left_mode_sep':  ' ' . g:statusline_symbols.left_alt . ' ',
            \ 'right_mode_sep': ' ' . g:statusline_symbols.right_alt . ' ',
            \ 'left_sep':       ' ' . g:statusline_symbols.left . ' ',
            \ 'left_alt_sep':   ' ' . g:statusline_symbols.left_alt . ' ',
            \ 'right_sep':      ' ' . g:statusline_symbols.right . ' ',
            \ 'right_alt_sep':  ' ' . g:statusline_symbols.right_alt . ' ',
            \ })

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
                    \ statusline#Hi('StItem'),
                    \ '%<',
                    \ statusline#Group(printf('StatusLineActiveMode(%d)', a:winnum)),
                    \ statusline#Hi('StSep'),
                    \ statusline#Group(printf('StatusLineLeftFill(%d)', a:winnum)),
                    \ statusline#Hi('StFill'),
                    \ '%=',
                    \ statusline#Group(printf('StatusLineRightFill(%d)', a:winnum)),
                    \ statusline#Hi('StInfo'),
                    \ '%<',
                    \ statusline#Group(printf('StatusLineRightMode(%d)', a:winnum)),
                    \ ], '')
    else
        return statusline#Hi('StItemNC') .
                    \ '%<' .
                    \ statusline#Group(printf('StatusLineInactiveMode(%d)', a:winnum))
    endif
endfunction

" Init statusline
command! RefreshStatusLine call statusline#Refresh()

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
