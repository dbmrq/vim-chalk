" chalk.vim - Better fold markers
" Author:   Daniel B. Marques
" Version:  1.0
" License:  Same as Vim

if exists("g:autoloaded_chalk") || &cp
    finish
endif
let g:autoloaded_chalk = 1

let s:save_cpo = &cpo
set cpo&vim

" Align markers ......................................................... {{{1
function! chalk#align()
    let comments = split(&l:commentstring, '%s')
    let openingComment = len(comments) > 0 ? comments[0] : ""
    let closingComment = len(comments) > 1 ? comments[1] : ""
    let markers = split(substitute(&l:foldmarker, ' ', '', 'g'), ',')
    let openingMarker = markers[0]
    let closingMarker = markers[1]
    let regex = '\(.*\)'
    let regex .= escape(openingComment, '/\^$.*~[]&')
    let regex .= '\(\s\)\?'
    let regex .= '\([^' . g:chalk_char . ']\{-}\s\)\?'
    let regex .= '\(\A\{2,}\)\?'
    let regex .= '\(' . escape(openingMarker, '/\^$.*~[]&') . '\|'
                \ . escape(closingMarker, '/\^$.*~[]&') . '\)'
    let regex .= '\(\d\)\?'
    let regex .= '\(\s\)\?'
    let regex .= '\(' . escape(closingComment, '/\^$.*~[]&') . '\)\?'
    let fillerCount = '&l:textwidth - strchars('
    let fillerCount .= 'submatch(1) . '
    let fillerCount .= '"' . escape(openingComment, '/') . '" . " " . '
    let fillerCount .= 'submatch(3) . " " . submatch(5) . '
    let fillerCount .= 'submatch(6) . submatch(7) . submatch(8))'
    let replacement = '\=submatch(1) . '
    let replacement .= '"' . escape(openingComment, '/\^$.*~[]&') . '" . " " . '
    let replacement .= 'submatch(3) . '
    let replacement .= 'repeat("' . g:chalk_char . '", ' . fillerCount . ') . '
    let replacement .= '" " . submatch(5) . '
    let replacement .= 'submatch(6) . submatch(7) . submatch(8)'
    " let replacement = '\=submatch(3)'
    execute "%s/" . regex . "/" . replacement . "/g"
endfunction
" ....................................................................... }}}1

" Get current fold ...................................................... {{{1
function! s:currentFold()
    let l:winview = winsaveview()
    let markers = split(&l:foldmarker, ',')
    if matchstr(getline('.'), markers[0]) != ""
        let openLine = line('.')
        normal! ]z
        let closeLine = line('.')
    elseif matchstr(getline('.'), markers[1]) != ""
        let closeLine = line('.')
        normal! [z
        let openLine = line('.')
    else
        normal! [z
        let openLine = line('.')
        normal! ]z
        let closeLine = line('.')
    endif
    call winrestview(l:winview)
    return [openLine, closeLine]
endfunction
" ....................................................................... }}}1

" Add marker to line .................................................... {{{1
function! s:addMarker(line, position, level)
    let lineText = substitute(getline(a:line), '^\s*\(.\{-}\)\s*$', '\1', '')
    let comments = split(&l:commentstring, '%s')
    let openingComment = len(comments) > 0 &&
        \ lineText !~ escape(comments[0], '/\^$.*~[]&') ? comments[0] : ""
    let closingComment = len(comments) > 1 ? " " . comments[1] : ""
    if len(comments) > 1
        let lineText = substitute(lineText,
            \ escape(comments[1], '/\^$.*~[]&') . "$", "", "")
        let lineText = substitute(lineText, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
    let markers = split(substitute(&l:foldmarker, ' ', '', 'g'), ',')
    let marker = a:position == 'close' ? markers[1] : markers[0]
    let openingString = lineText . openingComment . " "
    let closingString = marker . a:level . closingComment
    let spacesCount = &l:textwidth - strchars(openingString . closingString)
    let spacesCount = g:chalk_align == 1 && spacesCount > 0 ? spacesCount : 1
    let spaces = repeat(g:chalk_char, spacesCount - 1) . " "
    call setline(a:line, openingString . spaces . closingString)
endfunction
" ....................................................................... }}}1

" Increment all markers in range ........................................ {{{1
function! chalk#incrementMarkers(first_line, last_line, operator)
    let l:winview = winsaveview()
    let range = a:first_line . ',' . a:last_line
    let markers = split(&l:foldmarker, ',')
    let markers = '\(' . markers[0] . '\|' . markers[1] . '\)'
    silent! execute range . 's/' . markers .
                \ '\zs\d\+\ze/\=submatch(0)'. a:operator . '1/g'
    let level = foldlevel('.') + 2
    silent! execute range . 's/' . markers  . '$/\1' . level . '/g'
    call winrestview(l:winview)
endfunction
" ....................................................................... }}}1

" Increment current pair of markers ..................................... {{{1
function! chalk#incrementPair(operator)
    if a:operator == '-' && foldlevel('.') <= 1 | return | endif
    let lines = s:currentFold()
    let markers = split(&l:foldmarker, ',')
    let both = matchstr(getline(lines[0]), markers[0] . '\zs\d\+\ze') ==
                \ matchstr(getline(lines[1]), markers[1] . '\zs\d\+\ze')
    call chalk#incrementMarkers(lines[0], lines[0], a:operator)
    if both
        call chalk#incrementMarkers(lines[1], lines[1], a:operator)
    endif
endfunction
" ....................................................................... }}}1

" Create fold with single marker ........................................ {{{1
function! chalk#makeMarker(increment, ...)
    if a:0 && a:1
        let level = a:1
    else
        let level = a:increment ? foldlevel('.') + 1 : foldlevel('.')
    endif
    let level = level == 0 ? 1 : level
    call s:addMarker(line('.'), 'open', level)
    call s:editFoldText(line('.'))
endfunction
" ....................................................................... }}}1

" Create fold with opening and closing markers .......................... {{{1
function! chalk#makeFold(type, ...) range
    if a:0 == 1 || a:type == ''
        let first_line = a:firstline
        let last_line = a:lastline
    else
        let first_line = line('''[')
        let last_line = line(''']')
    endif
    if first_line == last_line | return | endif
    let level = foldlevel('.')
    call chalk#incrementMarkers(first_line, last_line, '+')
    call s:addMarker(first_line, 'open', level + 1)
    call s:addMarker(last_line, 'close', level + 1)
    call s:editFoldText(first_line)
endfunction
" ....................................................................... }}}1

" Edit the fold text .................................................... {{{1
function! s:editFoldText(line)
    if g:chalk_edit == 1
        if g:chalk_align == 1
        let regex = escape(repeat(g:chalk_char, 4), '/\^$.*~[]&')
        else
            let comments = split(&l:commentstring, '%s')
            let comment = len(comments) > 0 ? comments[0] : ""
            let regex = escape(comment . " ", '/\^$.*~[]&') . "/e"
        endif
        if match(getline('.'), regex) < 0
            return
        endif
        execute "normal! zv"
        silent! execute "normal! /" . regex . "\<CR>"
        if g:chalk_align == 1
            startreplace
        else
            execute "normal! l"
            startinsert
        endif
    endif
endfunction
" ....................................................................... }}}1

let &cpo = s:save_cpo
unlet s:save_cpo

