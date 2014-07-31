@echo off
setlocal

if "%HOME%"=="" set HOME=%USERPROFILE%

mklink "%HOME%\_vimrc" "%~dp0.vimrc"
mklink "%HOME%\_gvimrc" "%~dp0.gvimrc"

pause
