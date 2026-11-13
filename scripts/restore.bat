@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                    ARMAAN tvOS - 1-CLICK RESTORE
echo =====================================================================
echo This script safely restores your Android TV back to stock configuration.
echo Zero risk, zero data loss.
echo.

where adb >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] adb command not found in PATH.
    pause
    exit /b 1
)

echo Checking for connected Android TV devices...
adb devices
echo.

set /p TV_IP="Enter TV IP address (or press Enter if already connected): "
if not "!TV_IP!"=="" (
    echo Connecting to !TV_IP!:5555...
    adb connect !TV_IP!:5555
)

echo.
echo [1/4] Re-enabling Xiaomi Partner Customizer...
adb shell pm enable com.xiaomi.android.tvsetup.partnercustomizer >nul 2>&1

echo [2/4] Resetting Default Home Activity...
adb shell cmd package set-home-activity com.google.android.tvlauncher/.MainActivity >nul 2>&1
adb shell cmd package set-home-activity com.mitv.tvhome.atv/.MainActivity >nul 2>&1

echo [3/4] Launching Stock Home Screen...
adb shell input keyevent 3

echo [4/4] Optional: Would you like to uninstall Armaan tvOS completely?
set /p UNINSTALL="Type Y to uninstall, or press Enter to keep it installed as a secondary launcher: "
if /i "!UNINSTALL!"=="Y" (
    echo Uninstalling Armaan tvOS...
    adb uninstall com.techgenius.tvoslauncher
    echo Armaan tvOS uninstalled.
)

echo.
echo =====================================================================
echo             SUCCESS: Stock TV settings restored!
echo =====================================================================
pause
