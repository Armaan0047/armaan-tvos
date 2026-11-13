# Armaan tvOS v1.0.0 — Official Public Release

Welcome to the official public release of **Armaan tvOS**!

**Armaan tvOS** is an ultra-fast, lightweight Apple tvOS 26–inspired television experience built in pure native Java for Android TV, Google TV, and Fire TV devices.

---

## 🌟 What's New in v1.0.0 (Armaan Edition)

### 🚀 Liquid Glass & tvOS 26 Visual Experience
- Authentic Apple tvOS interface with centered magnifying dock and squircle icons.
- **Liquid Glass** and **Frosted Glass** real-time shaders with customizable blur and dark mode scheduling.
- **Status Pill Customization**: Switch between Minimal (time + profile), Weather pill, or Full status bar (Wi-Fi, Bluetooth, mic, settings).
- **Universal Continue Watching**: Aggregates media rows from YouTube, Netflix, Prime Video, Apple TV+, and Stremio, featuring a swipe-up full-screen backdrop view.

### ⚡ Recent Apps Switcher + Live RAM & Storage Hub
- Full-screen multitasking switcher displaying large app cards.
- **Live Hardware Telemetry**: Real-time RAM and Internal Storage liquid glass progress bars.
- **D-pad Up to Kill**: Press Up on any card to close and kill the background process.
- **Close All Apps**: Fast batch cleaner with animated card dismissals.
- **Protected System Whitelist**: Safeguards SystemUI, Settings, Remote daemons, and Input methods from being killed.

### 🎮 Remote Button Remapper & Hardware Input Fixes
- **Xiaomi Mi / PatchWall Button Fix**: Intercepts the Mi button (`KEYCODE_BUTTON_5` / 192) and routes it directly to Armaan tvOS Home, permanently eliminating the unwanted jump to HDMI 3.
- **Home Button Long-Press (500ms)**: Hold the Home button to open the Recent Apps switcher; tap quickly to return Home.
- **D-Pad Burst Debouncer**: Prevents double-taps and stuck navigation caused by Bluetooth remote lag and 2.4 GHz interference.
- Multi-tap mapping for colored remote keys (Red, Green, Yellow, Blue).

### 🎛️ Glass Control Center & TV Inputs Overlay
- Fast overlay accessible from any app with Sleep, Wi-Fi, Bluetooth, Dark Mode, and Settings.
- Standalone **Inputs Switcher** providing instant switching between HDMI 1, HDMI 2, HDMI 3, and AV without needing stock TV launchers.

---

## 📦 Download & Verification

- **APK File**: `armaan-tvos-release.apk`
- **Signing**: APK Signature Scheme v2 & v3 verified
- **Compatibility**: Android TV 9.0 through Android 14+ (ARM32, ARM64, x86)

### Quick Install (Windows)
```cmd
adb install -r -g armaan-tvos-release.apk
adb shell settings put secure enabled_accessibility_services com.techgenius.tvoslauncher/.PowerService
adb shell settings put secure accessibility_enabled 1
adb shell cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity
```
*(Or run `scripts/install.bat` included in the source code).*

---

## ⚖️ Legal & Upstream Attribution
- Licensed under the **Apache License 2.0**.
- Derived from `tvOS-Launcher` by **techgenius (Siddhant)** (`https://github.com/techgenius1/tvOS-Launcher`).
- Inter typeface (SIL Open Font License 1.1) and Project Nayuki QR Code library (MIT).
