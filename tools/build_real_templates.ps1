# LocalX real offline templates builder
# Requires Node.js/npm/npx, Composer, and optional Python tools.
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root 'assets\templates'
$src = Join-Path $root 'tools\templates_src'
New-Item -ItemType Directory -Force -Path $assets | Out-Null
New-Item -ItemType Directory -Force -Path $src | Out-Null

function Zip-Folder($folder, $dest) {
  if (-not (Test-Path $folder)) { return }
  if (Test-Path $dest) { Remove-Item $dest -Force }
  Compress-Archive -Path (Join-Path $folder '*') -DestinationPath $dest -Force
}

function Reset-Dir($dir) {
  if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

function Has-Cmd($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# Laravel
if (Has-Cmd 'composer') {
  $dir = Join-Path $src 'laravel'
  Reset-Dir $dir
  composer create-project laravel/laravel $dir --no-interaction --prefer-dist
  Zip-Folder $dir (Join-Path $assets 'laravel.zip')
}

# React
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'react'
  Reset-Dir $dir
  npx -y create-react-app $dir
  Zip-Folder $dir (Join-Path $assets 'react.zip')
}

# Vue
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'vue'
  Reset-Dir $dir
  npx -y create-vue@latest $dir --default
  Zip-Folder $dir (Join-Path $assets 'vue.zip')
}

# Next.js
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'next'
  Reset-Dir $dir
  npx -y create-next-app@latest $dir --yes
  Zip-Folder $dir (Join-Path $assets 'next.zip')
}

# Svelte
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'svelte'
  Reset-Dir $dir
  npx -y create-svelte@latest $dir
  Zip-Folder $dir (Join-Path $assets 'svelte.zip')
}

# Angular
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'angular'
  Reset-Dir $dir
  npx -y @angular/cli@latest new localx-angular --directory $dir --defaults --skip-git --skip-install
  Zip-Folder $dir (Join-Path $assets 'angular.zip')
}

# Nuxt
if (Has-Cmd 'npx') {
  $dir = Join-Path $src 'nuxt'
  Reset-Dir $dir
  npx -y nuxi@latest init $dir
  Zip-Folder $dir (Join-Path $assets 'nuxt.zip')
}

# Node.js
if (Has-Cmd 'npm') {
  $dir = Join-Path $src 'node'
  Reset-Dir $dir
  Push-Location $dir
  npm init -y
  Pop-Location
  Zip-Folder $dir (Join-Path $assets 'node.zip')
}

# Plain PHP
$phpDir = Join-Path $src 'php'
Reset-Dir $phpDir
Set-Content -Encoding UTF8 (Join-Path $phpDir 'index.php') "<?php`n`necho 'Hello LocalX!';`n"
Zip-Folder $phpDir (Join-Path $assets 'php.zip')

# FastAPI
$fastapiDir = Join-Path $src 'fastapi'
Reset-Dir $fastapiDir
Set-Content -Encoding UTF8 (Join-Path $fastapiDir 'main.py') "from fastapi import FastAPI`n`napp = FastAPI()`n`n@app.get('/')`ndef read_root():`n    return {'status': 'ok', 'message': 'Hello LocalX'}`n"
Set-Content -Encoding UTF8 (Join-Path $fastapiDir 'requirements.txt') "fastapi`nuvicorn`n"
Zip-Folder $fastapiDir (Join-Path $assets 'fastapi.zip')

# Django
$djangoDir = Join-Path $src 'django'
Reset-Dir $djangoDir
if (Has-Cmd 'django-admin') {
  django-admin startproject app $djangoDir
} else {
  Set-Content -Encoding UTF8 (Join-Path $djangoDir 'manage.py') "#!/usr/bin/env python`nprint('Install django to generate full scaffold')`n"
}
Zip-Folder $djangoDir (Join-Path $assets 'django.zip')

# WordPress
$wpDir = Join-Path $src 'wordpress'
Reset-Dir $wpDir
$tempZip = Join-Path $env:TEMP 'localx-wordpress.zip'
 $tempExtract = Join-Path $env:TEMP 'localx-wordpress-extract'
if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
Invoke-WebRequest -UseBasicParsing -Uri 'https://wordpress.org/latest.zip' -OutFile $tempZip
Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
if (Test-Path (Join-Path $tempExtract 'wordpress')) {
  Copy-Item (Join-Path $tempExtract 'wordpress\*') $wpDir -Recurse -Force
}
Zip-Folder $wpDir (Join-Path $assets 'wordpress.zip')

Write-Host "Templates built in $assets"
