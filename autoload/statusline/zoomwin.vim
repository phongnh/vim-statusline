" https://github.com/phongnh/ZoomWin
function! statusline#zoomwin#Status(zoomstate) abort
    for F in g:statusline_zoomwin_funcref
        if type(F) == v:t_func && F != function('statusline#zoomwin#Status')
            call F(a:zoomstate)
        endif
    endfor
    call statusline#Refresh()
endfunction
