@echo off
if exist objlist.dat del objlist.dat >nul
bin\srcwiz %1.asm
echo.
bin\tasm -80 -g3 -r12 -ll %1.asm
if errorlevel 1 goto errors
echo.
if exist objlist.dat bin\srcwiz %1.obj -r
bin\string85 %1.obj %2
if exist %1.bak del %1.bak >nul
if exist %1.lst del %1.lst >nul
if "%2"=="f" goto obj
if exist %1.obj del %1.obj >nul
copy %1.85s prgm
del %1.85s
link85
goto done
:errors
if exist %1.bak del %1.bak >nul
if exist %1.lst del %1.lst >nul
if exist %1.obj del %1.obj >nul
echo ERRORS!
goto done
:obj
if exist %1.85s del %1.85s >nul
bin\insert %1.obj 0 >nul
copy %1.obj obj\ >nul
del %1.obj
:done
call reloc$$$.bat
del reloc$$$.bat >nul
if exist objlist.dat del objlist.dat >nul
