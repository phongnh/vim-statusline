function! statusline#sections#Mode(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return l:mode['name']
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
        return statusline#Prepend(get(l:mode, 'plugin', ''))
    endif
    return statusline#Prepend(call('s:RenderPluginSection', a:000))
endfunction

function! s:RenderPluginSection(...) abort
    let l:winnr = get(a:, 1, 0)

    if g:statusline_show_git_branch && winwidth(l:winnr) >= g:statusline_winwidth_config.normal
        return statusline#git#Branch()
    endif

    return ''
endfunction

function! statusline#sections#FileName(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#Prepend(get(l:mode, 'filename', ''))
    endif
    return statusline#Prepend(call('s:RenderFileNameSection', a:000))
endfunction

function! s:RenderFileNameSection(...) abort
    return statusline#parts#FileName()
endfunction

function! statusline#sections#Buffer(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return get(l:mode, 'buffer', '')
    endif
    return call('s:RenderBufferSection', a:000)
endfunction

function! s:RenderBufferSection(...) abort
    return statusline#parts#FileType()
endfunction

function! statusline#sections#Settings(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#Append(get(l:mode, 'settings', ''))
    endif
    return statusline#Append(call('s:RenderSettingsSection', a:000))
endfunction

function! s:RenderSettingsSection(...) abort
    let l:winnr = get(a:, 1, 0)
    if winwidth(0) <= g:statusline_winwidth_config.compact
        return ''
    endif
    let l:compact = statusline#IsCompact(l:winnr)
    return statusline#Concatenate([
                \ statusline#parts#Indentation(l:compact),
                \ statusline#parts#FileEncodingAndFormat(),
                \ ], 1)
endfunction

function! statusline#sections#Info(...) abort
    let l:mode = statusline#parts#Integration()
    if len(l:mode)
        return statusline#Append(get(l:mode, 'info', ''))
    endif
    return statusline#Append(call('s:RenderInfoSection', a:000))
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
                    \ get(l:mode, 'plugin', ''),
                    \ get(l:mode, 'filename', ''),
                    \ ])
    endif
    return call('s:RenderInactiveModeSection', a:000)
endfunction

function! s:RenderInactiveModeSection(...) abort
    " plugin/statusline.vim[+]
    return statusline#parts#InactiveFileName()
endfunction
