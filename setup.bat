@echo off

if not exist "%HOME%" (
    echo please set environment variable %^HOME%.
    goto finally
)

ver|find "XP">nul
if %errorlevel% == 0 goto make_hardlink
goto make_symlink

:make_symlink
if exist "%HOME%\\_vimrc" del "%HOME%\\_vimrc"
mklink "%HOME%\\_vimrc" "%~dp0.vimrc"
if exist "%HOME%\\_gvimrc" del "%HOME%\\_gvimrc"
mklink "%HOME%\\_gvimrc" "%~dp0.gvimrc"
goto finally

:make_hardlink
if exist "%HOME%\\_vimrc" del "%HOME%\\_vimrc"
fsutil hardlink create "%HOME%\\_vimrc" "%~dp0.vimrc"
if exist "%HOME%\\_gvimrc" del "%HOME%\\_gvimrc"
fsutil hardlink create "%HOME%\\_gvimrc" "%~dp0.gvimrc"
goto finally

:finally
pause
