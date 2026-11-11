@echo off
setlocal
cd /d "%~dp0"
title Tray Icon Auto Show - START
if not exist "%~dp0TrayIconAutoShow.ps1" (
    echo ERROR: TrayIconAutoShow.ps1 is missing.
    echo Extract the whole ZIP to one folder and run Start.cmd again.
    echo.
    pause
    exit /b 1
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0TrayIconAutoShow.ps1" -Mode Install
if errorlevel 1 (
    echo.
    echo Installation failed. Read the error above.
)
echo.
pause
