# setup.ps1 - Automatically download and extract the latest Hugo Extended version for Windows (64-bit)

# GitHub API URL for latest Hugo release
$apiUrl = "https://api.github.com/repos/gohugoio/hugo/releases/latest"

Write-Host "Fetching latest Hugo release info from GitHub..."

try {
    # Fetch JSON data from API
    $response = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing

    # Find asset download URL for Windows 64-bit extended version (.zip)
    $asset = $response.assets | Where-Object { $_.name -match "hugo_extended_.*windows-amd64.zip" } | Select-Object -First 1

    if (-not $asset) {
        Write-Error "Cannot find Windows 64-bit extended Hugo asset in the latest release."
        exit 1
    }

    $downloadUrl = $asset.browser_download_url
    $zipName = "hugo_extended_latest.zip"

    Write-Host "Downloading latest Hugo Extended from:"
    Write-Host $downloadUrl

    # Download the zip
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipName

    # Extract to current folder, overwrite if exists
    Write-Host "Extracting $zipName ..."
    Expand-Archive -Path $zipName -DestinationPath "." -Force

    # Clean up zip file
    Remove-Item $zipName

    Write-Host "Done! Latest hugo.exe is ready in this folder."

} catch {
    Write-Error "Error occurred: $_"
    exit 1
}
