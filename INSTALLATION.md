# Installation Guide — Armaan tvOS

This guide covers all methods to install and configure **Armaan tvOS** on your Android TV, Google TV, or Fire TV device.

---

## Method 1: 1-Click Automated Installer (Windows - Recommended)

If your computer and TV are on the same Wi-Fi network or connected via USB:

1. Enable **Developer Options** and **USB / Network Debugging** on your TV:
   - Go to `Settings` → `Device Preferences` → `About`.
   - Scroll to **Build** and click it 7 times until you see *"You are now a developer!"*.
   - Return to `Device Preferences` → `Developer options`.
   - Enable **USB debugging**.
2. Run `scripts/install.bat`.
3. Enter your TV's IP address when prompted (found under `Settings` → `Network & Internet` → `Wi-Fi Details`).
4. Look at your TV screen and accept the **"Allow USB Debugging?"** prompt (check *Always allow from this computer*).
5. The script will automatically install Armaan tvOS, enable the accessibility service for the Button Mapper and Control Center, fix the Xiaomi Mi button behavior, and set Armaan tvOS as your default launcher.

---

## Method 2: Manual Installation via ADB (Cross-Platform: Windows, macOS, Linux)

### Step 1: Connect to your TV
```bash
adb connect <YOUR_TV_IP>:5555
```
*(Verify connection using `adb devices`)*

### Step 2: Install Armaan tvOS Release APK
```bash
adb install -r -g build/armaan-tvos-release.apk
```

### Step 3: Enable the Accessibility Service
The accessibility service powers the remote button mapping, Control Center overlay, and background task killer:
```bash
adb shell settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService
adb shell settings put secure accessibility_enabled 1
```

### Step 4 (Xiaomi TVs Only): Disable Partner Customizer Fallback
On Xiaomi TVs (e.g. MiTV-AXSO2), pressing the Mi button attempts to launch PatchWall; if PatchWall is debloated, the system falls back into HDMI 3. Disabling this safe partner stub prevents that redirect:
```bash
adb shell pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer
```

### Step 5: Set as Default Home Launcher
```bash
adb shell cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity
adb shell am start -n com.techgenius.tvoslauncher/.MainActivity
```

---

## Method 3: USB Drive / Local Sideloading

1. Copy `armaan-tvos-release.apk` to a FAT32 or exFAT formatted USB drive.
2. Insert the USB drive into your Android TV's USB port.
3. Open any file manager on your TV (such as *FX File Explorer*, *AnExplorer*, or *File Commander*).
4. Select `armaan-tvos-release.apk` and click **Install**.
   *(If prompted, allow the file manager to install unknown apps).*
5. Open **Armaan tvOS** from your apps drawer.
6. Follow the on-screen Setup Wizard:
   - Set as default launcher when prompted.
   - Go to `Settings` → `Button Mapper` and click **Enable Accessibility Service**.

---

## Remote Control Shortcuts

| Remote Button | Action in Armaan tvOS |
|---|---|
| **Home (Single Tap)** | Returns to Armaan tvOS Home screen |
| **Home (Long Press 500ms)** | Opens the **Recent Apps Switcher** + Live RAM/Storage Meter |
| **Mi / PatchWall Button** | Returns to Armaan tvOS Home screen (HDMI 3 loop eliminated) |
| **D-pad Up (in Recent Apps)** | Closes/kills the focused background app card |
| **Menu / Settings** | Opens the Liquid Glass **Control Center** overlay |
