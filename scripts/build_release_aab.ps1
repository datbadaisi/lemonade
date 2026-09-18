# Build a signed Play App Bundle (release).
# Requires android/key.properties OR BLUERUM_KEYSTORE_* env vars.
#
# Usage (from repo root):
#   powershell -ExecutionPolicy Bypass -File scripts/build_release_aab.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$keyProps = Join-Path $root "android\key.properties"
$hasEnv = @(
    $env:BLUERUM_KEYSTORE_PATH,
    $env:BLUERUM_KEYSTORE_PASSWORD,
    $env:BLUERUM_KEY_ALIAS,
    $env:BLUERUM_KEY_PASSWORD
) | Where-Object { -not [string]::IsNullOrEmpty($_) }

if (-not (Test-Path $keyProps) -and $hasEnv.Count -lt 4) {
    Write-Host @"
Missing release signing config.

Option A — local file (recommended):
  1. Copy android\key.properties.example → android\key.properties
  2. Fill storePassword, keyAlias, keyPassword
  3. Re-run this script

Option B — environment variables:
  BLUERUM_KEYSTORE_PATH
  BLUERUM_KEYSTORE_PASSWORD
  BLUERUM_KEY_ALIAS
  BLUERUM_KEY_PASSWORD

Keystore expected at: android\upload-keystore.jks
"@
    exit 1
}

Write-Host "Building release AAB..."
$configFile = Join-Path $root "config.json"
if (Test-Path $configFile) {
    flutter build appbundle --release --dart-define-from-file=config.json
} else {
    flutter build appbundle --release
}
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$aab = Join-Path $root "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $aab) {
    Write-Host ""
    Write-Host "OK: $aab"
    Get-Item $aab | Format-List FullName, Length, LastWriteTime
} else {
    Write-Host "Build finished but AAB not found at expected path."
    exit 1
}
