param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('patch', 'minor', 'major')]
    [string]$Level,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Message,

    [string]$GodotExe = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $projectRoot
try {
    if (-not (Test-Path '.git')) { throw 'This folder is not a Git repository. Run Git: Configure origin first.' }
    if (-not (& git config user.name)) { throw 'Set Git user.name before releasing.' }
    if (-not (& git config user.email)) { throw 'Set Git user.email before releasing.' }
    if (-not (& git remote get-url origin 2>$null)) { throw 'Configure the origin remote before releasing.' }
    $branch = (& git branch --show-current).Trim()
    if (-not $branch) { throw 'Check out a branch before releasing.' }

    & (Join-Path $PSScriptRoot 'verify.ps1') -GodotExe $GodotExe
    $next = (& (Join-Path $PSScriptRoot 'bump_version.ps1') -Level $Level).Trim()
    if (& git tag --list "v$next") { throw "Tag v$next already exists." }

    $changelogPath = Join-Path $projectRoot 'CHANGELOG.md'
    $changelog = [IO.File]::ReadAllText($changelogPath)
    $date = Get-Date -Format 'yyyy-MM-dd'
    $releaseEntry = "## [$next] - $date`r`n`r`n- $Message`r`n`r`n"
    $updated = $changelog -replace '(## \[Unreleased\]\r?\n\r?\n)', "`$1$releaseEntry"
    [IO.File]::WriteAllText($changelogPath, $updated, [Text.UTF8Encoding]::new($false))

    & git add -A
    if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }
    & git commit -m "Release v$next - $Message"
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
    & git tag -a "v$next" -m "Words v$next"
    if ($LASTEXITCODE -ne 0) { throw 'git tag failed.' }
    & git push origin $branch
    if ($LASTEXITCODE -ne 0) { throw 'Branch push failed; the commit and tag remain local.' }
    & git push origin "v$next"
    if ($LASTEXITCODE -ne 0) { throw 'Tag push failed; retry with git push origin --tags.' }
    Write-Host "Released and pushed Words v$next."
} finally {
    Pop-Location
}
