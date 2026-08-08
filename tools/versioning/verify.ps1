param(
    [string]$GodotExe = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}
$previousAppData = $env:APPDATA
$env:APPDATA = Join-Path $projectRoot '.godot_appdata'
try {
    & $GodotExe --headless --editor --path $projectRoot --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
    & $GodotExe --headless --path $projectRoot --script 'res://tests/smoke_test.gd'
    if ($LASTEXITCODE -ne 0) { throw 'Godot smoke test failed.' }
} finally {
    $env:APPDATA = $previousAppData
}
