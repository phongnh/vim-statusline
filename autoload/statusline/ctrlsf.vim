" https://github.com/dyng/ctrlsf.vim
function! statusline#ctrlsf#Mode(...) abort
    let pattern = substitute(ctrlsf#utils#SectionB(), 'Pattern: ', '', '')

    return {
                \ 'lmode': pattern,
                \ 'lmode_inactive': pattern,
                \ 'lfill': fnamemodify(ctrlsf#utils#SectionC(), ':~:.'),
                \ 'rmode': ctrlsf#utils#SectionX(),
                \ }
endfunction

function! statusline#ctrlsf#PreviewMode(...) abort
    return {
                \ 'lmode': fnamemodify(ctrlsf#utils#PreviewSectionC(), ':~:.'),
                \ 'lmode_inactive': fnamemodify(ctrlsf#utils#PreviewSectionC(), ':~:.'),
                \ }
endfunction
