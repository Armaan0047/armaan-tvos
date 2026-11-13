#!/usr/bin/env bash
# =====================================================================
# ARMAAN tvOS — UNIVERSAL ANDROID TV COMPATIBILITY INSTALLER (POSIX)
# Supported OS: macOS, Linux, ChromeOS, WSL
# =====================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================================================="
echo "             ARMAAN tvOS — UNIVERSAL ANDROID TV INSTALLER            "
echo "         Universal Compatibility & Safe Device-Aware Setup          "
echo "====================================================================="
echo ""

# Find ADB
if command -v adb >/dev/null 2>&1; then
    ADB_CMD="adb"
elif [ -n "$ANDROID_HOME" ] && [ -x "$ANDROID_HOME/platform-tools/adb" ]; then
    ADB_CMD="$ANDROID_HOME/platform-tools/adb"
elif [ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
    ADB_CMD="$HOME/Library/Android/sdk/platform-tools/adb"
elif [ -x "/usr/lib/android-sdk/platform-tools/adb" ]; then
    ADB_CMD="/usr/lib/android-sdk/platform-tools/adb"
else
    echo "[ERROR] adb command not found. Please install Android platform-tools."
    exit 1
fi

echo "[ADB] Using: $ADB_CMD"

# Connection
DEVICES=$($ADB_CMD devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICES" ]; then
    echo "No connected Android TV devices found."
    read -p "Enter your TV's IP address (or press Enter to retry): " TV_IP
    if [ -n "$TV_IP" ]; then
        echo "Connecting to $TV_IP:5555..."
        $ADB_CMD connect "$TV_IP:5555" || true
        sleep 2
    fi
    DEVICES=$($ADB_CMD devices | grep -w "device" | awk '{print $1}')
fi

if [ -z "$DEVICES" ]; then
    echo "[ERROR] Could not connect to an Android TV device."
    echo "Check that USB/Network debugging is enabled on your TV and accept the authorization prompt."
    exit 1
fi

TARGET_DEVICE=$(echo "$DEVICES" | head -n 1)
echo "[CONNECTED] Target Device: $TARGET_DEVICE"
echo ""

# Read-Only Inspection
echo "Running read-only hardware & system inspection..."
MFG=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.product.manufacturer | tr -d '\r')
BRAND=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.product.brand | tr -d '\r')
MODEL=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.product.model | tr -d '\r')
DEVICE=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.product.device | tr -d '\r')
BOARD=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.board.platform | tr -d '\r')
HARDWARE=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.hardware | tr -d '\r')
RELEASE=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.build.version.release | tr -d '\r')
SDK=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.build.version.sdk | tr -d '\r')
ABI=$($ADB_CMD -s "$TARGET_DEVICE" shell getprop ro.product.cpu.abi | tr -d '\r')

RAM_KB=$($ADB_CMD -s "$TARGET_DEVICE" shell "cat /proc/meminfo" | grep MemTotal | awk '{print $2}' | tr -d '\r')
RAM_MB=$((RAM_KB / 1024))

AVAIL_KB=$($ADB_CMD -s "$TARGET_DEVICE" shell "df -k /data" | grep -v "Filesystem" | awk '{print $4}' | head -n 1 | tr -d '\r')
AVAIL_MB=$((AVAIL_KB / 1024))

LEANBACK=$($ADB_CMD -s "$TARGET_DEVICE" shell "pm has-feature android.software.leanback" | tr -d '\r')

ACTIVE_HOME=$($ADB_CMD -s "$TARGET_DEVICE" shell "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME" | grep '/' | tr -d '\r')

# Classification
COMPAT_STATUS="COMPATIBLE"
CAN_INSTALL=1
WARNINGS=()

if [ "$SDK" -lt 24 ] 2>/dev/null; then
    COMPAT_STATUS="UNSUPPORTED"
    CAN_INSTALL=0
    WARNINGS+=("Android SDK $SDK is below minimum requirement (minSdkVersion 24).")
elif [ "$AVAIL_MB" -lt 30 ] 2>/dev/null; then
    COMPAT_STATUS="UNSUPPORTED"
    CAN_INSTALL=0
    WARNINGS+=("Available storage ($AVAIL_MB MB) is insufficient.")
else
    # Check for generic/assembled
    MFG_LOWER=$(echo "$MFG" | tr '[:upper:]' '[:lower:]')
    MODEL_LOWER=$(echo "$MODEL" | tr '[:upper:]' '[:lower:]')
    
    if [ "$MFG_LOWER" = "unknown" ] || [ "$MFG_LOWER" = "generic" ] || [ "$MFG_LOWER" = "android" ] || [ "$LEANBACK" != "true" ]; then
        COMPAT_STATUS="NEEDS MANUAL VERIFICATION"
        WARNINGS+=("Assembled, white-label, or unbranded Android TV hardware detected.")
        WARNINGS+=("Universal Rule Applied: No manufacturer-specific package modifications will be executed.")
    fi
fi

echo "---------------------------------------------------------------------"
echo "                       DEVICE PROFILE DETECTED                       "
echo "---------------------------------------------------------------------"
echo "  Manufacturer:    ${MFG:-Generic / Unknown}"
echo "  Brand:           ${BRAND:-Unknown}"
echo "  Model:           ${MODEL:-Unknown Assembled Model}"
echo "  Board/Platform:  $BOARD ($HARDWARE)"
echo "  Android OS:      $RELEASE (API Level $SDK)"
echo "  CPU ABI:         $ABI"
echo "  Total RAM:       $RAM_MB MB"
echo "  Free Storage:    $AVAIL_MB MB"
echo "  Leanback TV:     $LEANBACK"
echo "  Active Home:     ${ACTIVE_HOME:-None resolved}"
echo "---------------------------------------------------------------------"
echo "  COMPATIBILITY:   [$COMPAT_STATUS]"
for w in "${WARNINGS[@]}"; do
    echo "   ! $w"
done
echo "---------------------------------------------------------------------"
echo ""

if [ "$CAN_INSTALL" -eq 0 ]; then
    echo "[ABORT] Cannot proceed with installation due to operating system constraints."
    exit 1
fi

# Locate APK
APK_PATH=""
for cand in "$SCRIPT_DIR/../build/armaan-tvos-release.apk" "$SCRIPT_DIR/armaan-tvos-release.apk" "$SCRIPT_DIR/../armaan-tvos-release.apk"; do
    if [ -f "$cand" ]; then
        APK_PATH="$cand"
        break
    fi
done

if [ -z "$APK_PATH" ]; then
    echo "[ERROR] armaan-tvos-release.apk not found. Please build or place the release APK in the project directory."
    exit 1
fi

echo "Select an Installation Mode:"
echo "  [A] Basic APK Installation (Safe / Recommended for Testing)"
echo "  [B] Full Launcher Setup (Set as Default Home with State Backup)"
echo "  [C] Manufacturer-Specific Fixes & Diagnostics"
echo "  [Q] Quit"
echo ""
read -p "Choose Mode (A/B/C/Q) [Default: A]: " MODE_CHOICE
MODE_CHOICE=${MODE_CHOICE:-A}
MODE_UPPER=$(echo "$MODE_CHOICE" | tr '[:lower:]' '[:upper:]')

save_state() {
    cat <<EOF > "$SCRIPT_DIR/.armaan_tvos_state.txt"
# ARMAAN tvOS INSTALLER STATE BACKUP
DEVICE_MANUFACTURER=$MFG
DEVICE_MODEL=$MODEL
PREVIOUS_HOME=$ACTIVE_HOME
ACCESSIBILITY_ENABLED_BY_INSTALLER=$1
XIAOMI_PARTNER_DISABLED_BY_INSTALLER=$2
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
    $ADB_CMD -s "$TARGET_DEVICE" push "$SCRIPT_DIR/.armaan_tvos_state.txt" "/sdcard/.armaan_tvos_state.txt" >/dev/null 2>&1 || true
}

if [ "$MODE_UPPER" = "A" ]; then
    echo "--- Running Mode A: Basic APK Installation ---"
    $ADB_CMD -s "$TARGET_DEVICE" install -r -g "$APK_PATH"
    $ADB_CMD -s "$TARGET_DEVICE" shell "am start -n com.techgenius.tvoslauncher/.MainActivity"
    echo "[SUCCESS] Armaan tvOS installed and launched. Stock launcher was untouched."

elif [ "$MODE_UPPER" = "B" ]; then
    echo "--- Running Mode B: Full Launcher Setup ---"
    read -p "Set Armaan tvOS as your primary TV launcher? [y/N]: " CONFIRM
    case "$CONFIRM" in
        [yY]|[yY][eE][sS])
            $ADB_CMD -s "$TARGET_DEVICE" install -r -g "$APK_PATH"
            $ADB_CMD -s "$TARGET_DEVICE" shell "settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService"
            $ADB_CMD -s "$TARGET_DEVICE" shell "settings put secure accessibility_enabled 1"
            $ADB_CMD -s "$TARGET_DEVICE" shell "cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity"
            save_state "1" "0"
            $ADB_CMD -s "$TARGET_DEVICE" shell "am start -n com.techgenius.tvoslauncher/.MainActivity"
            echo "[SUCCESS] Armaan tvOS configured as default home."
            echo "Previous launcher backed up: $ACTIVE_HOME"
            echo "To restore at any time, run: ./scripts/restore.sh"
            ;;
        *)
            echo "Cancelled by user."
            ;;
    esac

elif [ "$MODE_UPPER" = "C" ]; then
    echo "--- Running Mode C: Manufacturer-Specific Fixes ---"
    IS_XIAOMI=0
    if echo "$MFG $BRAND $MODEL" | grep -iqE "xiaomi|redmi|mitv"; then
        IS_XIAOMI=1
    fi

    if [ "$IS_XIAOMI" -eq 1 ]; then
        PARTNER_EXISTS=$($ADB_CMD -s "$TARGET_DEVICE" shell "pm list packages com.xiaomi.android.tvsetup.partnercustomizer" | grep -c "package:com.xiaomi.android.tvsetup.partnercustomizer" || true)
        if [ "$PARTNER_EXISTS" -gt 0 ]; then
            echo "Detected Xiaomi TV with Partner Customizer."
            echo "Notice: On Xiaomi TVs with debloated PatchWall, pressing the remote's Mi button"
            echo "causes PartnerCustomizer to jump to HDMI 3. Disabling it prevents this loop."
            read -p "Disable PartnerCustomizer for User 0? [y/N]: " APPLY_FIX
            case "$APPLY_FIX" in
                [yY]|[yY][eE][sS])
                    $ADB_CMD -s "$TARGET_DEVICE" shell "pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer"
                    echo "[FIX APPLIED] Xiaomi Partner Customizer disabled."
                    ;;
                *)
                    echo "Skipped."
                    ;;
            esac
        else
            echo "Partner Customizer package not found on this device."
        fi
    else
        echo "Non-Xiaomi hardware detected. No manufacturer hacks needed."
        echo "Universal Rule: Assembled TVs use standard Android TV inputs."
    fi
else
    echo "No changes made."
fi
