$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$bundleRoot = Join-Path $root "assets\bundles"
$manifestPath = Join-Path $bundleRoot "manifest.json"

$entries = @(
  @{ software = "php"; version = "8.5.1"; platform = "windows"; archive = "php/8.5.1-windows.zip"; sourceUrl = "https://windows.php.net/downloads/releases/php-8.5.1-Win32-vs17-x64.zip"; installMode = "archive" },
  @{ software = "php"; version = "8.5.1"; platform = "linux"; archive = "php/8.5.1-linux.tar.xz"; sourceUrl = "https://www.php.net/distributions/php-8.5.1.tar.xz"; installMode = "archive" },
  @{ software = "python"; version = "3.14.3"; platform = "windows"; archive = "python/3.14.3-windows.zip"; sourceUrl = "https://www.python.org/ftp/python/3.14.3/python-3.14.3-embed-amd64.zip"; installMode = "archive" },
  @{ software = "python"; version = "3.14.3"; platform = "linux"; archive = "python/3.14.3-linux.tgz"; sourceUrl = "https://www.python.org/ftp/python/3.14.3/Python-3.14.3.tgz"; installMode = "archive" },
  @{ software = "nodejs"; version = "25.x"; platform = "windows"; archive = "nodejs/25.x-windows.zip"; sourceUrl = "https://nodejs.org/dist/v25.6.1/node-v25.6.1-win-x64.zip"; installMode = "archive" },
  @{ software = "nodejs"; version = "25.x"; platform = "linux"; archive = "nodejs/25.x-linux.tar.xz"; sourceUrl = "https://nodejs.org/dist/v25.6.1/node-v25.6.1-linux-x64.tar.xz"; installMode = "archive" },
  @{ software = "mysql"; version = "8.4.8"; platform = "windows"; archive = "mysql/8.4.8-windows.zip"; sourceUrl = "https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-8.4.8-winx64.zip"; installMode = "archive" },
  @{ software = "mysql"; version = "8.4.8"; platform = "linux"; archive = "mysql/8.4.8-linux.tar.xz"; sourceUrl = "https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-8.4.8-linux-glibc2.28-x86_64.tar.xz"; installMode = "archive" },
  @{ software = "apache"; version = "2.4.66"; platform = "windows"; archive = "apache/2.4.66-windows.zip"; sourceUrl = "https://www.apachelounge.com/download/VS18/binaries/httpd-2.4.66-260223-Win64-VS18.zip"; installMode = "archive" },
  @{ software = "apache"; version = "2.4.66"; platform = "linux"; archive = "apache/2.4.66-linux.tar.gz"; sourceUrl = "https://downloads.apache.org/httpd/httpd-2.4.66.tar.gz"; installMode = "archive" },
  @{ software = "mailhog"; version = "1.0.1"; platform = "windows"; archive = "mailhog/1.0.1-windows.zip"; sourceUrl = "https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_windows_amd64.exe"; installMode = "archive" },
  @{ software = "mailhog"; version = "1.0.1"; platform = "linux"; archive = "mailhog/1.0.1-linux.zip"; sourceUrl = "https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64"; installMode = "archive" },
  @{ software = "smtp"; version = "1.28.2"; platform = "windows"; archive = "smtp/1.28.2-windows.zip"; sourceUrl = "https://github.com/axllent/mailpit/releases/download/v1.28.2/mailpit-windows-amd64.zip"; installMode = "archive" },
  @{ software = "smtp"; version = "1.28.2"; platform = "linux"; archive = "smtp/1.28.2-linux.tar.gz"; sourceUrl = "https://github.com/axllent/mailpit/releases/download/v1.28.2/mailpit-linux-amd64.tar.gz"; installMode = "archive" },
  @{ software = "websocket"; version = "1.13.0"; platform = "windows"; archive = "websocket/1.13.0-windows.zip"; sourceUrl = "https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-pc-windows-gnu.exe"; installMode = "archive" },
  @{ software = "websocket"; version = "1.13.0"; platform = "linux"; archive = "websocket/1.13.0-linux.zip"; sourceUrl = "https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-unknown-linux-musl"; installMode = "archive" }
)

$finalEntries = @()
foreach ($entry in $entries) {
  $fullPath = Join-Path $bundleRoot $entry.archive
  if (-not (Test-Path $fullPath)) {
    throw "Bundle file not found: $fullPath"
  }
  $hash = (Get-FileHash -Path $fullPath -Algorithm SHA256).Hash.ToLower()
  $finalEntries += [ordered]@{
    software = $entry.software
    version = $entry.version
    platform = $entry.platform
    archive = $entry.archive
    sha256 = $hash
    sourceUrl = $entry.sourceUrl
    installMode = $entry.installMode
  }
}

$manifest = [ordered]@{
  schemaVersion = 1
  generatedAt = (Get-Date).ToUniversalTime().ToString("o")
  entries = $finalEntries
}

$manifest | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $manifestPath
Write-Host "Manifest written to $manifestPath"
