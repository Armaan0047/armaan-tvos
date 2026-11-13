# =====================================================================
# ARMAAN tvOS — UNIVERSAL ANDROID TV RESTORE & ROLLBACK
# =====================================================================
param(
    [string]$DeviceIp
)

$ErrorActionPreference = "Continue"

function Safe-ReadHost($prompt) {
    if ([Console]::IsInputRedirected) { return "" }
    try {
        return (Read-Host $prompt)
    } catch {
        return ""
    }
}

function Write-Header {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "               ARMAAN tvOS — UNIVERSAL RESTORE & ROLLBACK            " -ForegroundColor White
    Write-Host "             Safe, State-Aware Stock Configuration Recovery          " -ForegroundColor Gray
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Find-Adb {
    if (Get-Command adb -ErrorAction SilentlyContinue) {
        return (Get-Command adb).Source
    }
    $candidates = @(
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:ANDROID_HOME\platform-tools\adb.exe",
        "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe",
        "$PSScriptRoot\platform-tools\adb.exe",
        "$PSScriptRoot\..\platform-tools\adb.exe",
        "$PSScriptRoot\adb.exe",
        "C:\platform-tools\adb.exe"
    )
    foreach ($cand in $candidates) {
        if ($cand -and (Test-Path $cand)) { return $cand }
    }
    return $null
}

$AdbCmd = Find-Adb
if (-not $AdbCmd) {
    Write-Host "[ERROR] Android Debug Bridge (adb) was not found on your system." -ForegroundColor Red
    Safe-ReadHost "Press Enter to exit..."
    exit 1
}

Write-Header
Write-Host "[ADB] Using: $AdbCmd" -ForegroundColor DarkGray

# 1. Connection Manager
$connectedDevices = @(& $AdbCmd devices | Where-Object { $_ -match '\tdevice$' })
if ($connectedDevices.Count -eq 0) {
    if (-not $DeviceIp) {
        Write-Host "No active Android TV devices detected via USB or network." -ForegroundColor Yellow
        $DeviceIp = Safe-ReadHost "Enter your Android TV's IP address (e.g. 192.168.1.100), or press Enter to retry"
    }
    if ($DeviceIp) {
        Write-Host "Connecting to $DeviceIp:5555..." -ForegroundColor Cyan
        & $AdbCmd connect "$DeviceIp`:5555" | Out-Null
        Start-Sleep -Seconds 2
    }
}

$connectedDevices = @(& $AdbCmd devices | Where-Object { $_ -match '\tdevice$' })
if ($connectedDevices.Count -eq 0) {
    Write-Host "[ERROR] Could not connect to an Android TV device." -ForegroundColor Red
    Safe-ReadHost "Press Enter to exit..."
    exit 1
}

$TargetDevice = ($connectedDevices[0] -split '\t')[0].Trim()
Write-Host "[CONNECTED] Target Device: $TargetDevice`n" -ForegroundColor Green

# 2. Read State File
$state = @{}
$localStatePath = "$PSScriptRoot\.armaan_tvos_state.txt"
if (-not (Test-Path $localStatePath)) {
    # Attempt to pull from device
    try {
        & $AdbCmd -s $TargetDevice pull "/sdcard/.armaan_tvos_state.txt" "$localStatePath" >$null 2>&1
    } catch { }
}

if (Test-Path $localStatePath) {
    foreach ($line in (Get-Content $localStatePath)) {
        if ($line -match '^([A-Z_]+)=(.*)$') {
            $state[$matches[1]] = $matches[2]
        }
    }
    Write-Host "[STATE] Loaded previous installer state from backup file." -ForegroundColor Gray
} else {
    Write-Host "[STATE] No previous state file found. Using live device discovery." -ForegroundColor Yellow
}

# 3. Discover Available Home Launchers
$queryLaunchersRaw = & $AdbCmd -s $TargetDevice shell "cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
$availableLaunchers = @()
foreach ($l in $queryLaunchersRaw) {
    $t = $l.Trim()
    if ($t -match '^([a-zA-Z0-9_\.]+/[a-zA-Z0-9_\.]+)$') {
        $comp = $matches[1]
        if ($comp -notmatch 'FallbackHome' -and $comp -notmatch 'com\.techgenius\.tvoslauncher' -and $availableLaunchers -notcontains $comp) {
            $availableLaunchers += $comp
        }
    }
}

$targetRestoreHome = $state["PREVIOUS_HOME"]
if ($targetRestoreHome -and ($targetRestoreHome -match 'com\.techgenius\.tvoslauncher')) {
    $targetRestoreHome = $null
}

if ($targetRestoreHome) {
    $targetPkg = ($targetRestoreHome -split '/')[0]
    $pkgCheck = ((& $AdbCmd -s $TargetDevice shell "pm list packages $targetPkg") + "") -match "package:$targetPkg"
    if (-not $pkgCheck) {
        Write-Host "[WARN] Recorded previous launcher ($targetRestoreHome) is no longer installed on the TV." -ForegroundColor Yellow
        $targetRestoreHome = $null
    }
}

Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "                       STOCK RESTORE SELECTION                       " -ForegroundColor White
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray

if ($targetRestoreHome) {
    Write-Host "Recorded Previous Home Launcher: " -NoNewline
    Write-Host $targetRestoreHome -ForegroundColor Green
    $restoreChoice = Safe-ReadHost "Restore this launcher as your default? [Y/n]"
    if ($restoreChoice -and $restoreChoice -notmatch '^(y|yes)$') {
        $targetRestoreHome = $null
    }
}

if (-not $targetRestoreHome) {
    if ($availableLaunchers.Count -eq 0) {
        Write-Host "[WARN] No alternative home launcher packages were found installed on your TV." -ForegroundColor Red
        Write-Host "Cannot reset default home activity without a valid replacement." -ForegroundColor Yellow
    } else {
        Write-Host "Detected alternative home launcher packages installed on this TV:" -ForegroundColor White
        for ($i = 0; $i -lt $availableLaunchers.Count; $i++) {
            Write-Host "  [$($i+1)] $($availableLaunchers[$i])" -ForegroundColor Cyan
        }
        Write-Host "  [0] Skip restoring home activity" -ForegroundColor Gray
        $pick = Safe-ReadHost "Select launcher number to set as default"
        $idx = 0
        if ([int]::TryParse($pick, [ref]$idx) -and $idx -ge 1 -and $idx -le $availableLaunchers.Count) {
            $targetRestoreHome = $availableLaunchers[$idx - 1]
        }
    }
}

if ($targetRestoreHome) {
    Write-Host "`n[1/3] Restoring default home activity to $targetRestoreHome..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice shell "cmd package set-home-activity $targetRestoreHome"
    Write-Host "   + Default home set successfully." -ForegroundColor Green
} else {
    Write-Host "`n[1/3] Skipped home activity change." -ForegroundColor Gray
}

# 4. Re-enable Modified Manufacturer Packages (Only if actually modified by installer)
$xiaomiPartnerPkg = "com.xiaomi.android.tvsetup.partnercustomizer"
$wasXiaomiPartnerDisabled = ($state["XIAOMI_PARTNER_DISABLED_BY_INSTALLER"] -eq "1")
$mfg = ($state["DEVICE_MANUFACTURER"] + "").ToLower()

if ($wasXiaomiPartnerDisabled -or ($mfg -match 'xiaomi|redmi')) {
    $xiaomiPartnerExists = ((& $AdbCmd -s $TargetDevice shell "pm list packages $xiaomiPartnerPkg") + "") -match "package:$xiaomiPartnerPkg"
    if ($xiaomiPartnerExists) {
        Write-Host "`n[2/3] Re-enabling Xiaomi Partner Customizer..." -ForegroundColor Cyan
        & $AdbCmd -s $TargetDevice shell "pm enable $xiaomiPartnerPkg"
        Write-Host "   + Xiaomi Partner Customizer re-enabled." -ForegroundColor Green
    }
} else {
    Write-Host "`n[2/3] No manufacturer packages were modified by the installer. Skipping." -ForegroundColor Gray
}

# 5. Accessibility Service Cleanup
Write-Host "`n[3/3] Checking Accessibility Service..." -ForegroundColor Cyan
if ($state["ACCESSIBILITY_ENABLED_BY_INSTALLER"] -eq "1") {
    $resetAccess = Safe-ReadHost "Installer enabled the Armaan tvOS Accessibility service. Disable it now? [Y/n]"
    if (-not $resetAccess -or $resetAccess -match '^(y|yes)$') {
        & $AdbCmd -s $TargetDevice shell "settings put secure enabled_accessibility_services com.android.talkback/com.google.android.marvin.talkback.TalkBackService" >$null 2>&1
        Write-Host "   + Accessibility service reset." -ForegroundColor Green
    }
} else {
    Write-Host "   + Accessibility service was not modified by installer." -ForegroundColor Gray
}

# 6. Optional Uninstallation
Write-Host ""
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
$uninstall = Safe-ReadHost "Would you like to uninstall Armaan tvOS from your TV? [y/N]"
if ($uninstall -match '^(y|yes)$') {
    Write-Host "Uninstalling Armaan tvOS..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice uninstall com.techgenius.tvoslauncher
    Write-Host "[UNINSTALLED] Armaan tvOS removed. All user data on your TV is preserved." -ForegroundColor Green
} else {
    Write-Host "Armaan tvOS remains installed as a secondary application." -ForegroundColor Gray
}

# 7. Clean up local state file
if (Test-Path $localStatePath) {
    Remove-Item -Force $localStatePath -ErrorAction SilentlyContinue
}
try {
    & $AdbCmd -s $TargetDevice shell "rm -f /sdcard/.armaan_tvos_state.txt" >$null 2>&1
} catch { }

# Return to Home
Write-Host "`nReturning to home screen..." -ForegroundColor Cyan
& $AdbCmd -s $TargetDevice shell "input keyevent 3"

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host "                 RESTORE PROCEDURE COMPLETED SAFELY                 " -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host ""
Safe-ReadHost "Press Enter to exit..."
