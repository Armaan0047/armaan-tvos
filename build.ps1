param(
    [switch]$Release
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Test-ValidJdk($dir) {
    return ($dir -and (Test-Path "$dir\bin\java.exe") -and (Test-Path "$dir\bin\javac.exe"))
}

$foundJdk = $null
if (Test-ValidJdk $env:JAVA_HOME) {
    $foundJdk = $env:JAVA_HOME
} elseif (Test-ValidJdk $env:JDK_HOME) {
    $foundJdk = $env:JDK_HOME
} elseif (Test-ValidJdk "$env:USERPROFILE\.gemini\antigravity\scratch\jdk-17\jdk-17.0.21+9") {
    $foundJdk = "$env:USERPROFILE\.gemini\antigravity\scratch\jdk-17\jdk-17.0.21+9"
} elseif (Test-Path "$env:ProgramFiles\Java\jdk-*") {
    foreach ($cand in (Get-Item "$env:ProgramFiles\Java\jdk-*")) {
        if (Test-ValidJdk $cand.FullName) { $foundJdk = $cand.FullName; break }
    }
} elseif (Test-Path "$env:ProgramFiles\Microsoft\jdk-*") {
    foreach ($cand in (Get-Item "$env:ProgramFiles\Microsoft\jdk-*")) {
        if (Test-ValidJdk $cand.FullName) { $foundJdk = $cand.FullName; break }
    }
} elseif (Get-Command javac -ErrorAction SilentlyContinue) {
    $cand = Split-Path -Parent (Split-Path -Parent (Get-Command javac).Source)
    if (Test-ValidJdk $cand) { $foundJdk = $cand }
}

if ($foundJdk) {
    $env:JAVA_HOME = $foundJdk
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
} else {
    Write-Warning "Could not find full JDK 17+ home with bin\java.exe and bin\javac.exe. Ensure JAVA_HOME is set."
}

$SDK = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\Sdk" }
$BT = "$SDK\build-tools\34.0.0"
$JAR = "$SDK\platforms\android-34\android.jar"

if (Test-Path "build") { Get-ChildItem -Path "build" | Remove-Item -Recurse -Force }
New-Item -ItemType Directory -Force -Path "build\gen", "build\classes", "build\dex" | Out-Null

& "$BT\aapt2.exe" compile --dir res -o build\res.zip
if ($LASTEXITCODE -ne 0) { throw "aapt2 compile failed" }

& "$BT\aapt2.exe" link -o build\unsigned.apk -I "$JAR" --manifest AndroidManifest.xml `
    --java build\gen --min-sdk-version 24 --target-sdk-version 34 `
    --version-code 15 --version-name "2.1.5" build\res.zip
if ($LASTEXITCODE -ne 0) { throw "aapt2 link failed" }

$javaFiles = Get-ChildItem -Recurse -Path src, build\gen -Filter "*.java" | Select-Object -ExpandProperty FullName
$javaFiles | Out-File -Encoding ascii build\sources.txt
& javac -encoding UTF-8 --release 11 -classpath "$JAR" -d build\classes "@build\sources.txt"
if ($LASTEXITCODE -ne 0) { throw "javac failed" }

& jar cf build\classes.jar -C build\classes .
if ($LASTEXITCODE -ne 0) { throw "jar failed" }

& "$BT\d8.bat" --release --min-api 24 --lib "$JAR" --output build\dex build\classes.jar
if ($LASTEXITCODE -ne 0) { throw "d8 failed" }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open((Resolve-Path "build\unsigned.apk").Path, [System.IO.Compression.ZipArchiveMode]::Update)
try {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, (Resolve-Path "build\dex\classes.dex").Path, "classes.dex", [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null

    # Package assets with POSIX forward slashes (Windows aapt2 -A writes backslashes which Android AssetManager cannot open)
    $assetsRoot = (Resolve-Path "assets").Path
    $noCompressExts = @(".jpg", ".jpeg", ".png", ".webp", ".gif", ".mp3", ".wav", ".ogg", ".mp4", ".webm")
    Get-ChildItem -Recurse -File -Path $assetsRoot | ForEach-Object {
        $rel = $_.FullName.Substring($assetsRoot.Length + 1).Replace('\', '/')
        $entryName = "assets/$rel"
        $existing = $archive.GetEntry($entryName)
        if ($existing) { $existing.Delete() }
        $ext = $_.Extension.ToLowerInvariant()
        $level = if ($noCompressExts -contains $ext) {
            [System.IO.Compression.CompressionLevel]::NoCompression
        } else {
            [System.IO.Compression.CompressionLevel]::Optimal
        }
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $entryName, $level) | Out-Null
    }
} finally {
    $archive.Dispose()
}

& "$BT\zipalign.exe" -f 4 build\unsigned.apk build\aligned.apk
if ($LASTEXITCODE -ne 0) { throw "zipalign failed" }

if ($Release) {
    $KS = "release.keystore"
    $pass = if ($env:RELEASE_KEYSTORE_PASS) { $env:RELEASE_KEYSTORE_PASS } else { "armaan-tvos-2026" }
    $alias = if ($env:RELEASE_KEY_ALIAS) { $env:RELEASE_KEY_ALIAS } else { "armaan-tvos" }
    if (-not (Test-Path $KS)) {
        & keytool -genkeypair -keystore $KS -storepass $pass -keypass $pass -alias $alias `
            -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Armaan tvOS, O=Armaan, C=IN" | Out-Null
    }
    & "$BT\apksigner.bat" sign --ks $KS --ks-pass "pass:$pass" --key-pass "pass:$pass" --ks-key-alias $alias `
        --out build\armaan-tvos-release.apk build\aligned.apk
    if ($LASTEXITCODE -ne 0) { throw "apksigner failed" }
    Copy-Item -Force build\armaan-tvos-release.apk build\armaan-tvos.apk
    Copy-Item -Force build\armaan-tvos-release.apk build\tvos-home.apk
    Write-Host "Built production release APK: build\armaan-tvos-release.apk"
} else {
    $KS = "debug.keystore"
    if (-not (Test-Path $KS)) {
        & keytool -genkeypair -keystore $KS -storepass android -keypass android -alias debug `
            -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Armaan tvOS debug" | Out-Null
    }
    & "$BT\apksigner.bat" sign --ks $KS --ks-pass pass:android --key-pass pass:android `
        --out build\armaan-tvos.apk build\aligned.apk
    if ($LASTEXITCODE -ne 0) { throw "apksigner failed" }
    Copy-Item -Force build\armaan-tvos.apk build\tvos-home.apk
    Write-Host "Built development APK: build\armaan-tvos.apk"
}
