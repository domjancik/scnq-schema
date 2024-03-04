@echo off
echo Loading Schema Studio, please wait...

start "" ".\Schema_Studio\Schema_Studio.exe"

:WaitForProcess
timeout /t 1 >nul
tasklist | find /i "Schema_Studio.exe" >nul

if errorlevel 1 (
    echo Schema Studio is starting...
    goto WaitForProcess
)

echo Schema Studio started successfully.
