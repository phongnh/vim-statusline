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
let g:statusline_powerline             = get(g:, 'statusline_powerline', 0)
let g:statusline_show_tab_close_button = get(g:, 'statusline_show_tab_close_button', 0)
let g:statusline_show_git_branch       = get(g:, 'statusline_show_git_branch', 1)
let g:statusline_show_file_size        = get(g:, 'statusline_show_file_size', 1)
let g:statusline_show_devicons         = get(g:, 'statusline_show_devicons', 1)

" Disable NERDTree statusline
let g:NERDTreeStatusline = -1

" Window width
let s:xsmall_window_width = 60
let s:small_window_width  = 80
let s:normal_window_width = 100

" Number of displayable tabs
let s:displayable_tab_count = 5

" Symbols
let s:symbols = {
            \ 'clipboard':      'ⓒ  ',
            \ 'paste':          'Ⓟ  ',
            \ 'left':           '»',
            \ 'left_alt':       '»',
            \ 'right':          '«',
            \ 'right_alt':      '«',
            \ 'readonly':       '',
            \ 'ellipsis':       '…',
            \ 'left_fill_sep':  ' ',
            \ 'right_fill_sep': ' ',
            \ }

call extend(s:symbols, {
            \ 'left_mode_sep':  ' ' . s:symbols.left_alt . ' ',
            \ 'right_mode_sep': ' ' . s:symbols.right_alt . ' ',
            \ })

let s:powerline_symbols = {
            \ 'left':           '',
            \ 'left_alt':       '',
            \ 'right':          '',
            \ 'right_alt':      '',
            \ }

call extend(s:powerline_symbols, {
            \ 'left_mode_sep':  ' ' . s:powerline_symbols.left_alt . ' ',
            \ 'right_mode_sep': ' ' . s:powerline_symbols.right_alt . ' ',
            \ })

if g:statusline_powerline
    call extend(s:symbols, s:powerline_symbols)
endif

call extend(s:symbols, {
            \ 'left_sep':      ' ' . s:symbols.left . ' ',
            \ 'left_alt_sep':  ' ' . s:symbols.left_alt . ' ',
            \ 'right_sep':     ' ' . s:symbols.right . ' ',
            \ 'right_alt_sep': ' ' . s:symbols.right_alt . ' ',
            \ })

" Alternative Symbols
" ©: Clipboard
"Ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓒ  : Clipboard
"ⓟ  : Paste
"Ⓟ  : Paste
"℗  : Paste
"℗  : Paste
" Ρ: Paste
" ρ: Paste
"Ⓡ  : Readonly
"ⓡ  : Readonly
" ® : Readonly

" Detect DevIcons
let s:has_devicons = findfile('plugin/webdevicons.vim', &rtp) != ''
" let s:has_devicons = exists('*WebDevIconsGetFileTypeSymbol') && exists('*WebDevIconsGetFileFormatSymbol')

" Alternate status dictionaries
let s:filename_modes = {
            \ 'ControlP':             'CtrlP',
            \ '__CtrlSF__':           'CtrlSF',
            \ '__CtrlSFPreview__':    'Preview',
            \ '__Tagbar__':           'Tagbar',
            \ '__Gundo__':            'Gundo',
            \ '__Gundo_Preview__':    'Gundo Preview',
            \ '[BufExplorer]':        'BufExplorer',
            \ '[Command Line]':       'Command Line',
            \ '[Plugins]':            'Plugins',
            \ '__committia_status__': 'Committia Status',
            \ '__committia_diff__':   'Committia Diff',
            \ }

let s:filetype_modes = {
            \ 'netrw':             'NetrwTree',
            \ 'nerdtree':          'NERDTree',
            \ 'startify':          'Startify',
            \ 'tagbar':            'Tagbar',
            \ 'vim-plug':          'Plugins',
            \ 'terminal':          'Terminal',
            \ 'help':              'HELP',
            \ 'qf':                'Quickfix',
            \ 'godoc':             'GoDoc',
            \ 'gedoc':             'GeDoc',
            \ 'gitcommit':         'Commit Message',
            \ 'fugitiveblame':     'FugitiveBlame',
            \ 'gitmessengerpopup': 'Git Messenger',
            \ 'agit':              'Agit',
            \ 'agit_diff':         'Agit Diff',
            \ 'agit_stat':         'Agit Stat',
            \ }

" Hightlight mappings
let g:statusline_colors = {
            \ 'ActiveStatus':    'StatusLine',
            \ 'InactiveStatus':  'StatusLineNC',
            \ 'StatusSeparator': 'LineNr',
            \ 'TabTitle':        'CursorLineNr',
            \ 'TabPlaceholder':  'LineNr',
            \ 'ActiveTab':       'TabLineSel',
            \ 'InactiveTab':     'TabLine',
            \ 'TabSeparator':    'LineNr',
            \ 'CloseButton':     'CursorLineNr',
            \ }

function! s:HiSection(section) abort
    return printf('%%#%s#', g:statusline_colors[a:section])
endfunction

function! s:Strip(str) abort
    if exists('*trim')
        return trim(a:str)
    else
        return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

function! s:Wrap(text) abort
    return printf('%s %s %s', '«', a:text, '»')
endfunction

function! s:ShortenPath(filename) abort
    if exists('*pathshorten')
        return pathshorten(a:filename)
    else
        return substitute(a:filename, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
    endif
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
    let l:sep = get(a:, 1, s:symbols.left_mode_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightMode(parts) abort
    return s:BuildMode(a:parts, s:symbols.right_mode_sep)
endfunction

function! s:BuildFill(parts, ...) abort
    let l:sep = get(a:, 1, s:symbols.left_fill_sep)
    let l:parts = s:ParseList(a:parts, l:sep)
    return join(l:parts, l:sep)
endfunction

function! s:BuildRightFill(parts) abort
    return s:BuildFill(a:parts, s:symbols.right_fill_sep)
endfunction

function! s:GetCurrentDir() abort
    let dir = fnamemodify(getcwd(), ':~:.')
    if empty(dir)
        let dir = getcwd()
    endif
    return dir
endfunction

function! s:GetBufferType() abort
    return strlen(&filetype) ? &filetype : &buftype
endfunction

function! s:GetFileName() abort
    let fname = expand('%:~:.')

    if empty(fname)
        return '[No Name]'
    endif

    return fname
endfunction

function! s:FormatFileName(fname, winwidth, max_width) abort
    let fname = a:fname

    if a:winwidth < s:small_window_width
        return fnamemodify(fname, ':t')
    endif

    if strlen(fname) > a:winwidth && (fname[0] =~ '\~\|/')
        let fname = s:ShortenPath(fname)
    endif

    let max_width = min([a:winwidth, a:max_width])

    if strlen(fname) > max_width
        let fname = fnamemodify(fname, ':t')
    endif

    return fname
endfunction

function! s:ModifiedStatus() abort
    if &modified
        if !&modifiable
            return '[+-]'
        else
            return '[+]'
        endif
    elseif !&modifiable
        return '[-]'
    endif

    return ''
endfunction

function! s:ReadonlyStatus() abort
    return &readonly ? ' ' . s:symbols.readonly . ' ' : ''
endfunction

function! s:GetGitBranch() abort
    let branch = ''

    if exists('*FugitiveHead')
        let branch = FugitiveHead()

        if empty(branch) && exists('*FugitiveDetect') && !exists('b:git_dir')
            call FugitiveDetect(getcwd())
            let branch = FugitiveHead()
        endif
    elseif exists('*fugitive#head')
        let branch = fugitive#head()

        if empty(branch) && exists('*fugitive#detect') && !exists('b:git_dir')
            call fugitive#detect(getcwd())
            let branch = fugitive#head()
        endif
    elseif exists(':Gina') == 2
        let branch = gina#component#repo#branch()
    endif

    return branch
endfunction

function! s:ShortenBranch(branch, length) abort
    let branch = a:branch

    if strlen(branch) > a:length
        let branch = s:ShortenPath(branch)
    endif

    if strlen(branch) > a:length
        let branch = fnamemodify(branch, ':t')
    endif

    return branch
endfunction

function! s:FormatBranch(branch, winwidth) abort
    if a:winwidth >= s:normal_window_width
        return s:ShortenBranch(a:branch, 50)
    endif

    let branch = s:ShortenBranch(a:branch, 30)

    if strlen(branch) > 30
        let branch = strcharpart(branch, 0, 29) . s:symbols.ellipsis
    endif

    return branch
endfunction

function! s:FileNameStatus(...) abort
    let winwidth = get(a:, 1, 100)
    return s:FormatFileName(s:GetFileName(), winwidth, 50) . s:ModifiedStatus() . s:ReadonlyStatus()
endfunction

" Copied from https://github.com/ahmedelgabri/dotfiles/blob/master/files/vim/.vim/autoload/statusline.vim
function! s:FileSize() abort
    let l:size = getfsize(expand('%'))
    if l:size == 0 || l:size == -1 || l:size == -2
        return ''
    endif
    if l:size < 1024
        return l:size . ' bytes'
    elseif l:size < 1024 * 1024
        return printf('%.1f', l:size / 1024.0) . 'k'
    elseif l:size < 1024 * 1024 * 1024
        return printf('%.1f', l:size / 1024.0 / 1024.0) . 'm'
    else
        return printf('%.1f', l:size / 1024.0 / 1024.0 / 1024.0) . 'g'
    endif
endfunction

function! s:FileSizeStatus() abort
    if g:statusline_show_file_size
        return s:FileSize()
    endif
    return ''
endfunction

function! s:IndentationStatus(...) abort
    let shiftwidth = exists('*shiftwidth') ? shiftwidth() : &shiftwidth
    let compact = get(a:, 1, 0)
    if compact
        return printf(&expandtab ? 'SPC: %d' : 'TAB: %d', shiftwidth)
    else
        return printf(&expandtab ? 'Spaces: %d' : 'Tab Size: %d', shiftwidth)
    endif
endfunction

function! s:FileEncodingStatus() abort
    let l:encoding = strlen(&fileencoding) ? &fileencoding : &encoding
    " Show encoding only if it is not utf-8
    if empty(l:encoding) || l:encoding ==# 'utf-8'
        return ''
    endif
    return printf('[%s]', l:encoding)
endfunction

function! s:FileEncodingAndFormatStatus() abort
    let l:encoding = strlen(&fileencoding) ? &fileencoding : &encoding

    if strlen(l:encoding) && strlen(&fileformat)
        let stl = printf('%s[%s]', l:encoding, &fileformat)
    elseif strlen(l:encoding)
        let stl = l:encoding
    else
        let stl = printf('[%s]', &fileformat)
    endif

    " Show format only if it is not utf-8[unix]
    if stl ==# 'utf-8[unix]'
        return ''
    endif

    return stl
endfunction

function! s:FileInfoStatus(...) abort
    let ft = s:GetBufferType()

    if g:statusline_show_devicons && s:has_devicons
        let compact = get(a:, 1, 0)

        let parts = s:RemoveEmptyElement([
                    \ s:FileEncodingStatus(),
                    \ !compact ? WebDevIconsGetFileFormatSymbol() . ' ' : '',
                    \ ft,
                    \ !compact ? WebDevIconsGetFileTypeSymbol(expand('%')) . ' ' : '',
                    \ ])
    else
        let parts = s:RemoveEmptyElement([
                    \ s:FileEncodingAndFormatStatus(),
                    \ ft,
                    \ ])
    endif

    return join(parts, ' ')
endfunction

function! s:GitBranchStatus(...) abort
    if g:statusline_show_git_branch
        let l:winwidth = get(a:, 1, 100)
        return s:FormatBranch(s:GetGitBranch(), l:winwidth)
    endif

    return ''
endfunction

function! s:ClipboardStatus() abort
    if match(&clipboard, 'unnamed') > -1
        return s:symbols.clipboard
    endif
    return ''
endfunction

function! s:PasteStatus() abort
    if &paste
        return s:symbols.paste
    endif
    return ''
endfunction

function! s:SpellStatus() abort
    if &spell
        return toupper(substitute(&spelllang, ',', '/', 'g'))
    endif
    return ''
endfunction

function! s:IsCompact(winwidth) abort
    return &spell || &paste || strlen(s:ClipboardStatus()) || a:winwidth <= s:xsmall_window_width
endfunction

function! s:BuildGroup(exp) abort
    if a:exp =~ '^%'
        return '%( ' . a:exp . ' %)'
    else
        return '%( %{' . a:exp . '} %)'
    endif
endfunction

function! StatusLineActiveMode(...) abort
    " custom status
    let l:mode = s:CustomMode()
    if len(l:mode)
        return s:BuildMode([ l:mode['name'], get(l:mode, 'lmode', '') ])
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))
    let show_more_info = (l:winwidth >= s:small_window_width)

    return s:BuildMode([
                \ show_more_info ? s:GitBranchStatus(l:winwidth) : '',
                \ [s:ClipboardStatus(), s:PasteStatus()],
                \ s:FileNameStatus(l:winwidth - 2)
                \ ])
endfunction

function! StatusLineLeftFill(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'lfill', '')
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    if l:winwidth >= s:small_window_width
        return s:BuildFill(s:FileSizeStatus())
    endif

    return ''
endfunction

function! StatusLineRightMode(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'rmode', '')
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))
    let show_more_info = (l:winwidth >= s:small_window_width)
    let compact = s:IsCompact(l:winwidth)

    return s:BuildRightMode([
                \ show_more_info ? s:IndentationStatus(compact) : '',
                \ s:FileInfoStatus(compact),
                \ ])
endfunction

function! StatusLineRightFill(...) abort
    let l:mode = s:CustomMode()
    if len(l:mode)
        return get(l:mode, 'rfill', '')
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    return s:BuildRightFill(s:SpellStatus())
endfunction

function! StatusLineInactiveMode(...) abort
    " show only custom mode in inactive buffer
    let l:mode = s:CustomMode()
    if len(l:mode)
        return s:BuildMode([ l:mode['name'], get(l:mode, 'lmode_inactive', '') ])
    endif

    let l:winwidth = winwidth(get(a:, 1, 0))

    " « plugin/statusline.vim[+] »
    return s:Wrap(s:FileNameStatus(l:winwidth - 2))
endfunction


function! StatusLine(winnum) abort
    if a:winnum == winnr()
        return join([
                    \ s:HiSection('ActiveStatus'),
                    \ '%<',
                    \ s:BuildGroup(printf('StatusLineActiveMode(%d)', a:winnum)),
                    \ s:HiSection('StatusSeparator'),
                    \ s:BuildGroup(printf('StatusLineLeftFill(%d)', a:winnum)),
                    \ '%=',
                    \ s:BuildGroup(printf('StatusLineRightFill(%d)', a:winnum)),
                    \ '%*',
                    \ '%<',
                    \ s:BuildGroup(printf('StatusLineRightMode(%d)', a:winnum)),
                    \ ], '')
    else
        return s:HiSection('InactiveStatus') .
                    \ '%<' .
                    \ s:BuildGroup(printf('StatusLineInactiveMode(%d)', a:winnum))
    endif
endfunction

" Plugin Integration
" Save plugin states
let s:statusline = {}
let s:statusline_time_threshold = 0.50

function! s:SaveLastTime() abort
    let s:statusline_last_custom_mode_time = reltime()
endfunction

call s:SaveLastTime()

function! s:CustomMode() abort
    if has_key(b:, 'statusline_custom_mode') && reltimefloat(reltime(s:statusline_last_custom_mode_time)) < s:statusline_time_threshold
        return b:statusline_custom_mode
    endif
    let b:statusline_custom_mode = s:FetchCustomMode()
    call s:SaveLastTime()
    return b:statusline_custom_mode
endfunction

function! s:FetchCustomMode() abort
    let fname = expand('%:t')

    if has_key(s:filename_modes, fname)
        let result = {
                    \ 'name': s:filename_modes[fname],
                    \ 'type': 'name',
                    \ }

        if fname ==# 'ControlP'
            return extend(result, s:GetCtrlPMode())
        endif

        if fname ==# '__Tagbar__'
            return extend(result, s:GetTagbarMode())
        endif

        if fname ==# '__CtrlSF__'
            return extend(result, s:GetCtrlSFMode())
        endif

        if fname ==# '__CtrlSFPreview__'
            return extend(result, s:GetCtrlSFPreviewMode())
        endif

        return result
    endif

    if fname =~? '^NrrwRgn'
        let nrrw_rgn_mode = s:GetNrrwRgnMode()
        if len(nrrw_rgn_mode)
            return nrrw_rgn_mode
        endif
    endif

    let ft = s:GetBufferType()
    if has_key(s:filetype_modes, ft)
        let result = {
                    \ 'name': s:filetype_modes[ft],
                    \ 'type': 'filetype',
                    \ }

        if ft ==# 'tagbar'
            return extend(result, s:GetTagbarMode())
        endif

        if ft ==# 'terminal'
            return extend(result, {
                        \ 'lmode': expand('%'),
                        \ })
        endif

        if ft ==# 'help'
            let fname = expand('%:p')
            return extend(result, {
                        \ 'lmode': fname,
                        \ 'lmode_inactive': fname,
                        \ })
        endif

        if ft ==# 'qf'
            if getwininfo(win_getid())[0]['loclist']
                let result['name'] = 'Location'
            endif
            let qf_title = s:Strip(get(w:, 'quickfix_title', ''))
            return extend(result, {
                        \ 'lmode': qf_title,
                        \ 'lmode_inactive': qf_title,
                        \ })
        endif

        return result
    endif

    return {}
endfunction

" CtrlP Integration
let g:ctrlp_status_func = {
            \ 'main': 'CtrlPMainStatusLine',
            \ 'prog': 'CtrlPProgressStatusLine',
            \ }

function! s:GetCtrlPMode() abort
    let lfill = s:BuildFill([
                \ s:statusline.ctrlp_prev,
                \ s:Wrap(s:statusline.ctrlp_item),
                \ s:statusline.ctrlp_next,
                \ ])

    let rfill = s:BuildRightFill([
                \ s:statusline.ctrlp_focus,
                \ '[' . s:statusline.ctrlp_byfname . ']',
                \ ])

    return {
                \ 'name': s:filename_modes['ControlP'],
                \ 'lfill': lfill,
                \ 'rfill': rfill,
                \ 'rmode': s:statusline.ctrlp_dir,
                \ 'type': 'ctrlp',
                \ }
endfunction

function! CtrlPMainStatusLine(focus, byfname, regex, prev, item, next, marked) abort
    let s:statusline.ctrlp_focus   = a:focus
    let s:statusline.ctrlp_byfname = a:byfname
    let s:statusline.ctrlp_regex   = a:regex
    let s:statusline.ctrlp_prev    = a:prev
    let s:statusline.ctrlp_item    = a:item
    let s:statusline.ctrlp_next    = a:next
    let s:statusline.ctrlp_marked  = a:marked
    let s:statusline.ctrlp_dir     = s:GetCurrentDir()

    let b:statusline_custom_mode = s:GetCtrlPMode()
    call s:SaveLastTime()

    return StatusLine(winnr())
endfunction

function! CtrlPProgressStatusLine(len) abort
    let b:statusline_custom_mode = {
                \ 'name': s:filename_modes['ControlP'],
                \ 'lfill': a:len,
                \ 'rmode': s:GetCurrentDir(),
                \ 'type': 'ctrlp',
                \ }
    return StatusLine(winnr())
endfunction

" CtrlSF Integration
function! s:GetCtrlSFMode() abort
    let pattern = substitute(ctrlsf#utils#SectionB(), 'Pattern: ', '', '')
    return {
                \ 'lmode': pattern,
                \ 'lmode_inactive': pattern,
                \ 'lfill': ctrlsf#utils#SectionC(),
                \ 'rmode': ctrlsf#utils#SectionX(),
                \ }
endfunction

function! s:GetCtrlSFPreviewMode() abort
    let stl = ctrlsf#utils#PreviewSectionC()
    return {
                \ 'lmode': stl,
                \ 'lmode_inactive': stl,
                \ }
endfunction

" NrrwRgn Integration
function! s:GetNrrwRgnMode(...) abort
    let result = {}

    if exists(':WidenRegion') == 2
        let result['type'] = 'nrrwrgn'

        if exists('b:nrrw_instn')
            let result['name'] = printf('%s#%d', 'NrrwRgn', b:nrrw_instn)
        else
            let l:mode = substitute(bufname('%'), '^Nrrwrgn_\zs.*\ze_\d\+$', submatch(0), '')
            let l:mode = substitute(l:mode, '__', '#', '')
            let result['name'] = l:mode
        endif

        let dict = exists('*nrrwrgn#NrrwRgnStatus()') ?  nrrwrgn#NrrwRgnStatus() : {}

        if len(dict)
            let result['lmode'] = fnamemodify(dict.fullname, ':~:.')
            let result['lmode_inactive'] = result['lmode']
        elseif get(b:, 'orig_buf', 0)
            let result['lmode'] = bufname(b:orig_buf)
            let result['lmode_inactive'] = result['lmode']
        endif
    endif

    return result
endfunction

" Tagbar Integration
let g:tagbar_status_func = 'TagbarStatusFunc'

function! s:GetTagbarMode() abort
    if empty(s:statusline.tagbar_flags)
        let lfill = ''
    else
        let lfill = printf('[%s]', join(s:statusline.tagbar_flags, ''))
    endif

    return {
                \ 'name': s:statusline.tagbar_sort,
                \ 'lmode': s:statusline.tagbar_fname,
                \ 'lfill': lfill,
                \ 'type': 'tagbar',
                \ }
endfunction

function! TagbarStatusFunc(current, sort, fname, flags, ...) abort
    let s:statusline.tagbar_sort  = a:sort
    let s:statusline.tagbar_fname = a:fname
    let s:statusline.tagbar_flags = a:flags

    let b:statusline_custom_mode = s:GetTagbarMode()
    call s:SaveLastTime()

    return StatusLine(winnr())
endfunction

" ZoomWin Integration
let s:ZoomWin_funcref = []

if exists('g:ZoomWin_funcref')
    if type(g:ZoomWin_funcref) == 2
        let s:ZoomWin_funcref = [g:ZoomWin_funcref]
    elseif type(g:ZoomWin_funcref) == 3
        let s:ZoomWin_funcref = g:ZoomWin_funcref
    endif
endif
let s:ZoomWin_funcref = uniq(copy(s:ZoomWin_funcref))

function! ZoomWinStatusLine(zoomstate) abort
    for F in s:ZoomWin_funcref
        if type(F) == 2 && F != function('ZoomWinStatusLine')
            call F(a:zoomstate)
        endif
    endfor
    call s:RefreshStatusLine()
endfunction

let g:ZoomWin_funcref= function('ZoomWinStatusLine')

" Init statusline

function! s:RefreshStatusLine() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!StatusLine(' . nr . ')')
    endfor
endfunction

command! RefreshStatusLine :call s:RefreshStatusLine()

augroup VimStatusLine
    autocmd!
    autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost * call <SID>RefreshStatusLine()
    if !has('patch-8.1.1715')
        autocmd FileType qf call <SID>RefreshStatusLine()
    endif
    autocmd ColorScheme *
                \ if !has('vim_starting') || expand('<amatch>') !=# 'macvim'
                \   | call <SID>RefreshStatusLine() |
                \ endif
augroup END

" Init tabline
if exists('+tabline')
    function! s:TabPlaceholder(tab) abort
        return s:HiSection('TabPlaceholder') . printf('%%%d  %s %%*', a:tab, s:symbols.ellipsis)
    endfunction

    function! s:TabLabel(tabnr) abort
        let tabnr = a:tabnr
        let winnr = tabpagewinnr(tabnr)
        let buflist = tabpagebuflist(tabnr)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)

        let label = '%' . tabnr . 'T'
        let label .= (tabnr == tabpagenr() ? s:HiSection('ActiveTab') : s:HiSection('InactiveTab'))
        let label .= ' ' . tabnr . ':'

        let dev_icon = ''

        if getbufvar(bufnr, 'buftype') ==# 'nofile'
            if bufname =~ '\/.'
                let bufname = substitute(bufname, '.*\/\ze.', '', '')
            endif
        else
            let bufname = fnamemodify(bufname, ':p:~:.')

            if g:statusline_show_devicons && s:has_devicons
                let dev_icon = ' ' . WebDevIconsGetFileTypeSymbol(bufname) . ' '
            endif

            if bufname[0] =~ '\~\|/'
                let bufname = s:ShortenPath(bufname)
            elseif strlen(bufname) > 30
                let bufname = fnamemodify(bufname, ':t')
            endif
        endif

        if empty(bufname)
            let bufname = '[No Name]'
        endif

        let label .= ' ' . bufname . (getbufvar(bufnr, '&modified') ? '[+]' : '') . dev_icon . ' '

        return label
    endfunction

    function! Tabline() abort
        let stl = s:HiSection('TabTitle') . ' TABS %*'

        let tab_count = tabpagenr('$')
        let max_tab_count = s:displayable_tab_count

        if tab_count <= max_tab_count
            for i in range(1, tab_count)
                let stl .= s:TabLabel(i)
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
                let stl .= s:TabPlaceholder(start_index - 1)
            elseif start_index > 0
                let stl .= s:TabPlaceholder(start_index + 1)
            endif

            let displayable_tabs = tabs[start_index:end_index]

            for i in displayable_tabs
                let stl .= s:TabLabel(i)
            endfor

            if current_index < (tab_count - 1) && end_index < (tab_count - 1)
                let stl .= s:TabPlaceholder(end_index + 1)
            endif
        endif

        let stl .= s:HiSection('TabSeparator') . '%=' . '%*'

        if g:statusline_show_tab_close_button
            let stl .= s:HiSection('CloseButton') . '%999X  X  '
        endif

        return stl
    endfunction

    set tabline=%!Tabline()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
