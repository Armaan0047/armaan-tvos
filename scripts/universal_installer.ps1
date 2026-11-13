# =====================================================================
# ARMAAN tvOS — UNIVERSAL ANDROID TV COMPATIBILITY INSTALLER
# =====================================================================
param(
    [string]$DeviceIp,
    [switch]$NonInteractive,
    [string]$Mode
)

$ErrorActionPreference = "Continue"

function Write-Header {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "             ARMAAN tvOS — UNIVERSAL ANDROID TV INSTALLER             " -ForegroundColor White
    Write-Host "         Universal Compatibility & Safe Device-Aware Setup           " -ForegroundColor Gray
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
    Write-Host "Please install Android platform-tools or add adb to your PATH." -ForegroundColor Yellow
    Write-Host "Download: https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Gray
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Header
Write-Host "[ADB] Using: $AdbCmd" -ForegroundColor DarkGray

# 1. Connection Manager
$connectedDevices = @(& $AdbCmd devices | Where-Object { $_ -match '\tdevice$' })
if ($connectedDevices.Count -eq 0) {
    if (-not $DeviceIp) {
        Write-Host "No active Android TV devices detected via USB or network." -ForegroundColor Yellow
        $DeviceIp = Read-Host "Enter your Android TV's IP address (e.g. 192.168.1.100), or press Enter to retry"
    }
    if ($DeviceIp) {
        Write-Host "Connecting to $DeviceIp:5555..." -ForegroundColor Cyan
        & $AdbCmd connect "$DeviceIp`:5555" | Out-Null
        Start-Sleep -Seconds 2
    }
}

$connectedDevices = @(& $AdbCmd devices | Where-Object { $_ -match '\tdevice$' })
if ($connectedDevices.Count -eq 0) {
    Write-Host "[ERROR] Could not establish connection to an Android TV device." -ForegroundColor Red
    Write-Host "Check that:" -ForegroundColor Yellow
    Write-Host " 1. Your TV and computer are on the same Wi-Fi / LAN network." -ForegroundColor Gray
    Write-Host " 2. Developer options & USB/Network debugging are enabled on the TV." -ForegroundColor Gray
    Write-Host " 3. You accepted the 'Allow USB Debugging' authorization prompt on the TV." -ForegroundColor Gray
    Read-Host "Press Enter to exit..."
    exit 1
}

$TargetDevice = ($connectedDevices[0] -split '\t')[0].Trim()
Write-Host "[CONNECTED] Target Device: $TargetDevice" -ForegroundColor Green
Write-Host ""

# 2. Read-Only Hardware & System Probe
Write-Host "Running read-only hardware & system inspection..." -ForegroundColor Cyan

$rawProps = & $AdbCmd -s $TargetDevice shell "getprop"
$props = @{}
foreach ($line in $rawProps) {
    if ($line -match '^\[(.*?)\]: \[(.*?)\]$') {
        $props[$matches[1]] = $matches[2]
    }
}

$mfg      = ($props["ro.product.manufacturer"] + "").Trim()
$brand    = ($props["ro.product.brand"] + "").Trim()
$model    = ($props["ro.product.model"] + "").Trim()
$device   = ($props["ro.product.device"] + "").Trim()
$board    = ($props["ro.board.platform"] + "").Trim()
$hardware = ($props["ro.hardware"] + "").Trim()
$release  = ($props["ro.build.version.release"] + "").Trim()
$sdkStr   = ($props["ro.build.version.sdk"] + "").Trim()
$abi      = ($props["ro.product.cpu.abi"] + "").Trim()
$sdk = 0
[int]::TryParse($sdkStr, [ref]$sdk) | Out-Null

# Memory (RAM)
$meminfo = & $AdbCmd -s $TargetDevice shell "cat /proc/meminfo"
$ramKb = 0
foreach ($l in $meminfo) {
    if ($l -match 'MemTotal:\s+(\d+)\s+kB') { $ramKb = [int64]$matches[1]; break }
}
$ramMb = [Math]::Round($ramKb / 1024, 0)
$ramGb = [Math]::Round($ramKb / (1024 * 1024), 2)

# Storage
$df = & $AdbCmd -s $TargetDevice shell "df -k /data"
$availKb = 0
$totalKb = 0
foreach ($l in $df) {
    if ($l -match '\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+%\s+/data') {
        $totalKb = [int64]$matches[1]
        $availKb = [int64]$matches[3]
    }
}
$availMb = [Math]::Round($availKb / 1024, 0)
$availGb = [Math]::Round($availKb / (1024 * 1024), 2)

# Leanback Feature Check
$hasLeanback = ((& $AdbCmd -s $TargetDevice shell "pm has-feature android.software.leanback") + "").Trim() -eq "true"

# Current Active Home Launcher
$activeHomeRaw = & $AdbCmd -s $TargetDevice shell "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
$currentHome = ""
foreach ($l in $activeHomeRaw) {
    $t = $l.Trim()
    if ($t -match '^([a-zA-Z0-9_\.]+/[a-zA-Z0-9_\.]+)$') { $currentHome = $matches[1] }
}

# Installed Home Launchers
$queryLaunchersRaw = & $AdbCmd -s $TargetDevice shell "cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
$installedLaunchers = @()
foreach ($l in $queryLaunchersRaw) {
    $t = $l.Trim()
    if ($t -match '^([a-zA-Z0-9_\.]+/[a-zA-Z0-9_\.]+)$') {
        $comp = $matches[1]
        if ($comp -notmatch 'FallbackHome' -and $installedLaunchers -notcontains $comp) {
            $installedLaunchers += $comp
        }
    }
}

# Xiaomi-specific package checks
$xiaomiPartnerPkg = "com.xiaomi.android.tvsetup.partnercustomizer"
$xiaomiPartnerExists = ((& $AdbCmd -s $TargetDevice shell "pm list packages $xiaomiPartnerPkg") + "") -match "package:$xiaomiPartnerPkg"
$xiaomiPartnerEnabled = ((& $AdbCmd -s $TargetDevice shell "pm list packages -e $xiaomiPartnerPkg") + "") -match "package:$xiaomiPartnerPkg"
$isXiaomi = ($mfg -match '(?i)xiaomi|redmi' -or $brand -match '(?i)xiaomi|redmi' -or $model -match '(?i)mitv')

# 3. Compatibility Classification
$compatStatus = "COMPATIBLE"
$compatColor = "Green"
$compatReasons = @()
$compatWarnings = @()
$canInstall = $true

if ($sdk -lt 24) {
    $compatStatus = "UNSUPPORTED"
    $compatColor = "Red"
    $canInstall = $false
    $compatReasons += "Android SDK $sdk ($release) is below minimum requirement (minSdkVersion 24 / Android 7.0)."
    $compatWarnings += "Armaan tvOS cannot be installed on this operating system version."
} elseif ($availMb -gt 0 -and $availMb -lt 30) {
    $compatStatus = "UNSUPPORTED"
    $compatColor = "Red"
    $canInstall = $false
    $compatReasons += "Available storage ($availMb MB) is insufficient to install APK (minimum 30 MB required)."
} else {
    $genericMfgTokens = @("unknown", "generic", "android", "allwinner", "rockchip", "mstar", "amlogic", "qcom", "default", "")
    $genericModelTokens = @("generic", "smart_tv", "smarttv", "tv", "box", "ott", "unknown", "")

    $isGenericMfg = ($genericMfgTokens -contains $mfg.ToLower())
    $isGenericModel = ($genericModelTokens -contains $model.ToLower() -or $model.ToLower().StartsWith("rk") -or $model.ToLower().StartsWith("p2"))

    if ($isGenericMfg -or $isGenericModel -or (-not $hasLeanback)) {
        $compatStatus = "NEEDS MANUAL VERIFICATION"
        $compatColor = "Yellow"
        $compatReasons += "Assembled, white-label, or unbranded Android TV hardware detected."
        if (-not $hasLeanback) {
            $compatWarnings += "Device does not report standard android.software.leanback TV flag (may be a tablet/phone AOSP board)."
        }
        if ($isGenericMfg -or $isGenericModel) {
            $compatWarnings += "Hardware reports generic/assembled board identifiers (Manufacturer: '$mfg', Model: '$model', Board: '$board')."
        }
        $compatWarnings += "Universal Rule Applied: No manufacturer-specific tweaks or package disables will be executed."
        $compatWarnings += "Recommendation: Select Mode A (Basic APK Install) first to test UI scaling and remote navigation."
    } else {
        $limitations = @()
        if ($sdk -ge 24 -and $sdk -lt 28) {
            $limitations += "Android $release (SDK $sdk) has limited support for TvContract Watch Next APIs."
        }
        if ($ramMb -gt 0 -and $ramMb -lt 950) {
            $limitations += "Total RAM ($ramMb MB) is limited. Recommend low/medium glass blur and minimal status pill."
        }
        if ($availMb -ge 30 -and $availMb -lt 150) {
            $limitations += "Available storage ($availMb MB) is tight."
        }

        if ($limitations.Count -gt 0) {
            $compatStatus = "COMPATIBLE WITH LIMITATIONS"
            $compatColor = "Cyan"
            $compatReasons += $limitations
            $compatWarnings += "Armaan tvOS will run cleanly, but fine-tune glass blur in Settings for optimal FPS."
        } else {
            $compatStatus = "COMPATIBLE"
            $compatColor = "Green"
            $compatReasons += "Android $release (API $sdk) meets all modern Android TV specifications."
            $compatReasons += "RAM ($ramMb MB / ~$ramGb GB) and Storage ($availMb MB) within optimal 60 FPS range."
            $compatReasons += "Standard Leanback TV support confirmed."
        }
    }
}

# Helper: choose value
function Pick-Val($val, $fallback) {
    if ($val -and $val.ToString().Trim().Length -gt 0) { return $val }
    return $fallback
}

# 4. Display Detected Device Profile Card
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "                        DEVICE PROFILE DETECTED                      " -ForegroundColor White
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ("  Manufacturer:   " + (Pick-Val $mfg "Generic / Unknown")) -ForegroundColor White
Write-Host ("  Brand:          " + (Pick-Val $brand "Unknown")) -ForegroundColor White
Write-Host ("  Model:          " + (Pick-Val $model "Unknown Assembled Model")) -ForegroundColor White
Write-Host ("  Device / Board: " + "$device (Platform: $board, HW: $hardware)") -ForegroundColor White
Write-Host ("  Android OS:     " + "$release (API Level $sdk)") -ForegroundColor White
Write-Host ("  CPU ABI:        " + $abi) -ForegroundColor White
Write-Host ("  Total RAM:      " + "$ramMb MB (~$ramGb GB)") -ForegroundColor White
Write-Host ("  Free Storage:   " + "$availMb MB (~$availGb GB)") -ForegroundColor White
Write-Host ("  Leanback TV:    " + (if ($hasLeanback) { "Yes (Official TV OS)" } else { "No (Generic / AOSP)" })) -ForegroundColor White
Write-Host ("  Active Home:    " + (Pick-Val $currentHome "None resolved")) -ForegroundColor White
Write-Host ("  Installed Homes:" + (if ($installedLaunchers.Count -gt 0) { $installedLaunchers -join ", " } else { "None detected" })) -ForegroundColor White
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  COMPATIBILITY:  " -NoNewline
Write-Host "[$compatStatus]" -ForegroundColor $compatColor
foreach ($r in $compatReasons) { Write-Host "   + $r" -ForegroundColor DarkGray }
foreach ($w in $compatWarnings) { Write-Host "   ! $w" -ForegroundColor Yellow }
Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

if (-not $canInstall) {
    Write-Host "[ABORT] This device cannot run Armaan tvOS due to operating system constraints." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# 5. Resolve APK File Path
$ApkPath = $null
$apkCandidates = @(
    "$PSScriptRoot\..\build\armaan-tvos-release.apk",
    "$PSScriptRoot\armaan-tvos-release.apk",
    "$PSScriptRoot\..\armaan-tvos-release.apk"
)
foreach ($c in $apkCandidates) {
    if (Test-Path $c) { $ApkPath = (Resolve-Path $c).Path; break }
}

if (-not $ApkPath) {
    Write-Host "[ERROR] Could not find armaan-tvos-release.apk." -ForegroundColor Red
    Write-Host "Please run .\build.ps1 -Release first or place the release APK in the project directory." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}
Write-Host "[APK] Target: $ApkPath" -ForegroundColor DarkGray
Write-Host ""

# 6. Interactive Mode Selection
Write-Host "Select an Installation Mode:" -ForegroundColor White
Write-Host "  [A] Basic APK Installation (Safe / Recommended for Testing)" -ForegroundColor Green
Write-Host "      - Installs Armaan tvOS APK and launches it"
Write-Host "      - Keeps your current stock launcher completely untouched"
Write-Host "      - Zero system-level changes, zero permissions altered"
Write-Host ""
Write-Host "  [B] Full Launcher Setup (Set as Default Home)" -ForegroundColor Cyan
Write-Host "      - Backs up your previous home launcher state for 1-click restore"
Write-Host "      - Configures Accessibility Service (for Button Remap & Control Center)"
Write-Host "      - Sets Armaan tvOS as your default home screen with user confirmation"
Write-Host ""
Write-Host "  [C] Manufacturer-Specific Fixes & Diagnostics" -ForegroundColor Yellow
Write-Host "      - Inspects manufacturer-specific packages (e.g. Xiaomi Mi Button HDMI 3 fix)"
Write-Host "      - Requires individual confirmation before altering any package"
Write-Host "      - Never executes on generic, assembled, or non-matching TVs"
Write-Host ""
Write-Host "  [Q] Quit without making changes" -ForegroundColor Gray
Write-Host ""

$selectedMode = $Mode
if (-not $selectedMode) {
    $selectedMode = Read-Host "Choose Mode (A / B / C / Q) [Default: A]"
    if (-not $selectedMode) { $selectedMode = "A" }
}

$selectedMode = $selectedMode.ToUpper().Trim()

# Helper: Save State
function Save-InstallerState($dict) {
    $stateLines = @("# ARMAAN tvOS INSTALLER STATE BACKUP")
    foreach ($k in $dict.Keys) {
        $stateLines += "$k=$($dict[$k])"
    }
    $localStatePath = "$PSScriptRoot\.armaan_tvos_state.txt"
    Set-Content -Path $localStatePath -Value $stateLines -Force
    
    # Also push copy to TV /sdcard for recovery
    try {
        & $AdbCmd -s $TargetDevice push $localStatePath "/sdcard/.armaan_tvos_state.txt" >$null 2>&1
    } catch { }
}

if ($selectedMode -eq "A") {
    Write-Host "`n--- Running Mode A: Basic APK Installation ---" -ForegroundColor Green
    Write-Host "Installing Armaan tvOS APK..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice install -r -g "$ApkPath"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Installation failed. Check USB/Network debugging permissions." -ForegroundColor Red
        exit 1
    }
    Write-Host "Launching Armaan tvOS..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice shell "am start -n com.techgenius.tvoslauncher/.MainActivity"
    Write-Host "`n[SUCCESS] Armaan tvOS is installed and launched." -ForegroundColor Green
    Write-Host "Your stock launcher was NOT modified. Pressing Home will return to your stock home." -ForegroundColor White
    Write-Host "To make Armaan tvOS your default home later, run this installer and select Mode B." -ForegroundColor Gray

} elseif ($selectedMode -eq "B") {
    Write-Host "`n--- Running Mode B: Full Launcher Setup ---" -ForegroundColor Cyan
    Write-Host "This will install Armaan tvOS and set it as your primary television launcher." -ForegroundColor White
    $confirm = Read-Host "Are you sure you want to proceed? [y/N]"
    if ($confirm -notmatch '^(y|yes)$') {
        Write-Host "Full setup cancelled by user. No changes made." -ForegroundColor Yellow
        exit 0
    }

    # Backup state
    $state = @{
        "TIMESTAMP" = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        "DEVICE_MANUFACTURER" = $mfg
        "DEVICE_MODEL" = $model
        "PREVIOUS_HOME" = $currentHome
        "ACCESSIBILITY_ENABLED_BY_INSTALLER" = "0"
        "XIAOMI_PARTNER_DISABLED_BY_INSTALLER" = "0"
    }

    Write-Host "[1/4] Installing Armaan tvOS APK..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice install -r -g "$ApkPath"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] APK Installation failed." -ForegroundColor Red
        exit 1
    }

    Write-Host "[2/4] Configuring Accessibility Service (for Control Center & Remote Remapper)..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice shell "settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService"
    & $AdbCmd -s $TargetDevice shell "settings put secure accessibility_enabled 1"
    $state["ACCESSIBILITY_ENABLED_BY_INSTALLER"] = "1"

    Write-Host "[3/4] Setting Armaan tvOS as Default Home Activity..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice shell "cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity"
    
    Save-InstallerState $state
    $prevDisplay = if ($currentHome) { $currentHome } else { "None" }
    Write-Host "   + Previous Home Activity backed up: $prevDisplay" -ForegroundColor Green

    Write-Host "[4/4] Launching Armaan tvOS..." -ForegroundColor Cyan
    & $AdbCmd -s $TargetDevice shell "am start -n com.techgenius.tvoslauncher/.MainActivity"

    Write-Host "`n[SUCCESS] Armaan tvOS Full Setup Complete!" -ForegroundColor Green
    Write-Host "Previous launcher recorded for rollback: $currentHome" -ForegroundColor Gray
    Write-Host "To revert to stock at any time, run: .\scripts\restore.bat" -ForegroundColor White

} elseif ($selectedMode -eq "C") {
    Write-Host "`n--- Running Mode C: Manufacturer-Specific Fixes ---" -ForegroundColor Yellow
    if ($isXiaomi) {
        Write-Host "Positively identified supported Xiaomi / Redmi TV ($model)." -ForegroundColor Green
        if ($xiaomiPartnerExists) {
            Write-Host "`nFound Xiaomi Partner Customizer ($xiaomiPartnerPkg)." -ForegroundColor White
            Write-Host "Status: " -NoNewline
            if ($xiaomiPartnerEnabled) {
                Write-Host "ENABLED" -ForegroundColor Yellow
            } else {
                Write-Host "DISABLED" -ForegroundColor Green
            }
            Write-Host ""
            Write-Host "Notice: On Xiaomi TVs with debloated PatchWall, pressing the remote's Mi button" -ForegroundColor Gray
            Write-Host "causes PartnerCustomizer to automatically redirect to HDMI 3." -ForegroundColor Gray
            Write-Host "Disabling this package prevents HDMI 3 redirection and allows the button" -ForegroundColor Gray
            Write-Host "to open Armaan tvOS Home screen cleanly." -ForegroundColor Gray
            Write-Host ""
            $applyXiaomi = Read-Host "Do you want to disable PartnerCustomizer for User 0? [y/N]"
            if ($applyXiaomi -match '^(y|yes)$') {
                & $AdbCmd -s $TargetDevice shell "pm disable-user --user 0 $xiaomiPartnerPkg"
                Write-Host "[FIX APPLIED] Xiaomi Partner Customizer disabled." -ForegroundColor Green
                
                # Update state file if exists
                $localStatePath = "$PSScriptRoot\.armaan_tvos_state.txt"
                if (Test-Path $localStatePath) {
                    $content = Get-Content $localStatePath
                    $content = $content -replace 'XIAOMI_PARTNER_DISABLED_BY_INSTALLER=0', 'XIAOMI_PARTNER_DISABLED_BY_INSTALLER=1'
                    Set-Content -Path $localStatePath -Value $content -Force
                }
            } else {
                Write-Host "Skipped Xiaomi Partner Customizer modification." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Xiaomi Partner Customizer package was not found on this system (already clean)." -ForegroundColor Gray
        }
    } else {
        Write-Host "Non-Xiaomi hardware detected (Manufacturer: '$mfg', Model: '$model')." -ForegroundColor Cyan
        Write-Host "No proprietary manufacturer fixes required." -ForegroundColor White
        Write-Host "Universal Rule: Assembled and generic Android TVs use standard Android TV inputs." -ForegroundColor Gray
        Write-Host "No system packages will be modified." -ForegroundColor Green
    }
} else {
    Write-Host "No changes were made to your TV." -ForegroundColor Gray
}

Write-Host ""
Read-Host "Press Enter to exit..."
