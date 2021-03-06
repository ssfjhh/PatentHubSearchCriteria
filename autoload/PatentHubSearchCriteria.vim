augroup filetype_PatentHubSearchCriteria
    autocmd!
    " nnoremap <localleader>b :call Beauty()<cr>
    " nnoremap <localleader>o :call PatentHubSearchCriteria#JoinLinesWithOR()<cr>
    " nnoremap <localleader>s :call PatentHubSearchCriteria#SplitLineWithOR()<cr>
    " nnoremap <localleader>i :call PatentHubSearchCriteria#SortIPC()<cr>
    " nnoremap <localleader>e :call PatentHubSearchCriteria#GetElements()<cr>
    " 从检索式生成检索要素（去除括号， and or not = 等字符)
    " nnoremap <localleader>c :call PatentHubSearchCriteria#Copy_oneline()<cr>
    " nnoremap <localleader>f :call PatentHubSearchCriteria#GenerateSCFromList()<cr>
    " nnoremap <localleader>F :call PatentHubSearchCriteria#GenerateListFromSC()<cr>

    " for Wubi input method
    " iabbrev 巨 and
    " iabbrev 煌 or
    " iabbrev 刷业务 not

    " for Pinyin input method
    " iabbrev 安定 and
    " iabbrev 偶然 or
    " iabbrev 农田 not

    " iabbrev （ (
    " iabbrev ） )
augroup END

function! s:PrettyLine(line)
    let l:line = substitute(a:line, '\c\([a-z0-9-]\+\)\s*:\s*', '\L\1 : ', 'g')
    let l:line = substitute(l:line, '\c\S\zs\s*\<\(and\|or\|to\)\>\s*\ze\S', ' \L\1 ', 'g')
    let l:line = substitute(l:line, '\c\_^\s*\zs\<\(and\|not\)\>\s*', '\L\1 ', 'g')
    let l:line = substitute(l:line, '\c\_^\s*\zs\<\(or\)\>\s*', '\L\1  ', 'g')
    let l:line = substitute(l:line, '\([\[(]\)\s*\ze\S', '\1', 'g')
    let l:line = substitute(l:line, '\S\zs\s*\([\])]\)', '\1', 'g')
    let l:line = substitute(l:line, '\c[A-Z0-9]\@<!\([A-HY]\|[A-HY]\d\{2}\|[A-HY]\d\{2}[A-Z]\|[A-HY]\d\{2}[A-Z]\d\{1,4}\|[A-HY]\d\{2}[A-Z]\d\{1,4}\/\d\{1,5}\)[/A-Z0-9]\@!', '\U\1', 'g')
    let l:line = substitute(l:line, '\s\+$', '', 'g')
    let l:line = substitute(l:line, '\(\s*\<or\>\s*\)\{2,}', ' or ', 'g')
    return l:line
endfunction

function! PatentHubSearchCriteria#Beauty()
    let l:saveCursor = getpos(".")
    let l:unnamed = getreg('"')
    let l:lines = getline(1, '$')
    call map(l:lines, 's:PrettyLine(v:val)')
    execute("%delete")
    call setline(1, l:lines)
    call setpos(".", l:saveCursor)
    call setreg('"', l:unnamed)
    echo "Beauty run over!"
    unlet l:saveCursor
    unlet l:unnamed
    unlet l:lines
endfunction

function! PatentHubSearchCriteria#Copy_oneline()
    let l:lines = getline(1, '$')
    call map(l:lines, 's:PrettyLine(v:val)')
    let l:string = join(l:lines, "\n")
    let l:string = substitute(l:string, '\_s\+', " ", "g")
    let l:string = substitute(l:string, '[\(\[]\zs\_s\+', "", "g")
    let l:string = substitute(l:string, '\_s\+\ze[\)\]]', "", "g")
    let @+ = substitute(l:string, '^\_s\+\|\_s\+$', "", "g")
    echom "Oneline-PatentHubSearchCriteria has been copied to clipboard!"
    unlet l:lines
endfunction


function! PatentHubSearchCriteria#JoinLinesWithOR() range
    let l:saveCursor = getpos(".")
    let l:unnamed = getreg('"')
    if a:firstline ==# a:lastline
        if a:lastline ==# line('$')
            return 0
        else
            let l:lastline = a:lastline + 1
        endif
    else
        let l:lastline = a:lastline
    endif

    let l:_indent = repeat(" ", indent(a:firstline))
    let l:lines = getline(a:firstline, l:lastline)
    call map(l:lines, 'trim(v:val)')
    let l:string = join(l:lines, ' or ')
    let l:string = substitute(l:string, '\(\s*\<or\>\s*\)\{2,}', ' or ', 'g')
    silent execute a:firstline . "," . l:lastline . 'delete'
    call append(a:firstline - 1, l:_indent . l:string)
    call setpos(".", l:saveCursor)
    call setreg('"', l:unnamed)
    unlet l:saveCursor
    unlet l:_indent
    unlet l:lines
    unlet l:string
    unlet l:unnamed
endfunction


function! PatentHubSearchCriteria#SplitLineWithOR() range
    let l:saveCursor = getpos(".")
    let l:unnamed = getreg('"')
    let l:_indent = repeat(" ", indent(a:firstline))
    let l:string = join(getline(a:firstline, a:lastline), ' or ')
    let l:string = trim(l:string)
    let l:lines = uniq(split(l:string, '\c\(\s*\<or\>\s*\)\+'), "i")
    call map(l:lines, 'l:_indent . v:val')
    silent execute a:firstline . "," . a:lastline . 'delete'
    call append(a:firstline - 1, l:lines)
    call setpos(".", l:saveCursor)
    echom len(l:lines) . " keywords found."
    call setreg('"', l:unnamed)
    unlet l:saveCursor
    unlet l:_indent
    unlet l:lines
    unlet l:string
    unlet l:unnamed
endfunction

function! PatentHubSearchCriteria#SortInBracket() range
    let l:savePos = getpos(".")
    let l:unnamed = getreg('"')
    execute "normal! vi)\<esc>"
    let l:_indent = repeat(" ", indent("'<"))
    normal! gvd
    let l:lines = sort(uniq(split(trim(getreg('"')), '\c\(\n\|\(\s*\<or\>\s*\)\)\+'), "i"), "i")
    call map(l:lines, 'trim(v:val)')
    call filter(l:lines, 'strlen(v:val)')
    call map(l:lines, 'substitute(v:val, "\\c\[a-z]\\+", "\\u\\L&", "g")')
    let l:res = []
    for l:line in l:lines
        if len(l:res) == 0
            call add(l:res, l:_indent . l:line)
        elseif strlen(get(l:res, -1)) < 100
            let l:res[-1] .= " or " . l:line
        else
            call add(l:res, l:_indent[:-5] . "or  " . l:line)
        endif
    endfor
    let @" = join(l:res, "\n") . "\n"
    normal! P
    call setpos(".", l:savePos)
    call setreg('"', l:unnamed)
    unlet l:_indent
    unlet l:lines
    unlet l:res
    unlet l:unnamed
endfunction

function! PatentHubSearchCriteria#GenerateSCFromList()
    let l:unnamed = getreg('"')
    let l:lines = getline(1, "$")
    call filter(l:lines, 'v:val !~ "^\\s*\\d\\|隐藏\\|不公开\\|^\\s*$"')
    call map(l:lines, 'substitute(v:val, "\\d\\{1,2}\.\\d\\{1,2}%$", "", "g")')
    call map(l:lines, 'substitute(v:val, "^[ \"]*\\|[ \"]*$", "\"", "g")')
    call sort(uniq(l:lines, "i"), "i")
    execute("%delete")
    let l:l0 = "ap : (" . join(l:lines, ' or ') . ")"
    let l:l1 = "aee : (" . join(l:lines, ' or ') . ")"
    let l:l01 = "(" . l:l0 . " or " . l:l1 . ")"
    call setline(1, l:l01)
    call setpos(".", [0, 1, 1, 0])
    call setreg('"', l:unnamed)
    unlet l:lines
    unlet l:l0
    unlet l:l1
    unlet l:l01
    unlet l:unnamed
endfunction

function! PatentHubSearchCriteria#GenerateListFromSC()
    let l:save_register_plus = @z
    let l:save_register_unnamed = @"
    execute 'normal! gg/ap\s*:\s*(/e' . "\<cr>" . '"zyi)ggdG'
    let l:lines = sort(uniq(split(trim(@z), '\c\(\s*\<or\>\s*\)\+'), 'i'), "i")
    call map(l:lines, 'substitute(v:val, "\\w\\+", "\\L\\u&", "g")')
    call setline(1, l:lines)
    let @z = l:save_register_plus
    let @" = l:save_register_unnamed
    unlet l:save_register_plus
    unlet l:save_register_unnamed
    unlet l:lines
endfunction

function! PatentHubSearchCriteria#GetElements() range
    let l:lines = getline(a:firstline, a:lastline)
    let l:lines = map(l:lines, 'substitute(v:val, "\\(ti\\|eti\\|cti\\|ab\\|eab\\|cab\\|cl\\|ecl\\|d\\|eds\\|ap\\|fap\\|addr\\|aee\\|caee\\|in\\|ag\\|at\\|n\\|dn\\|an\\|pr\\|dd\\|ddy\\|ddm\\|ad\\|ady\\|adm\\|pctDate\\|ipc\\|ipc-section\\|ipc-class\\|ipc-subclass\\|ipc-group\\|ipc-subgroup\\|ipc-main\\|ipcm-section\\|ipcm-class\\|ipcm-subclass\\|ipcm-group\\|ipcm-subgroup\\|uspc\\|uspcc\\|fi\\|ft\\|loc\\|cpc\\|ls\\|currentStatus\\|type\\|cc\\|acc\\|kc\\|lang\\|apt\\|ap-zip\\|country\\|province\\|city\\|aeet\\|caeet\\|agc\\|legalTag\\|legalEvent\\|maintainYears\\|citedCount\\|citingCount\\|level\\|judgment\\.date\\|judgment\\.title\\|judgment\\.caseId\\|judgment\\.court\\|judgment\\.province\\|judgment\\.city\\|judgment\\.accuser\\|judgment\\.defendant\\)\\s*:\\s*", " ", "g")')
    " 删除字段名称
    let l:lines = map(l:lines, 'substitute(v:val, "\\c\\s*\\<\\(and\\|or\\|not\\)\\>\\+\\s*", " ", "g")')
    " 删除and or not
    let l:lines = map(l:lines, 'substitute(v:val, "\\s*[:：\\[\\]()（）]\\+\\s*", " ", "g")')
    " 删除方括号和圆括号
    let l:lines = map(l:lines, 'substitute(v:val, "\\s\\+", " ", "g")')
    " 多个连续的空格替换为单个空格
    call map(l:lines, 'trim(v:val)')
    let l:lines = filter(l:lines, 'v:val !~ "^\\s*$"')
    call uniq(l:lines, "i")
    " let @+ = join(l:lines, "\n")
    call setreg("+", join(l:lines, "\n"))
    echo len(l:lines) . " 行检索要素已经被复制到剪贴板！"
    unlet l:lines
endfunction
