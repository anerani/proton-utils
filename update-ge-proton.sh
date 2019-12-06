#!/bin/zsh

. ./steampath-vars.sh
. ./github-vars.sh

# --------------------------------------------------------------------------------------
# --- CLI tools definitions
# --------------------------------------------------------------------------------------

Curl=$(which curl)
Ls=$(which ls)
Jq=$(which jq)

if [ $? -ne 0 ] ; then
    echo "Jq is needed for this script to run. Please install it first." >&2
    exit 1
fi

Tar=$(which tar)
Sed=$(which sed)

# --------------------------------------------------------------------------------------
# --- Script
# --------------------------------------------------------------------------------------

Response="$($Curl -s "$GEProtonLatestRelease" | $Sed 's/\\r\\n//g')"

if [ $? -ne 0 ] ; then
    echo "Request to Github failed." >&2
    echo $Response >&2
    exit 1
fi

VersionInfo="$(echo $Response | $Jq -r .)"

if [ $? -ne 0 ] ; then
    echo "Parsing the response data failed." >&2
    echo $Response >&2
    exit 1
elif [ $VersionInfo = "" ] ; then
    echo "Empty response from server." >&2
    exit 1
fi

LatestVersion=$(echo "$VersionInfo" | $Jq -r .name)
LatestTag=$(echo "$VersionInfo" | $Jq -r .tag_name)

echo "---"
echo "Latest version of GE Proton is $LatestVersion (${LatestTag})."
echo ""
echo "Description: $(echo "$VersionInfo" | $Jq -r .body | fmt)"
echo "---"
echo ""

CurrentTools=$($Ls $CompatibilityToolsPath)

echo "Existing custom compatibility tools found"
echo "---"
echo $CurrentTools
echo ""

for Dir in $CurrentTools
do
    if [ "$(echo $Dir | grep "$LatestVersion")" != "" ] || [ "$(echo $Dir | grep "$LatestTag")" != "" ] ; then
        echo "All good, you're up to date!"
        exit 0
    fi
done

echo -n "Do you wish to install latest GE Proton? [y/N] " 
read Answer

Answer=${Answer:-n}

if [ $Answer = "Y" ] || [ $Answer = "y" ] ; then
    DownloadUrl=$(echo "$VersionInfo" | $Jq -r '.assets | .[0] | .browser_download_url' )
    DownloadPackage=$(echo "$VersionInfo" | $Jq -r '.assets | .[0] | .name' )
    
    echo "Downloading the release package."
    $Curl -L --progress-bar "$DownloadUrl" | gunzip - | $Tar -xf - -C "$CompatibilityToolsPath"
    
    if [ $? -ne 0 ] ; then
        echo "Download failed." >&2
        exit 1
    fi
    
    if [ ! -d "$CompatibilityToolsPath/$(echo $DownloadPackage | $Sed 's/\.tar\.gz//g')" ] ; then
        echo "Download failed." >&2
        exit 1
    fi

    echo "Done."
    exit 0
elif [ $Answer = "n" ] || [ $Answer = "N" ] ; then
    echo "Not updating."
    exit 0
else
    echo "Invalid input." >&2
    exit 1
fi
