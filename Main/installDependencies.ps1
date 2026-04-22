param(
    [string]$SearchRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$NugetDirectory = (Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local\vvvv\gamma\nugets"),
    [string]$NugetPath = "",
    [string[]]$Sources = @(
        "https://teamcity.vvvv.org/guestAuth/app/nuget/v1/FeedService.svc/",
        "https://api.nuget.org/v3/index.json"
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Define the list of locations to ignore
$ignoreList = @(
    "SharpDX.Mathematics",
    "SharpDX.XInput",
    "VL.Audio",
    "VL.Core",
    "VL.CoreLib",
    "VL.CoreLib.VVVV",
    "VL.CoreLib.Windows",
    "VL.EditingFramework",
    "VL.IO.ArtNet",
    "VL.IO.Midi",
    "VL.IO.OSC",
    "VL.NewAudio",
    "VL.OpenCV",
    "VL.Skia",
    "VL.Stride",
    "VL.Stride.Windows",
    "VL.Video.MediaFoundation"
)

function Get-VvvvNugetPath {
    param([string]$PreferredPath)

    if (-not [string]::IsNullOrWhiteSpace($PreferredPath) -and (Test-Path -LiteralPath $PreferredPath)) {
        return (Resolve-Path -LiteralPath $PreferredPath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($env:VVVV_NUGET_PATH) -and (Test-Path -LiteralPath $env:VVVV_NUGET_PATH)) {
        return (Resolve-Path -LiteralPath $env:VVVV_NUGET_PATH).Path
    }

    $candidates = @()
    foreach ($root in @('C:\Program Files\vvvv', 'C:\Program Files (x86)\vvvv')) {
        if (Test-Path -LiteralPath $root) {
            $candidates += Get-ChildItem -LiteralPath $root -Filter NuGet.exe -File -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -match '\\tools\\NuGet\.exe$' }
        }
    }

    $best = $candidates |
        Sort-Object -Property LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if ($best) {
        return $best.FullName
    }

    throw "NuGet executable not found. Set -NugetPath or VVVV_NUGET_PATH."
}

# Function to parse and return a comparable version object
function Parse-Version {
    param([string]$VersionString)
    $match = [regex]::Match($VersionString, '^\d+(\.\d+){0,3}')
    if ($match.Success) {
        try {
            return [System.Version]$match.Value
        }
        catch {
            return $null
        }
    }
    return $null
}

$nugetPathResolved = Get-VvvvNugetPath -PreferredPath $NugetPath
Write-Host "Using NuGet: $nugetPathResolved"
Write-Host "Dependency scan root: $SearchRoot"
Write-Host "NuGet output directory: $NugetDirectory"
Write-Host "NuGet sources: $($Sources -join '; ')"

New-Item -ItemType Directory -Force -Path $NugetDirectory | Out-Null

# Initialize a hashtable to hold the highest version for each package
$highestVersions = @{}

# Find all .vl files in the requested directory and subdirectories
$files = Get-ChildItem -Path $SearchRoot -Filter *.vl -Recurse -File

foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $dependencies = [regex]::Matches($content, '<NugetDependency Id=".*?" Location="(?<Location>.*?)" Version="(?<Version>.*?)" />')

    foreach ($dependency in $dependencies) {
        $location = $dependency.Groups["Location"].Value
        $versionString = $dependency.Groups["Version"].Value
        $version = Parse-Version -VersionString $versionString

        # Skip if version could not be parsed
        if ($null -eq $version) { continue }

        # Check if the location is in the ignore list
        if ($location -notin $ignoreList) {
            # Update the hashtable with the highest version found for each package
            if (-not $highestVersions.ContainsKey($location) -or (Parse-Version -VersionString $highestVersions[$location]) -lt $version) {
                $highestVersions[$location] = $versionString
            }
        }
    }
}

Write-Host "Resolved package count: $($highestVersions.Count)"

# Install the highest version found for each package
$failedPackages = @()
foreach ($package in $highestVersions.GetEnumerator() | Sort-Object Name) {
    Write-Host "Installing $($package.Name) $($package.Value)"
    & $nugetPathResolved install $package.Name -Version $package.Value -OutputDirectory $NugetDirectory -Source ($Sources -join ';') -Prerelease -NonInteractive
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "NuGet install failed for $($package.Name) $($package.Value) with exit code $LASTEXITCODE. Continuing."
        $failedPackages += "$($package.Name) $($package.Value)"
    }
}

if ($failedPackages.Count -gt 0) {
    Write-Warning "Some packages could not be pre-installed:"
    $failedPackages | ForEach-Object { Write-Warning " - $_" }
}
