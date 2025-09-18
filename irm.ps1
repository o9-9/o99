# Downloads the latest version, runs it, and cleans up afterward
$apiUrl = "https://api.github.com/repos/o9-9/o9sc/releases/latest"
$tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "o9sc-portable.exe")

try {
    # Remove old file if it exists (may sometimes cause issues)
    if (Test-Path $tempFile) {
        Remove-Item -Path $tempFile -Force
        Write-Host "Old temporary file removed." -ForegroundColor Green
    }
    
    # Get latest release info
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{
        "Accept"     = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShell Script"
    }
    
    # Get download URL for portable exe
    $downloadUrl = ($releaseInfo.assets | Where-Object { $_.name -eq "o9sc-portable.exe" }).browser_download_url
    
    if (-not $downloadUrl) {
        throw "Could not find o9sc-portable.exe in the latest release"
    }

    if (Test-Path $tempFile) {
        Write-Host "o9Sc already downloaded, starting..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -Wait
    }
    else {
        # Download the file
        Write-Host "Downloading from GitHub..." -ForegroundColor Green
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
    
        # Run the executable
        Write-Host "Starting o9Sc..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -Wait
    }
    
    # Clean up after execution
    if (Test-Path $tempFile) {
        Remove-Item -Path $tempFile -Force
        Write-Host "Temporary file removed, done!" -ForegroundColor Green
    }
    
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Failed to download or run o9Sc." -ForegroundColor Red
}
