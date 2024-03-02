" Caching
let s:statusline_time_threshold = 0.50
let s:statusline_last_finding_branch_time = reltime()

function! s:ShortenBranch(branch, length) abort
    let branch = a:branch

    if strlen(branch) > a:length && g:statusline_shorten_path
        let branch = statusline#ShortenPath(branch)
    endif

    if strlen(branch) > a:length
        let branch = fnamemodify(branch, ':t')
    endif

    if strlen(branch) > a:length
        " Show only JIRA ticket prefix
        let branch = substitute(branch, '^\([A-Z]\{3,}-\d\{1,}\)-.\+', '\1', '')
    endif

    return branch
endfunction

function! s:FormatBranch(branch) abort
    if winwidth(0) >= g:statusline_winwidth_config.normal
        return s:ShortenBranch(a:branch, 50)
    endif

    let branch = s:ShortenBranch(a:branch, 30)

    if strlen(branch) > 30
        let branch = strcharpart(branch, 0, 29) . g:statusline_symbols.ellipsis
    endif

    return branch
endfunction

function! s:GetGitBranch() abort
    " Get branch from caching if it is available
    if has_key(b:, 'statusline_git_branch') && reltimefloat(reltime(s:statusline_last_finding_branch_time)) < s:statusline_time_threshold
        return b:statusline_git_branch
    endif

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

    " Caching
    let b:statusline_git_branch = branch
    let s:statusline_last_finding_branch_time = reltime()

    return branch
endfunction

function! statusline#git#Branch(...) abort
    let branch = s:FormatBranch(s:GetGitBranch())

    if strlen(branch)
        return g:statusline_symbols.branch . ' ' . branch
    endif

    return branch
endfunction
