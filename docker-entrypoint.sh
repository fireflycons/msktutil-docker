#!/bin/sh

#  msktutil create -b "CN=COMPUTERS" -s HTTP/squid.fc.local -h squid.fc.local -k /tmp/HTTP.keytab --computer-name squid --upn HTTP/squid.fc.local --server fc-vad03.fc.local --verbose --verbose: --enctypes 28
while getopts u:h arg
do
    case "${arg}" in
    u)
        username=$OPTARG
        ;;
    h)
        msktutil --help
        exit 0
        ;;
    *)
        echo "Unrecogised argument ${OPTARG}"
        exit 1
        ;;
    esac
done

if [ -z "$username" ]
then
    echo "-u is required"
    exit 1
fi

kinit $username || exit 1

klist
