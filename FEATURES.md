# Features & Capabilities — Armaan tvOS

**Armaan tvOS** transforms your Android TV or Google TV into an ultra-clean, lightning-fast Apple tvOS experience.

---

## 1. Ultra-Lightweight Native Architecture
- **Tiny Memory Footprint**: Runs on ~42 MB RAM on 1 GB Android TV devices, and ~85 MB RAM on 2 GB Google TV devices.
- **Pure Native Java**: Zero Kotlin runtime overhead, zero Jetpack Compose, zero third-party UI framework bloat.
- **Instant Fluidity**: On-the-fly hardware-accelerated drawing designed to eliminate stutter on budget Amlogic and MediaTek chipsets.

---

## 2. Liquid Glass & Frosted Glass Shaders
- **Dual Glass Aesthetics**:
  - **Liquid Glass**: Refracting, crystal-clear glass inspired by modern Apple design.
  - **Frosted Glass**: Smooth, soft diffused frosted blur behind overlays and menus.
- **Adjustable Blur**: Customize the blur radius and tint directly in Settings to balance visual fidelity with hardware performance.
- **Automatic Dark Mode**: Seamlessly switches to dark themes at sunset or on a custom schedule, complete with iOS-style dark icons.

---

## 3. Status Pill Customization
Customize the floating top status bar to match your personal aesthetic:
- **Minimal**: Shows only the current time and active user profile badge.
- **Weather Pill**: Dedicated weather conditions and temperature readout.
- **Full Status Bar**: Comprehensive pill displaying the time, day/night celestial indicator, weather temperature, Wi-Fi status, Bluetooth connectivity, microphone dictation shortcut, and Quick Settings icon.

---

## 4. Apps, Folders & Favorites Row
- **Apple tvOS Dock**: Fluidly magnifying dock row with dynamic squircle icons and subtle reflection effects.
- **Folders**: Organize applications into categorized groups (e.g. *Streaming*, *Gaming*, *Utilities*), opening cleanly onto a frosted glass stage.
- **Favorites Management**: Pin your most frequently accessed streaming apps directly to the primary dock row.

---

## 5. Universal Continue Watching & Full-Screen Backdrops
- **Cross-App Integration**: Aggregates Watch Next items from YouTube, SmartTube, Netflix, Prime Video, Disney+, Apple TV+, Tivimate, Stremio, and Nuvio.
- **Full-Screen Media Backdrops**: Hovering over an app displays rich artwork; swipe up with your remote to transition into an uncluttered, cinematic full-screen backdrop view.
- **Direct Deep-Linking**: Launch directly into the specific episode or movie without navigating through nested app menus.

---

## 6. Recent Apps Switcher & Hardware Telemetry Hub
- **Apple tvOS Multitasking UI**: Dedicated full-screen card switcher displaying recently launched apps with high-resolution thumbnail cards.
- **Live RAM & Storage Meters**: Dual liquid glass pills at the top right displaying real-time memory usage (e.g. `RAM 1.1 GB of 2.0 GB`) and flash storage capacity.
- **Swipe-Up to Close App**: Highlight any app card and press **D-pad Up** to dismiss the card and gracefully kill the background process.
- **Close All Apps**: One-click action to dismiss all recent cards with an animated stagger effect.
- **System Whitelist Protection**: Critical TV components (SystemUI, Bluetooth remote services, IME keyboards, HDMI input managers) are automatically whitelisted to prevent system instability.

---

## 7. Glass Control Center Overlay
- **Instant Overlay**: Accessible over any running app or from the home screen without interrupting playback.
- **One-Press Quick Actions**:
  - **Sleep / Power Off**: Put the TV to sleep or set an automatic sleep timer.
  - **Wi-Fi Details & Quick Settings**: View active SSID and jump into network settings.
  - **Bluetooth Manager**: Connect or pair gamepads, headphones, and remotes.
  - **Inputs Switcher**: Instantly switch between HDMI 1, HDMI 2, HDMI 3, and AV inputs.
  - **AirPlay / Google Cast Guard**: Monitor active cast sessions.
  - **Dark Mode Toggle**: Instantly switch between light and dark glass aesthetics.

---

## 8. Remote Button Remapping & Hardware Debounce
- **Xiaomi Mi / PatchWall Button Fix**: Intercepts `KEYCODE_BUTTON_5` (192) and `KEYCODE_PROG_RED` (183), rerouting the Mi button to open the Armaan tvOS Home screen instead of abruptly jumping to HDMI 3.
- **Home Button Long-Press (500 ms)**: Pressing and holding the remote's Home button opens the Recent Apps switcher; a quick tap opens the Home screen.
- **D-Pad Burst Debouncer**: Ignores rapid, erratic repeat packets (<65 ms) sent by noisy Bluetooth remote connections, completely resolving stuck and skipping navigation issues.
- **Color Buttons Remapping**: Assign single, double, or triple taps on Red, Green, Yellow, Blue, Menu, Guide, and Info buttons to launch favorite apps, the Control Center, or the Inputs overlay.
