param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('patch', 'minor', 'major')]
    [string]$Level
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$versionPath = Join-Path $projectRoot 'VERSION'
$projectPath = Join-Path $projectRoot 'project.godot'
$current = [IO.File]::ReadAllText($versionPath).Trim()

if ($current -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "VERSION must contain semantic version X.Y.Z; found '$current'."
}

$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
switch ($Level) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
}
$next = "$major.$minor.$patch"

$utf8NoBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($versionPath, "$next`n", $utf8NoBom)
$projectText = [IO.File]::ReadAllText($projectPath)
$updatedProject = [regex]::Replace(
    $projectText,
    'config/version="\d+\.\d+\.\d+"',
    "config/version=`"$next`"",
    1
)
if ($updatedProject -eq $projectText) {
    throw 'Could not find application/config/version in project.godot.'
}
[IO.File]::WriteAllText($projectPath, $updatedProject, $utf8NoBom)
Write-Output $next
