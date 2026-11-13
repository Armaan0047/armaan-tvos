# Restore & Rollback Guide — Armaan tvOS

Armaan tvOS is 100% non-destructive and fully reversible. It operates entirely in Android user space, does not alter read-only system partitions, and preserves your TV's original factory software.

---

## 🛡️ State-Aware Rollback System

Unlike basic scripts that blindly attempt to restore a hardcoded launcher (such as Google TV or Xiaomi PatchWall), the Armaan tvOS installer creates a cryptographic hardware state backup when you install:
- **Local State File**: `scripts/.armaan_tvos_state.txt`
- **Device Backup File**: `/sdcard/.armaan_tvos_state.txt`

The state file records:
1. The **exact component name** of your previous home launcher (e.g. `com.google.android.apps.tv.launcherx/.home.HomeActivity` or `com.gathin.tvhome/.MainActivity`).
2. Whether the Accessibility service was activated by the installer.
3. Whether any manufacturer-specific packages were disabled.

---

## Method 1: Automated 1-Click Restore (Windows)

1. Connect your computer to your TV (or ensure both are on the same Wi-Fi).
2. Double-click `scripts/restore.bat`.
3. The restore utility:
   - Reads your backed-up state file and verifies that your original launcher is still installed on the TV.
   - Prompts for confirmation to restore that specific launcher.
   - If no state file exists (e.g. running from a new PC), it scans the TV for all installed home launchers and lets you select by number.
   - Re-enables any manufacturer packages that were modified during installation.
   - Resets the accessibility service.
   - Optionally asks if you would like to cleanly uninstall Armaan tvOS.

---

## Method 2: macOS, Linux & ChromeOS (`restore.sh`)

Open your terminal and run:

```bash
chmod +x scripts/restore.sh
./scripts/restore.sh
```

Follow the interactive prompts to restore your previous home launcher and revert any modified system settings.

---

## Method 3: Manual Safe ADB Commands (No Hardcoded Assumptions)

If you prefer using ADB commands directly in your terminal:

### 1. Discover all home launchers currently installed on your TV:
```bash
adb shell cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME
```
*Example output:*
```text
Activity #0: com.google.android.apps.tv.launcherx/.home.HomeActivity
Activity #1: com.techgenius.tvoslauncher/.MainActivity
```

### 2. Set your original launcher as default:
Copy your original launcher's component from the list above (do NOT use Armaan tvOS or FallbackHome):
```bash
adb shell cmd package set-home-activity <YOUR_STOCK_LAUNCHER_COMPONENT>
```
*Example:*
```bash
adb shell cmd package set-home-activity com.google.android.apps.tv.launcherx/.home.HomeActivity
```

### 3. Re-enable Xiaomi Partner Customizer (Xiaomi TVs only, if disabled):
```bash
adb shell pm enable com.xiaomi.android.tvsetup.partnercustomizer
```

### 4. Return to stock home screen:
```bash
adb shell input keyevent 3
```

### 5. (Optional) Uninstall Armaan tvOS:
```bash
adb uninstall com.techgenius.tvoslauncher
```
*(All your personal streaming app logins and TV settings remain 100% intact).*

---

## Method 4: Direct from TV System Settings (No Computer Required)

You can revert back to your factory launcher directly using your TV remote:

1. Open your TV's **System Settings** (gear icon or remote button).
2. Go to **Apps** → **Special app access** → **Default apps** → **Home app**.
3. Select your factory launcher from the list.
4. Press the **Home** button on your remote control.
