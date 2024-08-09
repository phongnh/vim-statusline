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
let g:statusline_shorten_path          = get(g:, 'statusline_shorten_path', 0)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 0)
let g:statusline_show_linenr           = get(g:, 'statusline_show_linenr', 0)
let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 0) && statusline#devicons#Detect()

" Window width
let g:statusline_winwidth_config = extend({
            \ 'compact': 60,
            \ 'default': 90,
            \ 'normal':  120,
            \ }, get(g:, 'statusline_winwidth_config', {}))


" Improved Model Labels
let g:statusline_mode_labels = {
            \ 'n':  'NORMAL',
            \ 'c':  'COMMAND',
            \ 'r':  'NORMAL',
            \ '!':  'NORMAL',
            \ 'i':  'INSERT',
            \ 't':  'TERMINAL',
            \ 'v':  'VISUAL',
            \ 'V':  'V-LINE',
            \ '': 'V-BLOCK',
            \ 's':  'SELECT',
            \ 'S':  'S-LINE',
            \ '': 'S-BLOCK',
            \ 'R':  'REPLACE',
            \ '':   '',
            \ }

" Short Modes
let g:statusline_short_mode_labels = {
            \ 'n':  'N',
            \ 'c':  'C',
            \ 'r':  'N',
            \ '!':  'N',
            \ 'i':  'I',
            \ 't':  'T',
            \ 'v':  'V',
            \ 'V':  'L',
            \ '': 'B',
            \ 's':  'S',
            \ 'S':  'S-L',
            \ '': 'S-B',
            \ 'R':  'R ',
            \ '':   '',
            \ }

" Symbols: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
let g:statusline_symbols = extend({
            \ 'dos':       '[dos]',
            \ 'mac':       '[mac]',
            \ 'unix':      '[unix]',
            \ 'tabs':      'TABS',
            \ 'space':     ' ',
            \ 'linenr':    '☰',
            \ 'branch':    '⎇ ',
            \ 'readonly':  '',
            \ 'bomb':      '🅑 ',
            \ 'noeol':     '∉ ',
            \ 'clipboard': '🅒 ',
            \ 'paste':     '🅟 ',
            \ 'ellipsis':  '…',
            \ 'left':      '→',
            \ 'right':     '←',
            \ }, get(g:, 'statusline_symbols', {}))

if g:statusline_powerline_fonts || g:statusline_show_devicons
    " Powerline Symbols
    call extend(g:statusline_symbols, {
                \ 'linenr':   "\ue0a1",
                \ 'branch':   "\ue0a0",
                \ 'readonly': "\ue0a2",
                \ })
endif

if g:statusline_show_devicons
    call extend(g:statusline_symbols, {
                \ 'tabs':  "\ue7c5 ",
                \ 'bomb':  "\ue287 ",
                \ 'noeol': "\ue293 ",
                \ 'dos':   "\ue70f",
                \ 'mac':   "\ue711",
                \ 'unix':  "\ue712",
                \ })
    let g:statusline_symbols.unix = '[unix]'
endif

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
    autocmd VimEnter * call statusline#Init() | call statusline#colors#Init()
    autocmd ColorScheme * call statusline#colors#Init()
    autocmd OptionSet background call statusline#colors#Init()
    autocmd VimEnter,WinEnter,BufWinEnter,BufUnload * call statusline#Refresh()
augroup END

" Init tabline
if exists('+tabline')
    set tabline=%!statusline#tabline#Init()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
