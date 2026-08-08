param(
    [Parameter(Mandatory = $true)]
    [string]$RemoteUrl
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $projectRoot
try {
    if (-not (Test-Path (Join-Path $projectRoot '.git'))) {
        & git init -b main
        if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
    }
    $origin = & git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and $origin) {
        & git remote set-url origin $RemoteUrl
    } else {
        & git remote add origin $RemoteUrl
    }
    if ($LASTEXITCODE -ne 0) { throw 'Could not configure the origin remote.' }
    Write-Host "origin -> $RemoteUrl"
    Write-Host 'Git remote configured. Create the initial commit, then push with: git push -u origin main'
} finally {
    Pop-Location
}
