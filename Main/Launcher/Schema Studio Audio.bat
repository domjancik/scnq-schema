@echo off
echo Loading Schema Studio Audio, please wait...

start "" ".\Schema_Studio\Schema_Studio_Audio.exe"

:WaitForProcess
timeout /t 1 >nul
tasklist | find /i "Schema_Studio_Audio.exe" >nul

if errorlevel 1 (
    echo Schema Studio is starting...
    goto WaitForProcess
)

echo Schema Studio started successfully.
