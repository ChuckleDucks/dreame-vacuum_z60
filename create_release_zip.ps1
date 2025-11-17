# PowerShell script to create dreame_vacuum.zip for release
# Usage: .\create_release_zip.ps1

$manifestPath = "custom_components\dreame_vacuum\manifest.json"
$manifestContent = Get-Content $manifestPath -Raw | ConvertFrom-Json
$version = $manifestContent.version
$zipName = "dreame_vacuum.zip"

Write-Host "Creating release zip for version: $version" -ForegroundColor Green

# The zip should contain files at root level (not in custom_components/dreame_vacuum/)
# HACS will extract this into custom_components/dreame_vacuum/
# Copy to temp directory first, then compress to ensure all subdirectories are included
$tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
$sourcePath = "custom_components\dreame_vacuum"

# Copy all files and subdirectories to temp location preserving structure
Copy-Item -Path "$sourcePath\*" -Destination $tempDir -Recurse -Force

# Use .NET compression to ensure forward slashes in zip paths (Python requirement)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = Join-Path (Get-Location).Path $zipName

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')

# Add all files with forward slashes in paths
$tempDirFullPath = (Resolve-Path $tempDir).Path
Get-ChildItem -Path $tempDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($tempDirFullPath.Length + 1)
    # Convert backslashes to forward slashes for Python compatibility
    $entryName = $relativePath.Replace('\', '/')
    $entry = $zip.CreateEntry($entryName)
    $entryStream = $entry.Open()
    $fileStream = [System.IO.File]::OpenRead($_.FullName)
    $fileStream.CopyTo($entryStream)
    $fileStream.Close()
    $entryStream.Close()
}

$zip.Dispose()

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force

$fileSize = (Get-Item $zipName).Length / 1MB
Write-Host "✓ Created $zipName" -ForegroundColor Green
Write-Host "✓ File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Create a GitHub release with tag: $version"
Write-Host "2. Attach $zipName to the release"
Write-Host "3. The release URL should be: https://github.com/Tasshack/dreame-vacuum/releases/download/$version/$zipName"

