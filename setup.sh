#!/bin/bash

#
# https://github.com/yougoxe/data_analyse_dvf
#

# Define text colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cat << "EOF"
  _______      ________                     _                
 |  __ \ \    / /  ____|                   | |               
 | |  | \ \  / /| |__      __ _ _ __   __ _| |_   _ ___  ___ 
 | |  | |\ \/ / |  __|    / _` | '_ \ / _` | | | | / __|/ _ \
 | |__| | \  /  | |      | (_| | | | | (_| | | |_| \__ \  __/
 |_____/   \/   |_|       \__,_|_| |_|\__,_|_|\__, |___/\___|
                                               __/ |         
                                              |___/          
EOF

# Associative array mapping versions to download links and their corresponding SHA-1 hashes
declare -A versions=(
    ["departements-regions"]="https://www.data.gouv.fr/fr/datasets/r/987227fb-dcb2-429e-96af-8979f97c9c84 464b65bce7c3a620d628b55cb5518bac2b8d4a0e"
    ["dvf2022"]="https://www.data.gouv.fr/fr/datasets/r/87038926-fb31-4959-b2ae-7a24321c599a cb748fbd4e51b336e546a122f4b7c3f48bef0205"
    ["dvf2021"]="https://www.data.gouv.fr/fr/datasets/r/817204ac-2202-4b4a-98e7-4184d154d98c 87d4b50eec72c953456b71c907a2f3157c3a5959"
    ["dvf2020"]="https://www.data.gouv.fr/fr/datasets/r/90a98de0-f562-4328-aa16-fe0dd1dca60f 5121c7512888be31b0454c0524f1b46c4d30dda7"
    ["dvf2019"]="https://www.data.gouv.fr/fr/datasets/r/3004168d-bec4-44d9-a781-ef16f41856a2 6cb8b7db62c9713df86f19880619e4af80d781f4"
    ["dvf2018"]="https://www.data.gouv.fr/fr/datasets/r/1be77ca5-dc1b-4e50-af2b-0240147e0346 6cb8b7db62c9713df86f19880619e4af80d781f4"
)

autoDownloadFiles=("departements-regions")

# Prompt user to choose versions
echo "Available versions:"
for version in "${!versions[@]}"; do
    if [[ ! " ${autoDownloadFiles[@]} " =~ " $version " ]]; then
        echo -e " - ${GREEN}$version${NC}"
    fi
done
echo ""

read -rp "Enter the desired versions (comma-separated): " selectedVersionsInput
echo ""

# Split the input into individual versions
IFS=',' read -ra selectedVersions <<< "$selectedVersionsInput"

selectedVersions+=("${autoDownloadFiles[@]}")


# Create data folder
mkdir -p ./data

# Iterate over each selected version
for selectedVersion in "${selectedVersions[@]}"; do
    # Validate the selected version
    if [[ -z "${versions[$selectedVersion]}" ]]; then
        echo -e "${RED}Invalid version selected: $selectedVersion ${NC}" >&2
        continue
    fi
    

    # Download the data file
    versionInfo=(${versions[$selectedVersion]})
    downloadUrl=${versionInfo[0]}
    sha1Hash=${versionInfo[1]}
    fileName="$selectedVersion.csv"
    destinationFolder="data"
    destinationPath="$destinationFolder/$fileName"

    if [[ -f "$destinationPath" ]]; then
        echo -en "${YELLOW}File $destinationPath already exists. Do you want to overwrite it? (y/n): ${NC}"
        read -r overwrite
        if [[ "$overwrite" != "y" ]]; then
            echo -e "${YELLOW}Skipping download of $selectedVersion.${NC}"
            echo ""
            continue
        fi
    fi

    echo -e "Downloading ${GREEN}$selectedVersion ${NC}..."

    # Download the file using wget
    wget -q --show-progress -O "$destinationPath" "$downloadUrl"

    # Verify SHA-1 hash
    computedHash=$(sha1sum "$destinationPath" | awk '{print $1}')

    if [[ "$computedHash" != "$sha1Hash" ]]; then
        # Rename the downloaded file with a prefix indicating it's dangerous
        dangerousFileName="dangerous_$selectedVersion.csv"
        dangerousFilePath="$destinationFolder/$dangerousFileName"
        mv "$destinationPath" "$dangerousFilePath"

        # Display an error message in red
        echo -e "\e${RED}⬤ SHA-1 verification failed for $selectedVersion. The downloaded file is potentially dangerous.\e${NC}"
        echo ""
    else
        echo -e "${GREEN}⬤ ${NC} Download of $selectedVersion complete!"
        echo ""
    fi
done

