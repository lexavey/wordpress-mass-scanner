down_par(){
    while ! command -v ./parallel &> /dev/null
    do
        # printf "\rDownloading Parallel"
        wget -q http://git.savannah.gnu.org/cgit/parallel.git/plain/src/parallel -O parallel
        chmod 755 parallel
        printf "will cite" | ./parallel --citation &> /dev/null
    done
}
fast_search(){
    host=$1
    pattern='wp-content'
    
    if [[ $host =~ http[s]? ]]; then
        url="$host"
    else 
        url="http://$host/"
    fi
    temp_http_header=$(mktemp)
    temp_http_response=$(mktemp)
    code=$(curl -L -s $url --insecure -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36 OPR/90.0.4480.100' --connect-timeout 10 --max-time 10 --write-out '%{http_code}' --dump-header $temp_http_header -o $temp_http_response)
    result=$(grep -E $pattern $temp_http_header $temp_http_response -oah | sort -u |paste -d, -s)
    rm -f $temp_http_header$temp_http_response
    echo "$url">>result.txt
    echo "$code|$url|$result"
}
getlist=host.txt
down_par
export -f fast_search
./parallel -j 0 -a $getlist fast_search {}
