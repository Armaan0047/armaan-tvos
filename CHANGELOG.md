# Changelog — Armaan tvOS

All notable changes to **Armaan tvOS** are documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

---

## [v1.0.0] — 2026-11-13 — Official Public Launch (Armaan Edition)

### ✨ Core Features & Enhancements
- **tvOS 26 & Apple tvOS Aesthetics**:
  - Pure Java native rendering with authentic Liquid Glass and Frosted Glass shaders.
  - Centered squircle app dock with real-time blur and fluid magnification animations.
  - Rotating Apple TV–inspired Night Scenes and custom wallpaper engine (Single, Multi, Folder Shuffle, and Reddit integration).
- **Recent Apps Switcher & Performance Hub**:
  - tvOS-style full-screen card switcher displaying recently used applications.
  - **Live Hardware Telemetry**: Real-time dual glass pills showing active RAM usage and Internal Storage capacity.
  - **D-pad Up to Kill**: Fluid swipe-up card animation that gracefully stops background processes without touching protected system services.
  - **Close All Apps**: Sequential card dismissal with memory reclamation feedback.
  - **System Safety Whitelist**: Protected whitelist preserving SystemUI, Settings, Remote Daemons, Input Methods, and TV Input services.
- **Button Mapper & Remote Lag Debounce**:
  - **Xiaomi Mi / PatchWall Button Fix**: Intercepts `KEYCODE_BUTTON_5` (192) and `KEYCODE_PROG_RED` (183) before system fallbacks trigger, opening Armaan tvOS Home screen instead of abruptly switching to HDMI 3.
  - **Home Button Long-Press (500ms)**: Holding the Home button triggers the Recent Apps Switcher overlay; single short-tap opens the Home screen.
  - **D-Pad Burst Debouncer**: Hardware input filter dropping spurious rapid repeats (<65ms) from erratic Bluetooth remote links, eliminating stuck and lagged button navigation.
  - Multi-tap mapping for Red, Green, Yellow, Blue, Menu, Guide, and Info buttons.
- **Control Center Overlay**:
  - Glass quick-access panel accessible from anywhere (or over any running application).
  - Instant toggles for Sleep / Power Off, Wi-Fi Settings, Bluetooth Devices, Inputs Switcher, Dark Mode, and System Settings.
- **Standalone TV Inputs Switcher**:
  - Native overlay allowing instant switching between HDMI 1, HDMI 2, HDMI 3, and AV inputs even when stock launchers are debloated or disabled.
- **Universal Continue Watching**:
  - Dock-linked Watch Next shelf integrating YouTube, SmartTube, Netflix, Prime Video, Apple TV+, Disney+, Stremio, and Nuvio.
- **Status Pill Customization**:
  - Choose between Minimal (time + profile), Weather pill, or Full status pill (weather, Wi-Fi, Bluetooth, microphone, settings).

### 🛠️ Build & Packaging
- Windows PowerShell build pipeline (`build.ps1 -Release`) with dynamic JDK 17+ auto-discovery.
- Pre-configured APK Signature Scheme v2 and v3 production release keys.
- Standalone 1-click Windows helper scripts (`scripts/install.bat` and `scripts/restore.bat`).

### ⚖️ Legal & Upstream Credits
- Licensed under Apache License 2.0.
- Upstream base: `techgenius1/tvOS-Launcher` by techgenius (Siddhant).
- All third-party fonts (Inter OFL) and QR code libraries (MIT) credited in `NOTICE`.
