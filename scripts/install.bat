@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                    ARMAAN tvOS - 1-CLICK INSTALLER
echo =====================================================================
echo.

where adb >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] adb command not found in PATH.
    echo Please install Android platform-tools or run from an Android SDK directory.
    pause
    exit /b 1
)

echo Checking for connected Android TV devices...
adb devices
echo.

set /p TV_IP="Enter TV IP address (e.g. 192.168.1.100), or press Enter if already connected via USB/Wi-Fi: "
if not "!TV_IP!"=="" (
    echo Connecting to !TV_IP!:5555...
    adb connect !TV_IP!:5555
)

echo.
echo Searching for Armaan tvOS APK...
set APK_PATH=
if exist "%~dp0..\build\armaan-tvos-release.apk" (
    set APK_PATH=%~dp0..\build\armaan-tvos-release.apk
) else if exist "%~dp0..\armaan-tvos-release.apk" (
    set APK_PATH=%~dp0..\armaan-tvos-release.apk
) else if exist "%~dp0armaan-tvos-release.apk" (
    set APK_PATH=%~dp0armaan-tvos-release.apk
) else (
    echo [ERROR] armaan-tvos-release.apk not found.
    echo Please run build.ps1 -Release first or place the APK alongside this script.
    pause
    exit /b 1
)

echo [1/5] Installing Armaan tvOS (!APK_PATH!)...
adb install -r -g "!APK_PATH!"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Installation failed. Check device connection and USB/Network debugging.
    pause
    exit /b 1
)

echo [2/5] Enabling Accessibility Service for Button Mapper and Control Center...
adb shell settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService
adb shell settings put secure accessibility_enabled 1

echo [3/5] Applying Xiaomi TV Fixes (Prevents Mi Button from switching to HDMI 3)...
adb shell pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer >nul 2>&1

echo [4/5] Setting Armaan tvOS as Default Home Launcher...
adb shell cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity >nul 2>&1

echo [5/5] Launching Armaan tvOS...
adb shell am start -n com.techgenius.tvoslauncher/.MainActivity

echo.
echo =====================================================================
echo             SUCCESS: Armaan tvOS is installed and active!
echo =====================================================================
echo Remote Shortcuts:
echo  - Single Tap Home: Armaan tvOS Home
echo  - Hold Home (500ms): Recent Apps Switcher + Live RAM/Storage Meter
echo  - Mi / PatchWall Button: Armaan tvOS Home (HDMI 3 loop eliminated)
echo.
pause
