func! Handler(channel, msg)
    echom a:msg
endfunc
function! s:matlab_job_start(matlabcmd)
    call job_start(["screen","-S","matlab","-X","stuff",a:matlabcmd],
                \{'callback':'Handler'})
endfunction

function! matlab#runSeleted() range
    execute "'<,'> write! ".expand('%:p:h')."/matlab_tmp.m"
    call job_start(["/bin/bash","-c","echo delete\\(\\'matlab_tmp.m\\'\\)\\; >> ".
                \expand('%:p:h')."/matlab_tmp.m"],{'callback':'Handler'})
    call job_start(["/bin/bash","-c","echo -n ".expand('%:p:h').">/tmp/vim_screen_pwd.tmp"])
    call job_start(["screen","-S","matlab","-X","stuff",
                \"cd(vim_matlab_getpwd());matlab_tmp^M"],{'callback':'Handler'})
endfunction
function! matlab#runCurrentFile()
    call job_start(["/bin/bash","-c","echo -n ".expand('%:p:h').">/tmp/vim_screen_pwd.tmp"])
    let matlabcmd = 'cd(vim_matlab_getpwd());'.
                \strpart(expand('%:t'),0,len(expand('%:t'))-2).'^M'
    call s:matlab_job_start(matlabcmd)
    call s:UpdateMatlabDebugLine()
endfunction
function! matlab#getDoc()
    let matlabcmd = "doc ".expand("<cword>")."^M"
    call s:matlab_job_start(matlabcmd)
endfunction
function! matlab#openVariable()
    let var_name = substitute(getline('.'),'^.*[a-zA-Z0-9._]\@<!\(\S*\%'.
                \col('.').'c\k*\).*$','\1', '')
    call s:matlab_job_start("openvar ".var_name."^M")
endfunction
function! matlab#dispVariable()
    let var_name = substitute(getline('.'),'^.*[a-zA-Z0-9._]\@<!\(\S*\%'.
                \col('.').'c\k*\).*$','\1', '')
    call s:matlab_job_start("disp(".var_name.")^M")
endfunction
function! matlab#openCurrentFile()
    call job_start(["/bin/bash","-c","echo ".expand('%:p').">/tmp/vim_screen_pwd.tmp"])
    call s:matlab_job_start("vim_matlab_edit^M")
endfunction
function! matlab#openAllFiles()
    let currentBuffer = 1
    let allFileStr = ''
    call job_start(["/bin/bash","-c","echo -n >/tmp/vim_screen_pwd.tmp"])
    while currentBuffer <= bufnr('$')
        if bufexists(currentBuffer)
            if expand('#'.string(currentBuffer).':e') != 'm'
                let currentBuffer = currentBuffer + 1
                continue
            endif
            call job_start(["/bin/bash","-c","echo ".
                        \expand('#'.string(currentBuffer).':p').
                        \">>/tmp/vim_screen_pwd.tmp"])
        endif
        let currentBuffer = currentBuffer + 1
    endwhile
    call s:matlab_job_start("vim_matlab_edit^M")
endfunction
function! matlab#openWorkspace()
    call s:matlab_job_start("workspace^M")
endfunction
function! matlab#clearAllVaribles()
    call s:matlab_job_start("clear^M")
endfunction
function! matlab#suspend()
    call s:matlab_job_start("^c^M")
endfunction
function! matlab#getVaribleSize()
    let var_name = substitute(getline('.'),'^.*[a-zA-Z0-9._]\@<!\(\S*\%'.
                \col('.').'c\k*\).*$','\1', '')
    call s:matlab_job_start("size(".var_name.")^M")
endfunction
function! matlab#debug_setBreak()
    let matlabcmd = "dbstop in ".expand('%:p')." at ".line(".")."^M"
    call s:matlab_job_start(matlabcmd)
    call s:updateMatlabBreakInfo()
endfunction
function! matlab#debug_clearAllBreaks()
    call s:matlab_job_start("dbclear all^M")
    call s:updateMatlabBreakInfo()
endfunction
function! matlab#debug_step()
    call s:matlab_job_start("dbstep^M")
    call s:UpdateMatlabDebugLine()
endfunction
if !exists("*s:matlab#debug_stepIn")
function! matlab#debug_stepIn()
    call s:matlab_job_start("dbstep in^M")
    call s:UpdateMatlabDebugLine()
endfunction
endif
function! matlab#debug_stepOut()
    call s:matlab_job_start("dbstep out^M")
    call s:UpdateMatlabDebugLine()
endfunction
function! matlab#debug_continue()
    call s:matlab_job_start("dbcont^M")
    call s:UpdateMatlabDebugLine()
endfunction
function! matlab#debug_quit()
    call s:matlab_job_start("dbquit^M")
    call s:UpdateMatlabDebugLine()
endfunction

function! s:updateMatlabBreakInfo()
    if !empty(glob('/tmp/vim_screen_matlab.tmp'))
        call delete('/tmp/vim_screen_matlab.tmp')
    endif
    call s:matlab_job_start("vim_matlab_dbstatus^M")
    for i in range(1,10)
        if !empty(glob('/tmp/vim_screen_matlab.tmp'))
            break
        endif
        if i == 9
            echom "Please UpdateMatlab first!"
            return
        endif
        sleep 100m
    endfor
    let retfile = readfile('/tmp/vim_screen_matlab.tmp')

    if exists("g:sign_BreakPoint") && len(g:sign_BreakPoint) > 0
        for i in g:sign_BreakPoint
            execute "sign unplace ".i[1]
        endfor
    endif
    let g:sign_BreakPoint = []
    for l in retfile
        let s = split(l)
        if s[0]=='dbstatus'
            if bufnr(s[1]) > 0
                for bp in s[2:]
                    execute "sign place ".bp. " line=".bp." name=MatlabBreakPoint file=".s[1]
                    let g:sign_BreakPoint = add(g:sign_BreakPoint,[bp,bp,s[1]])
                endfor
            endif
        endif
    endfor
endfunction

if !exists("*s:UpdateMatlabDebugLine1")
function! UpdateMatlabDebugLine_job(channel,msg)
    let retfile = readfile('/tmp/vim_screen_matlab.tmp')
    execute "sign unplace 10086"
    for l in retfile
        let s = split(l)
        if s[0]=='dbstack'
            if bufnr(s[1]) > 0 && s[2] > 0
                execute "sign place 10086 line=".s[2]." name=MatlabDebugLine file=".s[1]
                execute "buffer ".s[1]
                call cursor(s[2],1)
            elseif bufnr(s[1]) > 0 && s[2] < 0
                execute "sign unplace 10086"
            else
                execute "edit ".s[1]
                execute "sign place 10086 line=".s[2]." name=MatlabDebugLine file=".s[1]
                execute "buffer ".s[1]
                call cursor(s[2],1)
            endif
        endif
    endfor
endfunction
endif
if !exists("*s:UpdateMatlabDebugLine")
function! s:UpdateMatlabDebugLine()
    if !empty(glob('/tmp/vim_screen_matlab.tmp'))
        call delete('/tmp/vim_screen_matlab.tmp')
    endif
    call s:matlab_job_start("vim_matlab_dbstack(dbstack('-completenames'))^M")
    call job_start(['/bin/bash','-c','while true;do if [ -f /tmp/vim_screen_matlab.tmp  ];then break;else sleep 0.1;fi;done'],{'exit_cb':'UpdateMatlabDebugLine_job'})
endfunction
endif

if !exists("*matlab#update")
function! matlab#update()
    call s:updateMatlabBreakInfo()
    call s:UpdateMatlabDebugLine()
endfunction
endif

sign define MatlabBreakPoint text=B- texthl=Search
sign define MatlabDebugLine linehl=IncSearch

vnoremap <Leader>mr  :call matlab#runSeleted()<CR>
nnoremap <expr> <Leader>mr  matlab#runCurrentFile()
nnoremap <expr> <Leader>md  matlab#getDoc()
nnoremap <expr> <Leader>mv  matlab#openVariable()
nnoremap <expr> <Leader>mV  matlab#dispVariable()
nnoremap <expr> <Leader>mf  matlab#openCurrentFile()
nnoremap <expr> <Leader>maf matlab#openAllFiles()
nnoremap <expr> <Leader>mw  matlab#openWorkspace()
nnoremap <expr> <Leader>mc  matlab#clearAllVaribles()
nnoremap <expr> <Leader>mC  matlab#suspend()
nnoremap <expr> <Leader>ms  matlab#getVaribleSize()
nnoremap <expr> <Leader>mu  matlab#update()

nnoremap <expr> <Leader>mb  matlab#debug_setBreak()
nnoremap <expr> <Leader>mB  matlab#debug_clearAllBreaks()
nnoremap <expr> <F5> matlab#debug_continue()
nnoremap <expr> <F6> matlab#debug_step()
nnoremap <expr> <F7> matlab#debug_stepIn()
nnoremap <expr> <F8> matlab#debug_stepOut()
nnoremap <expr> <F9> matlab#debug_quit()
