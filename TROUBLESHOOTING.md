# Troubleshooting Guide — Armaan tvOS

### 1. Unknown or Assembled TV: Home Button Doesn't Open Armaan tvOS
**Cause**:
Some assembled or white-label televisions (e.g. Amlogic reference boards, MStar boards, or custom Android TV ROMs) do not support the modern `cmd package set-home-activity` shell command, or use a hardcoded factory system setting.

**Solution**:
1. Open your TV's **System Settings** using your physical remote.
2. Navigate to **Apps** → **Special app access** → **Default apps** → **Home app**.
3. Select **Armaan tvOS** manually.
4. If your ROM lacks this menu:
   - Open **Armaan tvOS** → `Settings` → `Button Mapper`.
   - Turn **ON** **"Fix Home button (Launch Armaan tvOS)"**.
   - Enable the **Accessibility Service** when prompted. This intercepts the physical remote's Home keycode (`KEYCODE_HOME`) and forces Armaan tvOS to open.

---

### 2. Xiaomi TVs: The Mi / PatchWall Button Switches to HDMI 3
**Cause**:
On Xiaomi smart TVs (such as the MiTV-AXSO2), pressing the Mi button triggers `KEYCODE_BUTTON_5` (192) or `KEYCODE_PROG_RED` (183). If PatchWall is debloated or inactive, the Xiaomi system receiver `GlobalKeyReceiver` falls back into `startLiveTV()`, which forcibly switches to HDMI 3.

**Solution**:
*(Only applicable to verified Xiaomi televisions; do NOT run on other brands)*:
1. Open **Armaan tvOS** → `Settings` → `Button Mapper`.
2. Ensure **"Fix Mi / PatchWall Button (Launch Armaan tvOS)"** is toggled **ON**.
3. Ensure the **Accessibility Service** is enabled.
4. Disable the Xiaomi vendor fallback package via the installer (Mode C) or via ADB:
   ```bash
   adb shell pm disable-user --user 0 com.xiaomi.android.tvsetup.partnercustomizer
   ```

---

### 3. Remote Control Lag, Double-Clicks, or Stuck Navigation
**Cause**:
Budget Android TV Bluetooth remotes frequently send rapid bursts of duplicate key packets when experiencing 2.4 GHz RF interference or low battery voltage.

**Solution**:
1. Armaan tvOS includes a built-in **D-Pad Burst Debouncer** that filters out repeated D-pad down packets arriving under <65 ms intervals.
2. Replace the batteries in your remote control.
3. Unpair and re-pair your remote in TV **Settings** → **Remotes & Accessories**.

---

### 4. ADB Connection Error: "device offline" or "unauthorized"
**Cause**:
The TV has not authorized your computer's ADB cryptographic RSA key.

**Solution**:
1. Disconnect and reconnect ADB:
   ```bash
   adb disconnect
   adb connect <YOUR_TV_IP>:5555
   ```
2. Turn on your television screen. A prompt will appear: **"Allow USB debugging?"**.
3. Check the box **"Always allow from this computer"** and click **OK**.
4. Run `adb devices` to verify the state shows `device` (not `unauthorized` or `offline`).

---

### 5. Installation Fails with `INSTALL_FAILED_INSUFFICIENT_STORAGE`
**Cause**:
Android TV requires at least 30–50 MB of free internal flash storage to unpack and optimize APK bytecode.

**Solution**:
1. Check available storage:
   ```bash
   adb shell df -h /data
   ```
2. Go to TV **Settings** → **Apps** → select cached apps (e.g. YouTube, Netflix) and click **Clear cache**.
3. Run the installer again.

---

### 6. Switching HDMI Inputs with Stock Launcher Disabled
**Solution**:
Armaan tvOS includes a built-in, standalone TV Inputs overlay:
1. Open the **Control Center** (or map any remote button to **Inputs Overlay**).
2. Click **Inputs**.
3. The glass overlay will display all physical ports (**HDMI 1, HDMI 2, HDMI 3, AV**) with live signal detection.

---

### 7. Windows CMD Installer Error: `'Safe' is not recognized` or `was unexpected at this time`
**Cause**:
Older batch scripts contained unquoted command chaining characters (`&`) or multi-byte UTF-8 characters paired with Unix LF line breaks, which causes the legacy Windows `cmd.exe` parser to miscalculate character offsets.

**Solution**:
This has been permanently fixed in the latest repository release.
The Windows batch scripts (`scripts/install.bat` and `scripts/restore.bat`) now feature:
1. Pure ASCII character encoding with strict Windows CRLF (`\r\n`) line endings.
2. Safe command separation without unescaped `&` operators.
3. Linear ADB binary discovery (`goto :FoundAdb`) avoiding premature closing parentheses from `(x86)` path expansions.
4. Full support for folder paths containing spaces and modern Windows 10 & 11 terminals.
Simply pull the latest repository updates or download the newest release zip.
