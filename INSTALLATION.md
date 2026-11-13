# Universal Installation Guide — Armaan tvOS

**Armaan tvOS** includes an intelligent, hardware-aware universal installer designed for all Android TV, Google TV, and assembled/white-label televisions.

Before making any changes, the installer runs a non-destructive read-only inspection of your television's hardware, classifies compatibility, and guarantees that vendor-specific hacks are never run on generic or non-matching hardware.

---

## 🌟 Universal Installer Safety Guarantees

1. **Read-Only Inspection First**: Queries hardware properties, RAM, storage, CPU architecture, and current active launcher before touching any configuration.
2. **Strict Zero-Assumption Rule**: Proprietary vendor commands (such as Xiaomi's partner customizer disable) are **NEVER** run universally. They are only considered when a device is positively identified as that specific brand and the user explicitly requests it.
3. **State-Aware Rollback**: The installer records your previously active home launcher and any modified system settings to a local backup state file (`scripts/.armaan_tvos_state.txt`) and to your TV (`/sdcard/.armaan_tvos_state.txt`).
4. **Safe for Assembled & Unknown TVs**: For white-label, generic Amlogic/Rockchip/Allwinner boards, or assembled smart TVs, the installer flags the device for manual review and preserves the factory launcher.

---

## Method 1: 1-Click Universal Installer (Windows - Recommended)

### Prerequisites: Enable USB / Network Debugging on your TV
1. On your Android TV, navigate to **Settings** → **Device Preferences** (or **System**) → **About**.
2. Highlight **Build** (or **Android TV OS build**) and click it **7 times** until you see:
   > *"You are now a developer!"*
3. Return to **Device Preferences** → **Developer options**.
4. Turn **ON** **USB debugging** (and **Network debugging** if available).
5. Note your TV's IP address under **Settings** → **Network & Internet** → your connected Wi-Fi network.

### Running the Installer:
1. Double-click `scripts/install.bat` on your Windows PC.
2. If prompted, type your TV's IP address (e.g. `192.168.1.100`) and press Enter.
3. Look at your TV screen and select **"Always allow from this computer"**, then click **OK**.
4. The installer inspects your TV and displays your complete **Device Profile Card** with compatibility classification.
5. Choose your desired installation mode:
   - **Mode A (Basic APK Installation)**: *Safest option.* Installs Armaan tvOS and opens it. Your stock launcher remains 100% active and untouched.
   - **Mode B (Full Launcher Setup)**: Backs up your current launcher, enables the accessibility service, and sets Armaan tvOS as your default home screen with user confirmation.
   - **Mode C (Manufacturer Fixes)**: Shows vendor-specific tweaks (such as the Xiaomi Mi button fix) only if hardware is positively matched and confirmed.

---

## Method 2: macOS, Linux & ChromeOS (`install.sh`)

Open your terminal, navigate to the `armaan-tvos` folder, and execute:

```bash
chmod +x scripts/install.sh scripts/restore.sh
./scripts/install.sh
```

The script runs the same read-only device probe, prints the hardware compatibility card, and prompts for Mode A, Mode B, or Mode C.

---

## Method 3: USB Drive / Local Sideloading

If your computer and TV are not on the same Wi-Fi network:

1. Copy `build/armaan-tvos-release.apk` to a USB flash drive (FAT32 or exFAT).
2. Insert the USB drive into your television.
3. Open a file manager on your TV (such as *FX File Explorer* or *AnExplorer*).
4. Select `armaan-tvos-release.apk` and click **Install**.
5. Launch **Armaan tvOS** from your app drawer.
6. The on-screen Setup Wizard will guide you through permissions.

---

## 🛠️ Manual ADB Commands (Advanced Users)

If you prefer executing manual commands, always follow these universal, non-destructive steps:

### Step 1: Connect and Install APK
```bash
adb connect <YOUR_TV_IP>:5555
adb install -r -g build/armaan-tvos-release.apk
```

### Step 2: Query Current Home Activity (For Rollback Record)
```bash
adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
```
*(Write down the component name returned, e.g. `com.google.android.apps.tv.launcherx/.home.HomeActivity` or `com.android.launcher3/.Launcher`).*

### Step 3: Enable Accessibility Service (Button Remapper & Control Center)
```bash
adb shell settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService
adb shell settings put secure accessibility_enabled 1
```

### Step 4: Set as Default Home Launcher
```bash
adb shell cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity
adb shell am start -n com.techgenius.tvoslauncher/.MainActivity
```

### ⚠️ Manufacturer-Specific Fixes (NEVER Run Universally)
**Xiaomi TVs Only**:
If and only if you are using a Xiaomi smart TV where pressing the remote's Mi/PatchWall button forces an unwanted jump to HDMI 3, disable the partner customizer fallback:
```bash
# ONLY execute on verified Xiaomi TVs:
adb shell pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer
```
*Do not run this command on Google TV, Sony, TCL, Philips, Fire TV, or assembled/white-label TVs.*

---

## 🔄 Reverting to Factory Configuration

To restore your previous launcher at any time:
- **Windows**: Double-click `scripts/restore.bat`.
- **macOS / Linux**: Run `./scripts/restore.sh`.

The restore tool reads your backed-up launcher component and safely restores your television to its original factory state without data loss. Detailed instructions are in **[RESTORE_GUIDE.md](RESTORE_GUIDE.md)**.
