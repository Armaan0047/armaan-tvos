@echo off
setlocal enabledelayedexpansion

title Armaan tvOS — Universal Restore & Rollback

echo =====================================================================
echo               ARMAAN tvOS — UNIVERSAL RESTORE & ROLLBACK
echo             Safe, State-Aware Stock Configuration Recovery
echo =====================================================================
echo.

:: Locate ADB in PATH or standard installation locations
set ADB_FOUND=0
where adb >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set ADB_FOUND=1
) else if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"
    set ADB_FOUND=1
) else if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    set "PATH=%ANDROID_HOME%\platform-tools;%PATH%"
    set ADB_FOUND=1
) else if exist "%ProgramFiles%\Android\platform-tools\adb.exe" (
    set "PATH=%ProgramFiles%\Android\platform-tools;%PATH%"
    set ADB_FOUND=1
) else if exist "%~dp0platform-tools\adb.exe" (
    set "PATH=%~dp0platform-tools;%PATH%"
    set ADB_FOUND=1
) else if exist "C:\platform-tools\adb.exe" (
    set "PATH=C:\platform-tools;%PATH%"
    set ADB_FOUND=1
)

if %ADB_FOUND% equ 0 (
    echo [ERROR] Android Debug Bridge (adb) was not found on your system.
    echo Please install Android platform-tools or place adb.exe in this folder.
    echo.
    pause
    exit /b 1
)

:: Launch the PowerShell universal restore script
where powershell.exe >nul 2>&1
if %ERRORLEVEL% equ 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0universal_restore.ps1" %*
    exit /b %ERRORLEVEL%
)

echo [ERROR] Windows PowerShell is required to execute the state-aware restore script.
pause
exit /b 1
