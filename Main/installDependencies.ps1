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

# The NuGet commands directory
$nugetDirectory = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local\vvvv\gamma\nugets"

# NuGet executable path
$nugetPath = "C:\Program Files\vvvv\vvvv_gamma_5.2\tools\NuGet.exe"

# Ensure NuGet executable exists
if (-not (Test-Path -Path $nugetPath)) {
    Write-Error "NuGet executable not found at $nugetPath. Please ensure it is installed correctly."
    exit
}

# Initialize a hashtable to hold the highest version for each package
$highestVersions = @{}

# Function to parse and return a comparable version object
function Parse-Version($versionString) {
    $match = [regex]::Match($versionString, '^\d+(\.\d+){0,3}')
    if ($match.Success) {
        try {
            return [System.Version]$match.Value
        } catch {
            return $null
        }
    }
    return $null
}

# Find all .vl files in the current directory and subdirectories
$files = Get-ChildItem -Path . -Filter *.vl -Recurse

foreach ($file in $files) {
    # Read the contents of the file
    $content = Get-Content $file.FullName
    
    # Find lines that match the NugetDependency pattern
    $dependencies = $content | Select-String -Pattern '<NugetDependency Id=".*" Location="(?<Location>.*)" Version="(?<Version>.*)" />' -AllMatches
    
    foreach ($dependency in $dependencies.Matches) {
        $location = $dependency.Groups["Location"].Value
        $versionString = $dependency.Groups["Version"].Value
        $version = Parse-Version $versionString
        
        # Skip if version could not be parsed
        if ($null -eq $version) { continue }
        
        # Check if the location is in the ignore list
        if ($location -notin $ignoreList) {
            # Update the hashtable with the highest version found for each package
            if (-not $highestVersions.ContainsKey($location) -or (Parse-Version $highestVersions[$location]) -lt $version) {
                $highestVersions[$location] = $versionString
            }
        }
    }
}

# Install the highest version found for each package
foreach ($package in $highestVersions.GetEnumerator()) {
    $nugetCommand = "& `"$nugetPath`" install $($package.Name) -Version $($package.Value) -OutputDirectory `"$nugetDirectory`""
    Invoke-Expression $nugetCommand
}
