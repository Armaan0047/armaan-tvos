# Troubleshooting Guide — Armaan tvOS

### 1. The Mi / PatchWall Button Switches to HDMI 3
**Cause**:
On Xiaomi televisions (such as the MiTV-AXSO2), pressing the Mi button triggers `KEYCODE_BUTTON_5` (192) or `KEYCODE_PROG_RED` (183). When PatchWall is debloated, the Xiaomi system service `GlobalKeyReceiver` falls back to `startLiveTV()`, which forcibly switches to HDMI 3.

**Solution**:
1. Open **Armaan tvOS** → `Settings` → `Button Mapper`.
2. Ensure **"Fix Mi / PatchWall Button (Launch Armaan tvOS)"** is toggled **ON**.
3. Ensure the **Accessibility Service** is enabled in `Settings` → `Button Mapper`.
4. Run this one-line ADB command to disable the vendor fallback trigger:
   ```bash
   adb shell pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer
   ```

---

### 2. Remote Input Lag & Repeated / Stuck Navigation Taps
**Cause**:
Budget Android TV Bluetooth remotes often buffer and burst repeated key packets when the 2.4 GHz RF link experiences interference or low battery voltage.

**Solution**:
1. Armaan tvOS includes a built-in **D-Pad Burst Debouncer** that ignores repeated D-pad down packets arriving within <65 ms intervals, preventing unwanted double-hops or runaway scrolling.
2. Replace the batteries in your remote control.
3. Unpair and re-pair the remote in your TV's Bluetooth settings:
   - Go to Android TV `Settings` → `Remotes & Accessories`.
   - Select your remote, choose **Unpair**, then hold the pairing buttons to pair afresh.

---

### 3. Recent Apps Switcher Doesn't Open on Home Long-Press
**Cause**:
The Accessibility Service is required to intercept and time the hardware Home button keycode (500 ms threshold).

**Solution**:
1. Go to `Settings` → `Device Preferences` → `Accessibility`.
2. Look for **Armaan tvOS – Button Mapper & Control Panel** and make sure it is turned **ON**.
3. In Armaan tvOS settings, ensure **"Home Button Long Press → Recent Apps"** is toggled **ON**.

---

### 4. TV Automatically Reverts to Stock Launcher After Reboot
**Cause**:
Some manufacturers (such as TCL, Xiaomi, or Philips) attempt to re-assert their stock launcher package during bootup.

**Solution**:
Set the default launcher using Android's system-level package command:
```bash
adb shell cmd package set-home-activity com.techgenius.tvoslauncher/.MainActivity
```
If your TV continues to override this, enable **"Fix Home button (Launch Armaan tvOS)"** in `Settings` → `Button Mapper`. This intercepts the hardware Home button at the accessibility level and redirects it directly to Armaan tvOS.

---

### 5. Switching HDMI Inputs with Stock Launcher Disabled
**Solution**:
You do **not** need the stock launcher to switch HDMI ports:
1. Open the **Control Center** (or map a button to **Inputs Overlay**).
2. Select **Inputs**.
3. The native TV Inputs overlay appears immediately, showing HDMI 1, HDMI 2, HDMI 3, and AV with live connection status.
