" chalk.vim - Better fold markers
" Author:   Daniel B. Marques
" Version:  0.1
" License:  Same as Vim

if exists("g:loaded_chalk") || &cp
    finish
endif
let g:loaded_chalk = 1

let s:save_cpo = &cpo
set cpo&vim

vnoremap <silent> <Plug>Chalk :call chalk#makeFold(visualmode(), 1)<CR>
nnoremap <silent> <Plug>Chalk :set opfunc=chalk#makeFold<CR>g@

nnoremap <silent> <Plug>ChalkRange :call chalk#makeFold('')<CR>

nnoremap <silent> <Plug>SingleChalk :<C-U>call chalk#makeMarker(0, v:count)<CR>
nnoremap <silent> <Plug>SingleChalkUp :<C-U>call chalk#makeMarker(1, v:count)<CR>

nnoremap <silent> <Plug>ChalkUp :call chalk#incrementPair('+')<CR>
nnoremap <silent> <Plug>ChalkDown :call chalk#incrementPair('-')<CR>

vnoremap <silent> <Plug>ChalkUp :<C-U>call
            \ chalk#incrementMarkers('''<', '''>', '+')<CR>
vnoremap <silent> <Plug>ChalkDown :<C-U>call
            \ chalk#incrementMarkers('''<', '''>', '-')<CR>

command! -range=% ChalkUp
            \ call chalk#incrementMarkers(<line1>, <line2>, '+')
command! -range=% ChalkDown
            \ call chalk#incrementMarkers(<line1>, <line2>, '-')

let &cpo = s:save_cpo
unlet s:save_cpo

