# Find all .vl files in the current directory and subdirectories
$files = Get-ChildItem -Path . -Filter *.vl -Recurse

# Initialize arrays to hold unique dependencies and locations
$foundDependencies = @()
$uniqueLocations = @()

foreach ($file in $files) {
    # Read the contents of the file
    $content = Get-Content $file.FullName
    
    # Find lines that match the NugetDependency pattern
    $dependencies = $content | Select-String -Pattern '<NugetDependency Id=".*" Location="(?<Location>.*)" Version="(?<Version>.*)" />' -AllMatches
    
    foreach ($dependency in $dependencies.Matches) {
        $location = $dependency.Groups["Location"].Value
        $version = $dependency.Groups["Version"].Value
        
        # Construct a string representing the dependency
        $dependencyString = "$location -Version $version"
        
        # Add the dependency to the list if it's not already included
        if ($dependencyString -notin $foundDependencies) {
            $foundDependencies += $dependencyString
        }
        
        # Add the location to the list if it's not already included
        if ($location -notin $uniqueLocations) {
            $uniqueLocations += $location
        }
    }
}

# Output the unique dependencies
Write-Output "Found dependencies:"
$foundDependencies | ForEach-Object { Write-Output $_ }

# Output the unique locations
Write-Output "`nUnique locations (regardless of versions):"
$uniqueLocations | Sort-Object | ForEach-Object { Write-Output $_ }
