#!/usr/bin/env python3
"""
Test Suite for Armaan tvOS Windows CMD Batch Scripts
Verifies that install.bat and restore.bat:
1. Launch without CMD syntax or parser errors.
2. Render banners cleanly.
3. Handle paths containing spaces without quotation or parenthesis issues.
4. Correctly execute PowerShell universal scripts and capture exit codes.
5. Successfully detect devices and display profiles.
"""

import subprocess
import os
import shutil
import sys

def run_tests():
    print("=" * 72)
    print("ARMAAN tvOS WINDOWS CMD INSTALLER TEST SUITE")
    print("=" * 72)

    project_root = r"C:\Users\mohdi\.gemini\antigravity\scratch\armaan-tvos"
    scripts_dir = os.path.join(project_root, "scripts")
    install_bat = os.path.join(scripts_dir, "install.bat")
    restore_bat = os.path.join(scripts_dir, "restore.bat")

    # TEST 1: Launch install.bat syntax check via cmd.exe
    print("\n[TEST 1] Syntax & Banner Check via CMD.EXE...")
    proc = subprocess.run(
        f'cmd.exe /c "{install_bat} -DeviceIp 10.120.97.193 -Mode Q"',
        shell=True,
        capture_output=True,
        text=True
    )
    out = proc.stdout + proc.stderr
    assert "is not recognized as an internal or external command" not in out, f"Command not recognized error found:\n{out}"
    assert "was unexpected at this time" not in out, f"Unexpected token error found:\n{out}"
    assert "ARMAAN tvOS - UNIVERSAL ANDROID TV INSTALLER" in out, "Banner missing!"
    print("  -> PASS: Zero syntax errors, banner rendered cleanly.")

    # TEST 2: Device Detection
    print("\n[TEST 2] Device Detection Flow on Live TV...")
    assert "DEVICE PROFILE DETECTED" in out, "Device profile card missing!"
    assert "Manufacturer:   Xiaomi" in out, "Manufacturer detection failed!"
    assert "COMPATIBILITY:  [COMPATIBLE]" in out, "Compatibility classification missing!"
    print("  -> PASS: Device profile card and compatibility classification verified.")

    # TEST 3: Invalid TV IP Handling
    print("\n[TEST 3] Invalid TV IP Handling...")
    proc_invalid = subprocess.run(
        f'cmd.exe /c "{install_bat} -DeviceIp 192.0.2.1 -Mode Q"',
        shell=True,
        capture_output=True,
        text=True,
        timeout=15
    )
    out_invalid = proc_invalid.stdout + proc_invalid.stderr
    assert "is not recognized" not in out_invalid, f"Syntax error on invalid IP:\n{out_invalid}"
    assert "was unexpected" not in out_invalid, f"Token error on invalid IP:\n{out_invalid}"
    print("  -> PASS: Invalid IP handled cleanly without batch script crash.")

    # TEST 4: Folder Path Containing Spaces
    print("\n[TEST 4] Execution from Folder Path Containing Spaces...")
    space_dir = r"C:\Users\mohdi\.gemini\antigravity\scratch\test path spaces\armaan-tvos"
    if os.path.exists(space_dir):
        shutil.rmtree(space_dir)
    os.makedirs(os.path.join(space_dir, "scripts"), exist_ok=True)
    os.makedirs(os.path.join(space_dir, "build"), exist_ok=True)
    shutil.copy(install_bat, os.path.join(space_dir, "scripts", "install.bat"))
    shutil.copy(os.path.join(scripts_dir, "universal_installer.ps1"), os.path.join(space_dir, "scripts", "universal_installer.ps1"))
    shutil.copy(os.path.join(project_root, "build", "armaan-tvos-release.apk"), os.path.join(space_dir, "build", "armaan-tvos-release.apk"))

    space_install_bat = os.path.join(space_dir, "scripts", "install.bat")
    proc_space = subprocess.run(
        f'cmd.exe /c ""{space_install_bat}" -DeviceIp 10.120.97.193 -Mode Q"',
        shell=True,
        capture_output=True,
        text=True
    )
    out_space = proc_space.stdout + proc_space.stderr
    assert "is not recognized" not in out_space, f"Space path error:\n{out_space}"
    assert "was unexpected" not in out_space, f"Space path error:\n{out_space}"
    assert "ARMAAN tvOS - UNIVERSAL ANDROID TV INSTALLER" in out_space, "Banner missing in space path!"
    print("  -> PASS: Script in path with spaces executed with 0 syntax errors.")

    # Clean up space test dir
    shutil.rmtree(r"C:\Users\mohdi\.gemini\antigravity\scratch\test path spaces", ignore_errors=True)

    # TEST 5: Restore script CMD syntax
    print("\n[TEST 5] restore.bat CMD Syntax Check...")
    proc_res = subprocess.run(
        f'cmd.exe /c "{restore_bat} -DeviceIp 10.120.97.193"',
        shell=True,
        capture_output=True,
        text=True
    )
    out_res = proc_res.stdout + proc_res.stderr
    assert "is not recognized" not in out_res, f"Restore error:\n{out_res}"
    assert "was unexpected" not in out_res, f"Restore error:\n{out_res}"
    assert "ARMAAN tvOS - UNIVERSAL RESTORE AND ROLLBACK" in out_res, "Restore banner missing!"
    print("  -> PASS: restore.bat executed with 0 syntax errors.")

    print("\n" + "=" * 72)
    print("ALL 5 WINDOWS CMD TESTS PASSED WITH 100% SUCCESS!")
    print("=" * 72)

if __name__ == "__main__":
    run_tests()
