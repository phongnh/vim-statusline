" https://github.com/dyng/ctrlsf.vim
function! statusline#ctrlsf#Mode(...) abort
    let pattern = substitute(ctrlsf#utils#SectionB(), 'Pattern: ', '', '')

    return {
                \ 'plugin': pattern,
                \ 'filename': fnamemodify(ctrlsf#utils#SectionC(), ':~:.'),
                \ 'buffer': ctrlsf#utils#SectionX(),
                \ }
endfunction

function! statusline#ctrlsf#PreviewMode(...) abort
    return { 'filename': fnamemodify(ctrlsf#utils#PreviewSectionC(), ':~:.') }
endfunction
