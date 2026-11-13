#!/usr/bin/env bash
# =====================================================================
# ARMAAN tvOS — UNIVERSAL ANDROID TV RESTORE & ROLLBACK (POSIX)
# Supported OS: macOS, Linux, ChromeOS, WSL
# =====================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================================================="
echo "              ARMAAN tvOS — UNIVERSAL RESTORE & ROLLBACK             "
echo "            Safe, State-Aware Stock Configuration Recovery           "
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
    echo "[ERROR] adb command not found."
    exit 1
fi

DEVICES=$($ADB_CMD devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICES" ]; then
    read -p "Enter your TV's IP address: " TV_IP
    if [ -n "$TV_IP" ]; then
        $ADB_CMD connect "$TV_IP:5555" || true
        sleep 2
    fi
    DEVICES=$($ADB_CMD devices | grep -w "device" | awk '{print $1}')
fi

if [ -z "$DEVICES" ]; then
    echo "[ERROR] Could not connect to an Android TV device."
    exit 1
fi

TARGET_DEVICE=$(echo "$DEVICES" | head -n 1)
echo "[CONNECTED] Target Device: $TARGET_DEVICE"

# Load state
STATE_FILE="$SCRIPT_DIR/.armaan_tvos_state.txt"
if [ ! -f "$STATE_FILE" ]; then
    $ADB_CMD -s "$TARGET_DEVICE" pull "/sdcard/.armaan_tvos_state.txt" "$STATE_FILE" >/dev/null 2>&1 || true
fi

PREVIOUS_HOME=""
XIAOMI_DISABLED=0
if [ -f "$STATE_FILE" ]; then
    PREVIOUS_HOME=$(grep '^PREVIOUS_HOME=' "$STATE_FILE" | cut -d'=' -f2 | tr -d '\r')
    XIAOMI_DISABLED=$(grep '^XIAOMI_PARTNER_DISABLED_BY_INSTALLER=1' "$STATE_FILE" | wc -l)
fi

# Discover available launchers
AVAILABLE_HOMES=$($ADB_CMD -s "$TARGET_DEVICE" shell "cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME" | grep '/' | grep -v 'FallbackHome' | grep -v 'com.techgenius.tvoslauncher' | tr -d '\r' || true)

TARGET_RESTORE=""
if [ -n "$PREVIOUS_HOME" ] && ! echo "$PREVIOUS_HOME" | grep -q 'com.techgenius.tvoslauncher'; then
    TARGET_PKG=$(echo "$PREVIOUS_HOME" | cut -d'/' -f1)
    if $ADB_CMD -s "$TARGET_DEVICE" shell "pm list packages $TARGET_PKG" | grep -q "package:$TARGET_PKG"; then
        echo "Found recorded previous launcher: $PREVIOUS_HOME"
        read -p "Restore this launcher as default? [Y/n]: " CONFIRM_RESTORE
        CONFIRM_RESTORE=${CONFIRM_RESTORE:-Y}
        if echo "$CONFIRM_RESTORE" | grep -iqE "^(y|yes)$"; then
            TARGET_RESTORE="$PREVIOUS_HOME"
        fi
    fi
fi

if [ -z "$TARGET_RESTORE" ] && [ -n "$AVAILABLE_HOMES" ]; then
    echo "Detected installed alternative home launchers:"
    i=1
    while IFS= read -r line; do
        [ -n "$line" ] && echo "  [$i] $line"
        i=$((i+1))
    done <<< "$AVAILABLE_HOMES"
    echo "  [0] Skip restoring home activity"
    read -p "Select launcher number: " PICK_NUM
    if [ "$PICK_NUM" -gt 0 ] 2>/dev/null; then
        TARGET_RESTORE=$(echo "$AVAILABLE_HOMES" | sed -n "${PICK_NUM}p")
    fi
fi

if [ -n "$TARGET_RESTORE" ]; then
    echo "[1/3] Restoring home activity to $TARGET_RESTORE..."
    $ADB_CMD -s "$TARGET_DEVICE" shell "cmd package set-home-activity $TARGET_RESTORE"
    echo "Default home restored."
else
    echo "[1/3] Skipped home activity change."
fi

# Re-enable Xiaomi package if disabled
if [ "$XIAOMI_DISABLED" -eq 1 ]; then
    echo "[2/3] Re-enabling Xiaomi Partner Customizer..."
    $ADB_CMD -s "$TARGET_DEVICE" shell "pm enable com.xiaomi.android.tvsetup.partnercustomizer" || true
    echo "Re-enabled."
else
    echo "[2/3] No manufacturer packages were modified. Skipping."
fi

# Accessibility cleanup
echo "[3/3] Resetting Accessibility Service..."
$ADB_CMD -s "$TARGET_DEVICE" shell "settings put secure accessibility_enabled 0" || true

# Optional uninstall
read -p "Uninstall Armaan tvOS completely? [y/N]: " UNINSTALL_APP
case "$UNINSTALL_APP" in
    [yY]|[yY][eE][sS])
        echo "Uninstalling Armaan tvOS..."
        $ADB_CMD -s "$TARGET_DEVICE" uninstall com.techgenius.tvoslauncher
        echo "Armaan tvOS uninstalled. User data preserved."
        ;;
    *)
        echo "Armaan tvOS remains installed."
        ;;
esac

# Cleanup state
rm -f "$STATE_FILE" || true
$ADB_CMD -s "$TARGET_DEVICE" shell "rm -f /sdcard/.armaan_tvos_state.txt" || true
$ADB_CMD -s "$TARGET_DEVICE" shell "input keyevent 3" || true

echo "Restore completed safely."
