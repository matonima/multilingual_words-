param(
    [string]$GodotExe = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$androidOutput = Join-Path $projectRoot 'exports\android\words-1.0.0-debug.apk'
$webOutput = Join-Path $projectRoot 'exports\web\index.html'

if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}

New-Item -ItemType Directory -Force (Split-Path $androidOutput) | Out-Null
New-Item -ItemType Directory -Force (Split-Path $webOutput) | Out-Null

& $GodotExe --headless --path $projectRoot --export-debug 'Android' $androidOutput
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $androidOutput)) {
    throw 'Android APK export failed.'
}

& $GodotExe --headless --path $projectRoot --export-release 'Web' $webOutput
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $webOutput)) {
    throw 'Web export failed.'
}

Write-Host "Android APK: $androidOutput"
Write-Host "Web folder:  $(Split-Path $webOutput)"
