Curl=$(which curl)
Tar=$(which tar)

install_release()
{
    DownloadUrl=$(echo "$1" | $Jq -r '.assets | .[0] | .browser_download_url' )
    DownloadPackage=$(echo "$1" | $Jq -r '.assets | .[0] | .name' )

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

    return 0
}
