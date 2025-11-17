# PowerShell script to create dreame_vacuum.zip for release
# Usage: .\create_release_zip.ps1

$manifestPath = "custom_components\dreame_vacuum\manifest.json"
$manifestContent = Get-Content $manifestPath -Raw | ConvertFrom-Json
$version = $manifestContent.version
$zipName = "dreame_vacuum.zip"
$tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }

Write-Host "Creating release zip for version: $version" -ForegroundColor Green
Write-Host "Temporary directory: $tempDir"

# Copy the integration directory to temp location
Copy-Item -Path "custom_components\dreame_vacuum" -Destination $tempDir -Recurse -Force

# Create zip file from the integration directory contents (not the directory itself)
# The install script unzips into custom_components/dreame_vacuum/, so zip should contain files at root
$zipPath = Join-Path $tempDir $zipName
$sourcePath = Join-Path $tempDir "dreame_vacuum"
Compress-Archive -Path "$sourcePath\*" -DestinationPath $zipPath -Force

# Move zip to current directory
Move-Item -Path $zipPath -Destination $zipName -Force

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

