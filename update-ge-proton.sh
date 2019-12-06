#!/bin/zsh

. ./common/vars/steampath
. ./common/vars/github

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

. ./common/helpers.sh
. ./common/http.sh

Response="$(fetch_url "$GEProtonLatestRelease")"
LatestRelease="$(parse_response "$Response")"

LatestVersion=$(echo "$LatestRelease" | $Jq -r .name)
LatestTag=$(echo "$LatestRelease" | $Jq -r .tag_name)

echo "---"
echo "Latest version of GE Proton is $LatestVersion (${LatestTag})."
echo ""
echo "Description: $(echo "$LatestRelease" | $Jq -r .body | fmt)"
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
    install_release $LatestRelease
elif [ $Answer = "n" ] || [ $Answer = "N" ] ; then
    echo "Not updating."
    exit 0
else
    echo "Invalid input." >&2
    exit 1
fi
