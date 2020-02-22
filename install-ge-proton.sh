 #!/bin/zsh

. ./common/vars/steampath
. ./common/vars/github

# --------------------------------------------------------------------------------------
# --- CLI tools definitions
# --------------------------------------------------------------------------------------

Ls=$(which ls)
Jq=$(which jq)

if [ $? -ne 0 ] ; then
    echo "Jq is needed for this script to run. Please install it first." >&2
    exit 1
fi

Sed=$(which sed)

# --------------------------------------------------------------------------------------
# --- Functions
# --------------------------------------------------------------------------------------

. ./common/http.sh
. ./common/utils.sh

# --------------------------------------------------------------------------------------
# --- Main
# --------------------------------------------------------------------------------------

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

# Check for last 5 releases

Response="$(fetch_url "$GEProtonReleases")"
Releases="$(parse_response "$Response")"

echo "Recent 5 releases (excluding latest)"
echo "---"
Output=$"ID,Release Tag,Release Name,Release Date\n"

for Index in $(seq 1 5)
do
    ReleaseInfo="$(echo $Releases | $Jq -r --arg i "$Index" '.[$i|tonumber] | [.tag_name, .name, .published_at] | @csv' | sed 's/\"//g')"
    Output=$"${Output}$(echo -n "$Index,$ReleaseInfo")\n"
done

echo -e "$Output" | column -t -s','
echo -n "Choose release to install, l for latest (default) [L/n/1..5]: " 
read Answer

Answer=${Answer:-l}

if [ $Answer = "l" ] || [ $Answer = "L" ] ; then
    install_release "$LatestRelease"
elif [ $Answer = "n" ] || [ $Answer = "N" ] ; then
    echo "Installation cancelled."
    exit 0
elif [ ! $(echo $Answer | sed 's/^[1-5]$//g') ] ; then
    echo "Installing another release."
    ReleaseId=$Answer
    Release=$(echo $Releases | $Jq -r --arg i $ReleaseId '.[$i|tonumber]')
    install_release "$Release"
else
    echo "Invalid input." >&2
    exit 
fi

exit 0
