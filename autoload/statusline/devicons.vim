function! statusline#devicons#FileType(filename) abort
    return ''
endfunction

function! statusline#devicons#Detect() abort
    if findfile('autoload/nerdfont.vim', &rtp) != ''
        function! statusline#devicons#FileType(filename) abort
            return ' ' . nerdfont#find(a:filename) . ' '
        endfunction

        return 1
    elseif findfile('plugin/webdevicons.vim', &rtp) != ''
        function! statusline#devicons#FileType(filename) abort
            return ' ' . WebDevIconsGetFileTypeSymbol(a:filename) . ' '
        endfunction

        return 1
    elseif exists('g:StatuslineWebDevIconsFind')
        function! statusline#devicons#FileType(filename) abort
            return ' ' . g:StatuslineWebDevIconsFind(a:filename) . ' '
        endfunction

        return 1
    endif

    return 0
endfunction
