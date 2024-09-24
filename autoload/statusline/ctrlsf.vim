" https://github.com/dyng/ctrlsf.vim
function! statusline#ctrlsf#Mode(...) abort
    return {
                \ 'plugin': substitute(ctrlsf#utils#SectionB(), 'Pattern: ', '', ''),
                \ 'filename': fnamemodify(ctrlsf#utils#SectionC(), ':p:~:.'),
                \ 'buffer': ctrlsf#utils#SectionX(),
                \ }
endfunction

function! statusline#ctrlsf#PreviewMode(...) abort
    return { 'filename': fnamemodify(ctrlsf#utils#PreviewSectionC(), ':~:.') }
endfunction
