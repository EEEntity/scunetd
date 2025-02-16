#!/bin/bash

default_ip="192.168.2.135"
userid=""
passwd=""
ip="$default_ip"

function show_help() {
    echo "Usage: $0 --userid <userid> --password <password> [--ip <ip>]"
    echo "Example: $0 --userid 2024322010000 --password 123456 --ip 192.168.1.100"
}

fetch_params() {
    local fetch_url="http://""$1"
    test_online=$(curl -XGET -sL -o /dev/null -w '%{url_effective}' $fetch_url)
    if [[ $test_online == *"success.jsp"* ]]; then
        echo "rdy"
    fi
    string=$(curl -XGET -sL $fetch_url | cut -d"'" -f2)
    echo ${string#*\?}
}

generate_data() {
    local userid="$1"
    local passwd="$2"
    local ip="$3"
    cat <<EOF
    "{
        "userId":"$userid",
        "password": "$passwd",
        "service": "internet",
        "queryString": $(fetch_params $ip),
        "operatorPwd": "",
        "operatorUserId": "",
        "validcode": "",
        "passwordEncrypt": "false"
    }"
EOF
}

login() {
    local userid="$1"
    local passwd="$2"
    local login_url="http://"$3"/eportal/InterFace.do?method=login"
    query=$(fetch_params $ip)
    if [[ $query == "rdy" ]]; then
        exit 0
    fi
    response=$(curl -XPOST -sL $login_url \
    --data-urlencode "userId=$userid" \
    --data-urlencode "password=$passwd" \
    --data-urlencode "service=internet" \
    --data-urlencode "queryString=$query" \
    --data-urlencode "operatorUserId=" \
    --data-urlencode "operatorPwd=" \
    --data-urlencode "validcode=" \
    --data-urlencode "passwordEncrypt=false")
    echo $response
    if [[ $response != *"success"* ]]; then
        exit 3
    else exit 0
    fi
}

while [[ "$1" != "" ]]; do
    case $1 in
        --userid )
            shift
            userid=$1
            ;;
        --password )
            shift
            password=$1
            ;;
        --ip )
            shift
            ip=$1
            ;;
        -h | --help )
            show_help
            exit 0
            ;;
        -v )
            generate_data $userid $passwd $ip
            exit 0
            ;;
        * )
            echo "Invalid option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

if [ -z "$userid" ] || [ -z "$password" ]; then
    echo "Error: --userid and --password are required."
    show_help
    exit 2
fi


login $userid $password $ip
