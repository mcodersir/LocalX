$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$frameworkDir = Join-Path $root "assets\brands\frameworks"
$serviceDir = Join-Path $root "assets\brands\services"

New-Item -ItemType Directory -Force -Path $frameworkDir | Out-Null
New-Item -ItemType Directory -Force -Path $serviceDir | Out-Null

function Download-Icon($slug, $hexColor, $destination, $required = $true) {
  $url = "https://cdn.simpleicons.org/$slug/$hexColor"
  try {
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $destination
    Write-Host "ok: $destination"
  } catch {
    if ($required) {
      throw "Failed to download required icon '$slug' from $url"
    }
    Write-Warning "optional icon not found for '$slug' ($destination)"
  }
}

$frameworks = @(
  @{ Name = "laravel.svg"; Slug = "laravel"; Color = "FF2D20" },
  @{ Name = "react.svg"; Slug = "react"; Color = "61DAFB" },
  @{ Name = "vue.svg"; Slug = "vuedotjs"; Color = "4FC08D" },
  @{ Name = "nextjs.svg"; Slug = "nextdotjs"; Color = "FFFFFF" },
  @{ Name = "svelte.svg"; Slug = "svelte"; Color = "FF3E00" },
  @{ Name = "angular.svg"; Slug = "angular"; Color = "DD0031" },
  @{ Name = "nuxt.svg"; Slug = "nuxt"; Color = "00DC82" },
  @{ Name = "nodejs.svg"; Slug = "nodedotjs"; Color = "339933" },
  @{ Name = "php.svg"; Slug = "php"; Color = "777BB4" },
  @{ Name = "fastapi.svg"; Slug = "fastapi"; Color = "009688" },
  @{ Name = "django.svg"; Slug = "django"; Color = "092E20" },
  @{ Name = "wordpress.svg"; Slug = "wordpress"; Color = "21759B" }
)

$services = @(
  @{ Name = "apache.svg"; Slug = "apache"; Color = "D22128"; Required = $true },
  @{ Name = "mysql.svg"; Slug = "mysql"; Color = "00758F"; Required = $true },
  @{ Name = "php.svg"; Slug = "php"; Color = "777BB4"; Required = $true },
  @{ Name = "python.svg"; Slug = "python"; Color = "3776AB"; Required = $true },
  @{ Name = "redis.svg"; Slug = "redis"; Color = "DC382D"; Required = $true },
  @{ Name = "nodejs.svg"; Slug = "nodedotjs"; Color = "339933"; Required = $true },
  @{ Name = "postgresql.svg"; Slug = "postgresql"; Color = "336791"; Required = $true },
  @{ Name = "memcached.svg"; Slug = "memcached"; Color = "51B24B"; Required = $false },
  @{ Name = "mailhog.svg"; Slug = "mailhog"; Color = "E83D31"; Required = $false },
  @{ Name = "smtp.svg"; Slug = "mailpit"; Color = "7C3AED"; Required = $false },
  @{ Name = "websocket.svg"; Slug = "socketdotio"; Color = "10B981"; Required = $false }
)

foreach ($icon in $frameworks) {
  $dest = Join-Path $frameworkDir $icon.Name
  Download-Icon $icon.Slug $icon.Color $dest $true
}

foreach ($icon in $services) {
  $dest = Join-Path $serviceDir $icon.Name
  Download-Icon $icon.Slug $icon.Color $dest $icon.Required
}

Write-Host "brand icon download complete."
