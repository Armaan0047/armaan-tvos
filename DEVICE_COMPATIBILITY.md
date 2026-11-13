# Device Compatibility & Hardware Requirements — Armaan tvOS

**Armaan tvOS** is engineered to run on Android TV 9.0 through Android TV 14+. It features a pure Java native architecture with zero heavy runtimes, making it ideal for budget and low-RAM smart TVs as well as flagship media players.

---

## Hardware Specifications & Resource Footprint

| Metric | Minimum Requirement | Verified Performance |
|---|---|---|
| **RAM** | 1 GB | **~42 MB RAM** on 1 GB Android TV 9; **~85 MB RAM** on 2 GB Android TV 11 |
| **Storage / APK Size** | 10 MB free | **~6.8 MB APK** (including complete offline wallpaper pack) |
| **Operating System** | Android 9.0 (API 28)+ | Verified on Android 9, Android 11, Android 12, Android 14 |
| **Architecture** | ARM32 (`armeabi-v7a`), ARM64 (`arm64-v8a`), x86 | Universal bytecode |

---

## Verified & Tested TV Models

### 1. Xiaomi Smart TVs (Amlogic / Droidlogic Platform)
- **MiTV-AXSO2 (dangalUHD)** — *Primary reference device*:
  - Fully verified with Android TV 11 (API 30).
  - Mi/PatchWall button hardware remapped to Armaan tvOS Home.
  - HDMI 1, HDMI 2, HDMI 3, and AV inputs accessible via standalone inputs overlay.
  - Bluetooth remote input lag debounced via software filter.
- Xiaomi Mi Box 4K / Mi Box S (1st & 2nd Gen)
- Xiaomi TV Stick 4K

### 2. Google TV & Android TV Devices
- **Chromecast with Google TV (4K & HD)**
- **TCL Android / Google TV** (e.g. C-series, P-series on Android 11–14)
- **Philips Android TV & Ambilight TVs**
- **Sony Bravia 4K Android TV / Google TV**
- **NVIDIA Shield TV & Shield TV Pro** (Tegra X1+)
- **Amazon Fire TV Stick 4K / Max** (via FireOS sideload)
- **Onn Google TV 4K Streaming Box**

---

## Chipset Compatibility
- **Amlogic**: S905X, S905X2, S905X3, S905X4, S905Y4, T950X, T962X, T972, T982
- **MediaTek**: MT9611, MT9638, MT9675, MT9950, Pentonic 700 / 1000
- **Realtek**: RTD2871, RTD2984
- **Broadcom**: BCM7252S, BCM7271
- **Allwinner**: H6, H616, H618 (Android TV boxes and budget projectors)
