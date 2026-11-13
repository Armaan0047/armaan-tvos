# Restore Guide — Reverting to Stock TV Launcher

Armaan tvOS is 100% safe, non-destructive, and fully reversible. It does not overwrite any system partitions or delete system APKs from the Android root directory.

If you ever want to switch back to your factory launcher (such as Google TV Launcher, Android TV Home, or Xiaomi PatchWall), follow the steps below.

---

## Method 1: Automated 1-Click Restore (Windows)

1. Connect your PC to the TV (or ensure both are on the same Wi-Fi).
2. Run `scripts/restore.bat`.
3. The script will:
   - Re-enable the Xiaomi Partner Customizer service.
   - Reset your TV's default home activity back to the stock launcher.
   - Send the Home key event to display your original launcher immediately.
   - Optionally offer to cleanly uninstall Armaan tvOS.

---

## Method 2: Manual ADB Commands

Run the following commands in your terminal:

```bash
# 1. Connect to your TV
adb connect <YOUR_TV_IP>:5555

# 2. Re-enable Xiaomi system customizers (if on Xiaomi TV)
adb shell pm enable com.xiaomi.android.tvsetup.partnercustomizer

# 3. Reset default launcher to Google TV or Android TV Home
adb shell cmd package set-home-activity com.google.android.tvlauncher/.MainActivity
# For Xiaomi stock PatchWall launcher:
adb shell cmd package set-home-activity com.mitv.tvhome.atv/.MainActivity

# 4. Return to home screen
adb shell input keyevent 3

# 5. (Optional) Uninstall Armaan tvOS
adb uninstall com.techgenius.tvoslauncher
```

---

## Method 3: Direct from TV Interface (No PC Required)

1. Open your TV's **System Settings** (gear icon or remote button).
2. Navigate to **Apps** → **Special app access** → **Default apps** → **Home app**.
3. Select your stock launcher (e.g. *Android TV Home*, *Google TV*, or *PatchWall*).
4. Press the **Home** button on your remote. You are now back to your factory interface.
