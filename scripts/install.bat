@echo off
setlocal

title Armaan tvOS - Universal Android TV Installer

echo =====================================================================
echo             ARMAAN tvOS - UNIVERSAL ANDROID TV INSTALLER
echo         Universal Compatibility and Safe Device-Aware Setup
echo =====================================================================
echo.

:: Locate ADB in PATH or standard installation locations
set "ADB_BIN="
where adb >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "ADB_BIN=adb"
    goto :FoundAdb
)

if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_BIN=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    set "ADB_BIN=%ANDROID_HOME%\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%ANDROID_SDK_ROOT%\platform-tools\adb.exe" (
    set "ADB_BIN=%ANDROID_SDK_ROOT%\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%ProgramFiles%\Android\platform-tools\adb.exe" (
    set "ADB_BIN=%ProgramFiles%\Android\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%ProgramFiles(x86)%\Android\platform-tools\adb.exe" (
    set "ADB_BIN=%ProgramFiles(x86)%\Android\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%~dp0platform-tools\adb.exe" (
    set "ADB_BIN=%~dp0platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "%~dp0..\platform-tools\adb.exe" (
    set "ADB_BIN=%~dp0..\platform-tools\adb.exe"
    goto :FoundAdb
)
if exist "C:\platform-tools\adb.exe" (
    set "ADB_BIN=C:\platform-tools\adb.exe"
    goto :FoundAdb
)

:NoAdb
echo [ERROR] Android Debug Bridge (adb) was not found on your system.
echo Please install Android platform-tools or place adb.exe in:
echo   %~dp0platform-tools\adb.exe
echo Download: https://developer.android.com/tools/releases/platform-tools
echo.
pause
exit /b 1

:FoundAdb
for %%I in ("%ADB_BIN%") do set "ADB_DIR=%%~dpI"
if defined ADB_DIR (
    if exist "%ADB_DIR%adb.exe" (
        set "PATH=%ADB_DIR%;%PATH%"
    )
)

where powershell.exe >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Windows PowerShell is required to execute the installer.
    pause
    exit /b 1
)

if not exist "%~dp0universal_installer.ps1" (
    echo [ERROR] Required script "%~dp0universal_installer.ps1" was not found.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0universal_installer.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

if %EXIT_CODE% neq 0 (
    echo.
    echo [NOTICE] Installer finished with exit code %EXIT_CODE%.
)

exit /b %EXIT_CODE%