$ErrorActionPreference = 'Stop'

$root = Resolve-Path "$PSScriptRoot\.."
$bundleRoot = Join-Path $root 'assets\bundles'

function Ensure-Dir($path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Download($url, $out) {
  Write-Host "Downloading $url"
  if (Test-Path $out) { Remove-Item $out -Force }
  $attempts = 0
  while ($attempts -lt 3) {
    $attempts++
    try {
      & curl.exe -L --fail --ssl-no-revoke -o $out $url
      if (Test-Path $out) { return }
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  throw "Failed to download $url after $attempts attempts."
}

function ZipSingle($src, $dest) {
  if (Test-Path $dest) { Remove-Item $dest -Force }
  Compress-Archive -Path $src -DestinationPath $dest
}

# Versions
$phpVersion = '8.5.1'
$pythonVersion = '3.14.3'
$nodeMajor = '25.x'
$nodeVersion = '25.6.1'
$mysqlVersion = '8.4.8'
$apacheVersion = '2.4.66'
$mailhogVersion = '1.0.1'
$smtpVersion = '1.28.2'
$wsVersion = '1.13.0'

# Create folders
$softwares = @('php','python','nodejs','mysql','apache','mailhog','smtp','websocket')
foreach ($s in $softwares) { Ensure-Dir (Join-Path $bundleRoot $s) }

# PHP
$phpWinUrl = "https://windows.php.net/downloads/releases/php-$phpVersion-Win32-vs17-x64.zip"
$phpWinOut = Join-Path $bundleRoot "php\$phpVersion-windows.zip"
if (-not (Test-Path $phpWinOut)) { Download $phpWinUrl $phpWinOut }

$phpLinuxUrl = "https://www.php.net/distributions/php-$phpVersion.tar.xz"
$phpLinuxOut = Join-Path $bundleRoot "php\$phpVersion-linux.tar.xz"
if (-not (Test-Path $phpLinuxOut)) { Download $phpLinuxUrl $phpLinuxOut }

# Python
$pyWinUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-embed-amd64.zip"
$pyWinOut = Join-Path $bundleRoot "python\$pythonVersion-windows.zip"
if (-not (Test-Path $pyWinOut)) { Download $pyWinUrl $pyWinOut }

$pyLinuxUrl = "https://www.python.org/ftp/python/$pythonVersion/Python-$pythonVersion.tgz"
$pyLinuxOut = Join-Path $bundleRoot "python\$pythonVersion-linux.tgz"
if (-not (Test-Path $pyLinuxOut)) { Download $pyLinuxUrl $pyLinuxOut }

# Node.js
$nodeWinUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-win-x64.zip"
$nodeWinOut = Join-Path $bundleRoot "nodejs\$nodeMajor-windows.zip"
if (-not (Test-Path $nodeWinOut)) { Download $nodeWinUrl $nodeWinOut }

$nodeLinuxUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-linux-x64.tar.xz"
$nodeLinuxOut = Join-Path $bundleRoot "nodejs\$nodeMajor-linux.tar.xz"
if (-not (Test-Path $nodeLinuxOut)) { Download $nodeLinuxUrl $nodeLinuxOut }

# MySQL
$mysqlWinUrl = "https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-$mysqlVersion-winx64.zip"
$mysqlWinOut = Join-Path $bundleRoot "mysql\$mysqlVersion-windows.zip"
if (-not (Test-Path $mysqlWinOut)) { Download $mysqlWinUrl $mysqlWinOut }

$mysqlLinuxUrl = "https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-$mysqlVersion-linux-glibc2.28-x86_64.tar.xz"
$mysqlLinuxOut = Join-Path $bundleRoot "mysql\$mysqlVersion-linux.tar.xz"
if (-not (Test-Path $mysqlLinuxOut)) { Download $mysqlLinuxUrl $mysqlLinuxOut }

# Apache
$apacheWinUrl = "https://www.apachelounge.com/download/VS18/binaries/httpd-2.4.66-260223-Win64-VS18.zip"
$apacheWinOut = Join-Path $bundleRoot "apache\$apacheVersion-windows.zip"
if (-not (Test-Path $apacheWinOut)) { Download $apacheWinUrl $apacheWinOut }

$apacheLinuxUrl = "https://downloads.apache.org/httpd/httpd-$apacheVersion.tar.gz"
$apacheLinuxOut = Join-Path $bundleRoot "apache\$apacheVersion-linux.tar.gz"
if (-not (Test-Path $apacheLinuxOut)) { Download $apacheLinuxUrl $apacheLinuxOut }

# Mailhog (zip the binaries)
$tempDir = Join-Path $env:TEMP "localx-bundles"
Ensure-Dir $tempDir

$mailhogWinExe = Join-Path $tempDir "MailHog_windows_amd64.exe"
if (-not (Test-Path $mailhogWinExe)) {
  Download "https://github.com/mailhog/MailHog/releases/download/v$mailhogVersion/MailHog_windows_amd64.exe" $mailhogWinExe
}
$mailhogWinOut = Join-Path $bundleRoot "mailhog\$mailhogVersion-windows.zip"
if (-not (Test-Path $mailhogWinOut)) { ZipSingle $mailhogWinExe $mailhogWinOut }

$mailhogLinuxBin = Join-Path $tempDir "MailHog_linux_amd64"
if (-not (Test-Path $mailhogLinuxBin)) {
  Download "https://github.com/mailhog/MailHog/releases/download/v$mailhogVersion/MailHog_linux_amd64" $mailhogLinuxBin
}
$mailhogLinuxOut = Join-Path $bundleRoot "mailhog\$mailhogVersion-linux.zip"
if (-not (Test-Path $mailhogLinuxOut)) { ZipSingle $mailhogLinuxBin $mailhogLinuxOut }

# SMTP (Mailpit)
$smtpWinUrl = "https://github.com/axllent/mailpit/releases/download/v$smtpVersion/mailpit-windows-amd64.zip"
$smtpWinOut = Join-Path $bundleRoot "smtp\$smtpVersion-windows.zip"
if (-not (Test-Path $smtpWinOut)) { Download $smtpWinUrl $smtpWinOut }

$smtpLinuxUrl = "https://github.com/axllent/mailpit/releases/download/v$smtpVersion/mailpit-linux-amd64.tar.gz"
$smtpLinuxOut = Join-Path $bundleRoot "smtp\$smtpVersion-linux.tar.gz"
if (-not (Test-Path $smtpLinuxOut)) { Download $smtpLinuxUrl $smtpLinuxOut }

# WebSocket (websocat)
$wsWinBin = Join-Path $tempDir "websocat.x86_64-pc-windows-gnu.exe"
if (-not (Test-Path $wsWinBin)) {
  Download "https://github.com/vi/websocat/releases/download/v$wsVersion/websocat.x86_64-pc-windows-gnu.exe" $wsWinBin
}
$wsWinOut = Join-Path $bundleRoot "websocket\$wsVersion-windows.zip"
if (-not (Test-Path $wsWinOut)) { ZipSingle $wsWinBin $wsWinOut }

$wsLinuxBin = Join-Path $tempDir "websocat.x86_64-unknown-linux-musl"
if (-not (Test-Path $wsLinuxBin)) {
  Download "https://github.com/vi/websocat/releases/download/v$wsVersion/websocat.x86_64-unknown-linux-musl" $wsLinuxBin
}
$wsLinuxOut = Join-Path $bundleRoot "websocket\$wsVersion-linux.zip"
if (-not (Test-Path $wsLinuxOut)) { ZipSingle $wsLinuxBin $wsLinuxOut }

& (Join-Path $root 'tools\build_bundle_manifest.ps1')
Write-Host "Bundle downloads complete."
