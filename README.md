# matlab-screen
*For Vim version 8.1* matlab terminal support wit vim

# INTRODUCTION

matlab-screen is a plugin to pass commands to matlab, to make it work more
smoothly by using vim shortcut. Here are main feathers in current version:

    1. Open and Close Matlab under vim 8.1 built-in terminal
    2. Run selected text / Run Matlab cell / Run current file directly
    3. Consult matlab doc/variable under current cursor directly
    4. Some pass some useful command to matlab.

# CONFIGURATION

1.  the matlab run command(must be defined)

    let g:matlab_term_cmd='matlab -nodesktop'

1. default shortcut & Function

    vnoremap <Leader>mr  :call matlab#RunSelected()<CR>
    nnoremap <Leader>mr  :call matlab#RunCell()<CR>
    nnoremap <Leader>mR  :call matlab#RunCurrentFile()<CR>
    nnoremap <Leader>md  :call matlab#GetDoc()<CR>
    nnoremap <Leader>mb  :call matlab#SetBreak()<CR>
    nnoremap <Leader>mv  :call matlab#WatchVarible()<CR>
    nnoremap <Leader>mf  :call matlab#OpenCurrentFile()<CR>
    nnoremap <Leader>maf :call matlab#OpenAllFile()<CR>
    nnoremap <Leader>mw  :call matlab#OpenWorkspace()<CR>
    nnoremap <Leader>mc  :call matlab#ClearVariables()<CR>
    nnoremap <Leader>ms  :call matlab#GetVariableSize()<CR>
    nnoremap <Leader>mt  :call matlab#Toggle()<CR>

1. highlight cell line (start with '%%')
  
    let g:matlab_screen_highlight_cell = 1

# FUNCTION

*matlab#RunSeletected()*
    Run selected line under visual mode in matlab
    
*matlab#RunCell()*
    Run lines between '%% ... %%' in matlab

*matlab#RunCurrentFile()*
    Run current matlab scripts in matlab

*matlab#GetDoc()*
    Refer keyword under current cursor in matlab

*matlab#SetBreak()*
    Set a breakpoint at current line

*matlab#WatchVariable()*
    Open Variables under current cursor(Support struct)

*matlab#OpenCurrentFile()*
    Open current file under matlab file editor

*matlab#OpenAllFile()*
    Open all File in current buffer under matlab file editor

*matlab#OpenWorkspace()*
    Open matlab workspace

*matlab#ClearVariabels()*
    Clear matlab all variables

*matlab#GetVariableSize()*
    show size of keyword (variables) under curent cursor

*matlab#Toggle()*
    Open/Close matlab in vim terminal

*matlab#Start()*
    Open matlab in vim terminal(Only one process should exist)

*matlab#Close()*
    Close matlab in vim terminal
