# Device Compatibility & Hardware Requirements — Armaan tvOS

Armaan tvOS is designed to run across a wide spectrum of Android television hardware, from budget 1 GB streaming sticks to high-end 4K Google TVs and custom assembled smart TV motherboards.

Because television hardware varies significantly across manufacturers and white-label assemblers, compatibility is divided into **APK execution compatibility** versus **feature-level compatibility**.

---

## 🧭 Compatibility Classification Matrix

The Armaan tvOS universal installer automatically evaluates your hardware against the following matrix:

| Classification | Hardware Criteria | Experience & Recommendations |
|---|---|---|
| **COMPATIBLE** | • Android 9.0+ (API Level 28+)<br>• RAM: 1.0 GB or higher<br>• Free Storage: ≥ 150 MB<br>• Leanback TV flag: `true`<br>• Branded TV OS (Google TV, Android TV) | **Optimal 60 FPS Experience**<br>• Full Liquid Glass refraction<br>• Universal Continue Watching active<br>• Full Control Center & Recent Apps switcher |
| **COMPATIBLE WITH LIMITATIONS** | • Android 7.0 – 8.1 (API 24–27)<br>• RAM: 512 MB – 950 MB<br>• Free Storage: 30 MB – 150 MB | **Supported with Visual Tuning**<br>• APK runs reliably<br>• Recommend setting Glass Blur to Low or Medium in Settings<br>• Use Minimal Status Pill to conserve RAM<br>• Older Android versions may have partial TvContract Watch Next support |
| **NEEDS MANUAL VERIFICATION** | • Generic / Assembled motherboards<br>• Manufacturer reported as `unknown`, `generic`, `android`<br>• Model reported as `smart_tv`, `box`, `ott`<br>• Leanback flag missing (Tablet/Phone AOSP build) | **Requires Mode A Testing First**<br>• Run installer in **Mode A (Basic APK Install)** to verify remote control responsiveness and UI scaling<br>• Zero manufacturer tweaks are applied<br>• Verify default launcher behavior before setting default home |
| **UNSUPPORTED** | • Android 6.0 or older (API < 24)<br>• Free Storage < 30 MB<br>• Non-Android OS (Tizen, webOS, RokuOS) | **Incompatible**<br>• Installation is blocked to prevent device bootloops or corrupted states |

---

## 🔬 Hardware Verification Status

To ensure complete transparency, hardware testing is explicitly categorized:

### 1. Physically Tested & Verified Hardware
- **Xiaomi MiTV-AXSO2 (dangalUHD)**:
  - Chipset: Amlogic T950X / txlx (ARM32 `armeabi-v7a`)
  - OS: Android TV 11 (API 30)
  - RAM: 2.0 GB
  - Verification: Live verified. Full 60 FPS home screen, Recent Apps switcher with live RAM/Storage meters, Control Center overlay, and hardware Mi button remapping.

### 2. Tested via Hardware Test Fixtures
- **Generic Amlogic Reference Board (p212 / g12a)**:
  - OS: Android 9.0 (API 28), 1.0 GB RAM
  - Status: Classified as *Needs Manual Verification*. Installer bypasses all vendor hacks and preserves stock AOSP launcher.
- **Google TV (Chromecast with Google TV / sabrina)**:
  - OS: Android 12 (API 31), 2.0 GB RAM
  - Status: Classified as *Compatible*. Standard Google TV home activity cleanly overridden and restored.
- **Assembled / White-Label OTT TV Box (Rockchip rk3328 / rk3328_box)**:
  - OS: Android 10 (API 29), 1.0 GB RAM, Leanback missing
  - Status: Classified as *Needs Manual Verification*. Detected as assembled hardware; protected against vendor package modifications.

---

## ⚙️ Chipset Architecture Overview

Armaan tvOS compiles to universal Android bytecode compatible with:
- **Amlogic**: S905X, S905X2, S905X3, S905X4, S905Y4, T950X, T962X, T972, T982
- **MediaTek**: MT9611, MT9638, MT9675, MT9950, Pentonic 700 / 1000
- **Realtek**: RTD2871, RTD2984
- **Rockchip**: RK3328, RK3399, RK3566, RK3588 (TV box firmware)
- **Allwinner**: H6, H616, H618 (Smart projectors and budget TV sticks)

---

## 🛡️ Assembled & Unknown TV Policy

If you or your friends own an assembled TV built from a white-label LCD controller board (common in local repair shops and custom smart TV builds):
1. **Never guess the manufacturer**: The installer reads kernel properties directly from `ro.hardware` and `ro.board.platform`.
2. **Never apply Xiaomi fixes**: Xiaomi partner packages do not exist on generic boards and attempting to disable them can cause error states.
3. **Always use Mode A first**: Verify that your TV remote's D-pad (Up, Down, Left, Right, OK, Back) responds smoothly before setting Armaan tvOS as your primary launcher in Mode B.
