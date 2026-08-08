param(
    [string]$GodotExe = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe',
    [string]$SigningDirectory = 'D:\godot\private-keys\multilingualwords'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$version = [IO.File]::ReadAllText((Join-Path $projectRoot 'VERSION')).Trim()
$androidOutput = Join-Path $projectRoot "exports\android\words-$version-release.apk"
$webOutput = Join-Path $projectRoot 'exports\web\index.html'
$webZip = Join-Path $projectRoot "exports\words-web-$version.zip"
$keystorePath = Join-Path $SigningDirectory 'multilingualwords-release.keystore'
$credentialsPath = Join-Path $SigningDirectory 'release-credentials.txt'

if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}
if (-not (Test-Path -LiteralPath $keystorePath -PathType Leaf) -or -not (Test-Path -LiteralPath $credentialsPath -PathType Leaf)) {
    throw "Release signing files are missing from $SigningDirectory"
}

$credentials = @{}
Get-Content -LiteralPath $credentialsPath | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') { $credentials[$Matches[1].Trim()] = $Matches[2].Trim() }
}
if (-not $credentials.alias -or -not $credentials.password) {
    throw 'The private release credentials file is incomplete.'
}

New-Item -ItemType Directory -Force (Split-Path $androidOutput) | Out-Null
New-Item -ItemType Directory -Force (Split-Path $webOutput) | Out-Null

$previousKeystore = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH
$previousUser = $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER
$previousPassword = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
try {
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $keystorePath
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $credentials.alias
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $credentials.password
    & $GodotExe --headless --path $projectRoot --export-release 'Android' $androidOutput
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $androidOutput)) {
        throw 'Release-signed Android APK export failed.'
    }
} finally {
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $previousKeystore
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $previousUser
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $previousPassword
}

& $GodotExe --headless --path $projectRoot --export-release 'Web' $webOutput
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $webOutput)) {
    throw 'Web export failed.'
}

Compress-Archive -Path (Join-Path (Split-Path $webOutput) '*') -DestinationPath $webZip -CompressionLevel Optimal -Force
$checksums = @(
    "SHA256  $((Get-FileHash -Algorithm SHA256 -LiteralPath $androidOutput).Hash)  $(Split-Path $androidOutput -Leaf)",
    "SHA256  $((Get-FileHash -Algorithm SHA256 -LiteralPath $webZip).Hash)  $(Split-Path $webZip -Leaf)"
)
[IO.File]::WriteAllLines((Join-Path $projectRoot 'exports\SHA256SUMS.txt'), $checksums, [Text.UTF8Encoding]::new($false))

Write-Host "Release APK: $androidOutput"
Write-Host "Web ZIP:     $webZip"
Write-Host "Web folder:  $(Split-Path $webOutput)"
