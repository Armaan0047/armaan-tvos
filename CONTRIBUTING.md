# Contributing to Armaan tvOS

Thanks for contributing to **Armaan tvOS**!

Armaan tvOS is an Apple tvOS 26–inspired home screen experience for Android TV and Google TV devices. Built in pure Java with zero heavy third-party runtime libraries, it is engineered to deliver 60 FPS fluid performance even on low-end 1 GB and 2 GB RAM TV hardware.

Armaan tvOS is maintained by **Armaan (Armaan0047)** and derived from the upstream project `tvOS-Launcher` by **techgenius (Siddhant)** under the **Apache License 2.0**.

---

## 1. Project Overview & Architecture

```text
AndroidManifest.xml                    Package com.techgenius.tvoslauncher
build.ps1                              Windows PowerShell build script (aapt2 → javac → d8 → zipalign → apksigner)
build.sh                               Unix bash build script
src/com/techgenius/tvoslauncher/       Core launcher engine (pure Java, ~10,000 lines)
├── MainActivity.java                  Main UI, dock/grid, liquid glass, carousel, status pill, D-pad debouncer
├── SettingsActivity.java              Configuration pages, appearance, button mapping toggles
├── SetupActivity.java                 Onboarding experience and permissions wizard
├── ButtonMapper.java                  Hardware button remapping, Mi button fix, Home long-press
├── RecentAppsOverlay.java             Recent Apps switcher, live RAM/Storage meters, swipe-up kill
├── ControlPanelOverlay.java           Control Center quick settings overlay (Inputs, Sleep, Wi-Fi, BT)
├── MediaWatchService.java             Universal Continue Watching provider
└── ...
res/                                   Resources: icons, accessibility configs, strings
screenshots/                           Real-device 1080p demonstration screenshots
scripts/                               1-click installation and restore scripts
```

---

## 2. Development Setup & Building

### Prerequisites
- **JDK 17 or higher** (`JAVA_HOME` set or automatically discovered in PATH)
- **Android SDK Build-Tools 34.0.0+** (`ANDROID_HOME` or `ANDROID_SDK_ROOT`)

### Building a Release APK (Windows)
```powershell
.\build.ps1 -Release
```
This generates:
- `build/armaan-tvos-release.apk` (Signed with v2 and v3 signatures using `release.keystore`)

### Building a Debug APK
```powershell
.\build.ps1
```

---

## 3. Core Principles

1. **Zero Bloatware / Pure Native Java**:
   - Do not introduce heavy dependencies, Kotlin runtimes, AndroidX Compose, or external UI frameworks.
   - Keep the private memory footprint under 85 MB RAM.
2. **Hardware Remote Friendly**:
   - Every UI element must be 100% controllable via standard 5-way D-pad TV remotes (Up, Down, Left, Right, Select/Enter, Back).
   - Ensure explicit focus states and smooth scroll snapping.
3. **Hardware Safety & Reversibility**:
   - Zero root requirements. Zero partition flashes.
   - Never disable critical system services like Bluetooth remote daemons, input methods, or system settings.

---

## 4. Submitting Pull Requests

1. Fork the repository `https://github.com/Armaan0047/armaan-tvos`.
2. Create a feature branch: `git checkout -b feature/my-improvement`.
3. Test your build on real TV hardware (or Android TV emulator).
4. Ensure `build.ps1 -Release` compiles cleanly without warnings or errors.
5. Commit with clear, descriptive commit messages.
6. Submit a Pull Request targeting the `main` branch.

---

## 5. Licensing & Attribution

Armaan tvOS is licensed under the **Apache License 2.0**.
Contributions submitted to this repository will be licensed under the same Apache 2.0 terms.
Upstream attributions to `techgenius1/tvOS-Launcher` and original authors are preserved in `LICENSE` and `NOTICE`.
