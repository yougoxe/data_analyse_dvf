#
# https://github.com/yougoxe/data_analyse_dvf
#

Write-Host @"
  _______      ________                     _                
 |  __ \ \    / /  ____|                   | |               
 | |  | \ \  / /| |__      __ _ _ __   __ _| |_   _ ___  ___ 
 | |  | |\ \/ / |  __|    / _` | '_ \ / _` | | | | / __|/ _ \
 | |__| | \  /  | |      | (_| | | | | (_| | | |_| \__ \  __/
 |_____/   \/   |_|       \__,_|_| |_|\__,_|_|\__, |___/\___|
                                               __/ |         
                                              |___/          
"@

# Associative array mapping versions to download links and their corresponding SHA-1 hashes
$versions = @{
    "departements-regions" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/987227fb-dcb2-429e-96af-8979f97c9c84"
        "sha1" = "464b65bce7c3a620d628b55cb5518bac2b8d4a0e"
    }
    "dvf2022" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/87038926-fb31-4959-b2ae-7a24321c599a"
        "sha1" = "cb748fbd4e51b336e546a122f4b7c3f48bef0205"
    }
    "dvf2021" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/817204ac-2202-4b4a-98e7-4184d154d98c"
        "sha1" = "87d4b50eec72c953456b71c907a2f3157c3a5959"
    }
    "dvf2020" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/90a98de0-f562-4328-aa16-fe0dd1dca60f"
        "sha1" = "5121c7512888be31b0454c0524f1b46c4d30dda7"
    }
    "dvf2019" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/3004168d-bec4-44d9-a781-ef16f41856a2"
        "sha1" = "6cb8b7db62c9713df86f19880619e4af80d781f4"
    }
    "dvf2018" = @{
        "url" = "https://www.data.gouv.fr/fr/datasets/r/1be77ca5-dc1b-4e50-af2b-0240147e0346"
        "sha1" = "6cb8b7db62c9713df86f19880619e4af80d781f4"
    }
}

$autoDownloadFiles = @("departements-regions")

# Prompt user to choose versions
Write-Host "Available versions:"
foreach ($version in $versions.Keys) {
    if ($autoDownloadFiles -notcontains $version) {
        Write-Host " - $version" -ForegroundColor Green
    }
}
Write-Host ""

$selectedVersionsInput = Read-Host "Enter the desired versions (comma-separated)"

# Split the input into individual versions
$selectedVersions = $selectedVersionsInput -split ','

$selectedVersions += $autoDownloadFiles

$destinationFolder = "data"
New-Item -ItemType Directory -Force -Path $destinationFolder | Out-Null

# Iterate over each selected version
foreach ($selectedVersion in $selectedVersions) {
    # Validate the selected version
    if (-not $versions.ContainsKey($selectedVersion)) {
        Write-Host "Invalid version selected: $selectedVersion" -ForegroundColor Red
        Write-Host ""
        continue
    }

    # Download the data file
    $versionInfo = $versions[$selectedVersion]
    $downloadUrl = $versionInfo["url"]
    $sha1Hash = $versionInfo["sha1"]
    $fileName = "$selectedVersion.csv"
    $destinationPath = Join-Path $destinationFolder $fileName

    if (Test-Path -Path $destinationPath) {
        Write-Host "File $destinationPath already exists. Do you want to overwrite it? (y/n): " -NoNewline -ForegroundColor Yellow
        $overwrite = Read-Host
        if ($overwrite -ne "y") {
            Write-Host "Skipping download of $selectedVersion." -ForegroundColor Yellow
            Write-Host ""
            continue
        }
    }

    Write-Host "Downloading $selectedVersion..."

    # Download the file using Invoke-WebRequest and stream it to the destination folder
    $webRequest = Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath -PassThru

# Verify SHA-1 hash
$computedHash = (Get-FileHash -Path $destinationPath -Algorithm SHA1).Hash

if ($computedHash -ne $sha1Hash) {
    # Rename the downloaded file with a prefix indicating it's dangerous
    $dangerousFileName = "dangerous_$selectedVersion.csv"
    $dangerousFilePath = Join-Path $destinationFolder $dangerousFileName
    Rename-Item -Path $destinationPath -NewName $dangerousFileName -Force

    # Display an error message in red
    Write-Host "⬤ SHA-1 verification failed for $selectedVersion. The downloaded file is potentially dangerous." -ForegroundColor Red
    Write-Host ""
}
else {
    Write-Host "⬤ Download of $selectedVersion complete!" -ForegroundColor Green
    Write-Host ""
	}
}
