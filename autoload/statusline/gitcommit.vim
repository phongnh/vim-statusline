function! statusline#gitcommit#Mode(...) abort
    return {
                \ 'name': statusline#Concatenate([
                \   'Commit Message',
                \   statusline#parts#Spell(),
                \ ]),
                \ 'plugin': statusline#git#Branch(),
                \ 'info': statusline#lineinfo#Simple(),
                \ }
endfunction
