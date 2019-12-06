Curl=$(which curl)

fetch_url ()
{
    local Response="$($Curl -s "$1" | $Sed 's/\\r\\n//g')"
    
    if [ $? -ne 0 ] ; then
        echo "Request to Github failed." >&2
        exit 1
    fi
    
    echo "$Response"
}

parse_response()
{
    JsonData="$(echo $1 | $Jq -r .)"

    if [ $? -ne 0 ] ; then
        echo "Parsing the response data failed." >&2
        echo $1 >&2
        exit 1
    elif [ "$JsonData" = "" ] ; then
        echo "Empty response from server." >&2
        exit 1
    fi
    
    echo "$JsonData"
}
