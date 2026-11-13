# Armaan tvOS (`v1.0.0`)

<p align="center">
  <img src="screenshots/01_home_screen.png" alt="Armaan tvOS Home Screen" width="900" />
</p>

<p align="center">
  <b>The Complete Apple tvOS Experience, Re-Engineered for Android TV & Google TV.</b><br>
  Built in pure native Java with zero runtime bloatware — buttery-smooth 60 FPS performance even on 1 GB RAM TVs.
</p>

<p align="center">
  <a href="https://github.com/Armaan0047/armaan-tvos/releases/latest"><img src="https://img.shields.io/github/v/release/Armaan0047/armaan-tvos?style=flat-square&color=blue&label=Latest%20Release" alt="Latest Release" /></a>
  <img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Platform-Android%20TV%209%E2%80%9314%2B-orange.svg?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/RAM%20Footprint-~42MB%20(1GB)%20%2F%20~85MB%20(2GB)-purple.svg?style=flat-square" alt="RAM Usage" />
  <img src="https://img.shields.io/badge/Developer-Armaan-black.svg?style=flat-square" alt="Developer" />
</p>

---

## ⚡ Highlights & Key Features

### 🪶 Tiny App. Tiny Footprint.
- **Ultra-Low Memory Consumption**: Consumes only **~42 MB RAM** on 1 GB Android TV devices, and **~85 MB RAM** on 2 GB Google TV devices.
- **Zero Heavy Runtimes**: 100% native Java architecture without Kotlin overhead, Jetpack Compose, or bulky webview engines.
- **Silky 60 FPS Navigation**: Layouts and glass graphics are drawn on-the-fly and let go immediately when an app launches, keeping memory free for your streaming video playback.

---

### 🔮 Liquid Glass & Frosted Glass Shaders
- **Dual Glass Styles**: Choose between high-refraction **Liquid Glass** (modern tvOS styling) or a soft, diffused **Frosted Glass** blur.
- **Customizable Blur**: Adjust blur radius directly in Settings to tailor visual depth to your TV's GPU capability.
- **Automatic Dark Mode**: Automatically transitions between light and dark glass at sunset or on a custom schedule, featuring authentic iOS-style dark app icons.

<p align="center">
  <img src="screenshots/02_night_scenes_sunset.png" alt="Armaan tvOS Night Scenes" width="800" />
</p>

---

### 💊 Glass Status Pills, Your Way
Personalize the top floating glass pill to match your needs:
- **Minimal**: Crisp display of the current time and active user profile.
- **Weather**: Current temperature and atmospheric conditions.
- **Full Status Bar**: Comprehensive pill displaying the time, day/night indicator, weather, Wi-Fi status, Bluetooth connection, microphone search, and Settings shortcut.

---

### 📂 Folders, Favorites & Centered Dock
- **Dynamic Squircle Dock**: Apple-style centered app dock with fluid focus magnification and subtle reflective highlights.
- **App Folders**: Group applications into clean categories (Streaming, Gaming, Utilities) that open on an authentic frosted glass modal.
- **Quick Favorites**: Easily organize and reorder your favorite streaming services.

---

### 📺 Continue Watching & Full-Screen Backdrops
- **Universal Watch Next**: Aggregates episodes and movies from YouTube, SmartTube, Netflix, Prime Video, Disney+, Apple TV+, Tivimate, Stremio, and Nuvio.
- **Swipe-Up Backdrops**: Focused apps display dynamic artwork; simply swipe up on your remote to transition into a full-screen backdrop view.
- **Direct Deep Links**: Jump straight into your next episode with a single click.

---

### 🔄 Recent Apps Switcher + Live RAM & Storage Hub
An authentic tvOS multitasking card switcher built right into your TV:
- **Large Preview Cards**: Seamlessly toggle between recently opened applications.
- **Live Hardware Telemetry**: Dual real-time liquid glass meters showing active RAM and Internal Flash Storage usage.
- **D-pad Up to Kill**: Highlight any running app card and swipe Up on your remote to dismiss the card and cleanly terminate the background process.
- **Close All Apps**: Fast batch closure with a staggered card animation.
- **System Protection Whitelist**: Safeguards critical system services (SystemUI, Bluetooth remote daemons, keyboards, HDMI managers) from accidental termination.

<p align="center">
  <img src="screenshots/03_recent_apps_switcher.png" alt="Recent Apps Switcher" width="800" />
</p>

---

### 🎛️ Glass Control Center Overlay
One press away, anytime, anywhere:
- Accessible over the home screen or **over any running app** without stopping video playback.
- **Quick Controls**: Sleep / Power Off timer, Wi-Fi status & setup, Bluetooth devices, HDMI Inputs switcher, AirPlay/Cast monitor, Dark Mode toggle, and System Settings.

<p align="center">
  <img src="screenshots/04_control_center.png" alt="Control Center Overlay" width="800" />
</p>

---

### 🎮 Remote Button Remapper & Hardware Input Fixes
- **Xiaomi Mi / PatchWall Button Fix**: Intercepts `KEYCODE_BUTTON_5` (192) and `KEYCODE_PROG_RED` (183). Permanently prevents the TV from unexpectedly switching to HDMI 3, opening Armaan tvOS Home screen instead.
- **Home Button Long-Press (500 ms)**: Holding the Home button opens the Recent Apps switcher; a single tap returns to the Home screen.
- **D-Pad Burst Debouncer**: Hardware input filter ignoring spurious rapid repeat packets (<65 ms) caused by Bluetooth interference, eliminating stuck navigation and input lag.
- **Color Button Remapping**: Assign actions or apps to Red, Green, Yellow, Blue, Menu, Guide, and Info remote buttons.

<p align="center">
  <img src="screenshots/06_button_mapper_settings.png" alt="Button Mapper Settings" width="800" />
</p>

---

### 🔌 Standalone TV Inputs Switcher
- Switch between **HDMI 1**, **HDMI 2**, **HDMI 3**, and **AV** inputs through an elegant glass overlay.
- Works even when the stock manufacturer launcher has been completely disabled or debloated.

<p align="center">
  <img src="screenshots/05_inputs_overlay.png" alt="TV Inputs Overlay" width="800" />
</p>

---

## 🚀 Universal Hardware-Aware Installer

Armaan tvOS features an intelligent, device-detecting universal installer that safely inspects your Android TV before making any changes. It works across branded, assembled, and unknown Android TV motherboards without making dangerous assumptions.

### 🛡️ Safety & Compatibility First
- **Read-Only Probe**: Identifies manufacturer, brand, model, board platform, Android SDK level, total RAM, and storage before modifying configuration.
- **Strict Zero-Assumption Rule**: Proprietary vendor commands (e.g. Xiaomi's partner customizer disable) are **NEVER** run on generic or non-matching hardware.
- **Three Safe Modes**:
  - **Mode A (Basic APK Install)**: Safest mode. Installs Armaan tvOS and leaves your factory launcher 100% active and untouched.
  - **Mode B (Full Launcher Setup)**: Automatically backs up your current launcher to a local and on-device state file, configures accessibility, and sets Armaan tvOS as default home upon explicit confirmation.
  - **Mode C (Manufacturer Fixes)**: Shows vendor-specific tweaks only when hardware is positively matched and confirmed.
- **State-Aware 1-Click Rollback**: Restores your exact previous launcher without hardcoded guesses.

### Quick Start
- **Windows**: Double-click `scripts/install.bat` and follow the on-screen device profile card.
- **macOS / Linux**: Run `./scripts/install.sh`.
- **Safe Rollback**: Run `scripts/restore.bat` (or `./scripts/restore.sh`) at any time to restore your original stock launcher.

For manual ADB instructions, USB sideloading, or detailed troubleshooting, see **[INSTALLATION.md](INSTALLATION.md)** and **[RESTORE_GUIDE.md](RESTORE_GUIDE.md)**.

---

## 📺 Device Compatibility & Classification Matrix

Armaan tvOS evaluates hardware into 4 distinct compatibility classes:
- **COMPATIBLE**: Branded Android TV & Google TV devices (Android 9.0+, ≥1 GB RAM) with full 60 FPS Liquid Glass experience.
- **COMPATIBLE WITH LIMITATIONS**: Android 7.0–8.1 or devices with 512 MB–950 MB RAM (supported with tuned blur settings).
- **NEEDS MANUAL VERIFICATION**: Assembled, white-label, or generic boards (Amlogic, Rockchip, Allwinner). Run Mode A to verify remote navigation.
- **UNSUPPORTED**: Android 6.0 or below, or storage < 30 MB.

See **[DEVICE_COMPATIBILITY.md](DEVICE_COMPATIBILITY.md)** for the complete hardware audit and tested fixtures.

---

## 🛠️ Building from Source

### Prerequisites
- JDK 17 or higher
- Android SDK Build-Tools 34.0.0+

```powershell
# Build signed production release APK (Windows)
.\build.ps1 -Release

# Output: build\armaan-tvos-release.apk (Signed with APK Signature Scheme v2 & v3)
```

---

## ⚖️ License & Attribution

Armaan tvOS is open source software licensed under the **[Apache License 2.0](LICENSE)**.

### Credits & Acknowledgments
- **Upstream Project**: Derived from and inspired by [tvOS-Launcher](https://github.com/techgenius1/tvOS-Launcher) by **techgenius (Siddhant)** under Apache-2.0.
- **Inter Typeface**: Designed by Rasmus Andersson — SIL Open Font License 1.1.
- **QR Code Generator Library**: Copyright (c) Project Nayuki — MIT License.
- **Inspirations**: Hume Launcher, Couch TV, CleanYourTV.

Full legal attribution and third-party notices are detailed in **[NOTICE](NOTICE)**.
