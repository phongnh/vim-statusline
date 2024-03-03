function! statusline#sections#Mode(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#Concatenate([
                    \ l:mode['name'],
                    \ get(l:mode, 'lmode', ''),
                    \ ])
    endif

    return statusline#Concatenate([
                \ statusline#parts#Mode(),
                \ statusline#parts#Clipboard(),
                \ statusline#parts#Paste(),
                \ statusline#parts#Spell(),
                \ ])
endfunction

function! statusline#sections#Plugin(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'lfill', '')
    endif
    return call('s:RenderPluginSection', a:000)
endfunction

function! s:RenderPluginSection(...) abort
    let l:winnr = get(a:, 1, 0)

    if g:statusline_show_git_branch && winwidth(l:winnr) >= g:statusline_winwidth_config.small
        return statusline#Concatenate([
                    \ statusline#git#Branch(),
                    \ statusline#parts#FileName(),
                    \ ])
    endif

    return statusline#parts#FileName()
endfunction

function! statusline#sections#FileName(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'filename', '')
    endif
    return call('s:RenderFileNameSection', a:000)
endfunction

function! s:RenderFileNameSection(...) abort
    let l:winwidth = winwidth(get(a:, 1, 0))

    if l:winwidth >= g:statusline_winwidth_config.small
    endif

    return ''
endfunction

function! statusline#sections#Buffer(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'rmode', '')
    endif
    return call('s:RenderBufferSection', a:000)
endfunction

function! s:RenderBufferSection(...) abort
    return statusline#parts#FileType()
endfunction

function! statusline#sections#Settings(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'rfill', '')
    endif
    return call('s:RenderSettingsSection', a:000)
endfunction

function! s:RenderSettingsSection(...) abort
    let l:winnr = get(a:, 1, 0)
    let l:compact = statusline#IsCompact(l:winnr)
    return statusline#Concatenate([
                \ statusline#parts#Indentation(l:compact),
                \ statusline#parts#FileEncodingAndFormat(),
                \ ], 1)
endfunction

function! statusline#sections#Info(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'info', '')
    endif
    return call('s:RenderInfoSection', a:000)
endfunction

function! s:RenderInfoSection(...) abort
    return ''
endfunction

function! statusline#sections#InactiveMode(...) abort
    " Show only custom mode in inactive buffer
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#Concatenate([
                    \ l:mode['name'],
                    \ get(l:mode, 'lmode_inactive', ''),
                    \ get(l:mode, 'filename', ''),
                    \ ])
    endif
    return call('s:RenderInactiveModeSection', a:000)
endfunction

function! s:RenderInactiveModeSection(...) abort
    " plugin/statusline.vim[+]
    return statusline#parts#InactiveFileName()
endfunction
