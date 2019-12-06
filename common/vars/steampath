# --------------------------------------------------------------------------------------
# --- Local path definitions
# --------------------------------------------------------------------------------------

SteamPath="$HOME/.steam"
CompatibilityToolsPath="$SteamPath/compatibilitytools.d"

if [ ! -d "$SteamPath" ] ; then
    echo "Steam not found from $SteamPath" >&2
    exit 1
fi

if [ ! -d "$CompatibilityToolsPath" ] ; then
    echo "Compatibility tools path not found from $CompatibilityToolsPath. Creating one..."
    mkdir $CompatibilityToolsPath
fi
