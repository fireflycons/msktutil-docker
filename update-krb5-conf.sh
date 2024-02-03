#!/bin/sh

usage() {
    echo "$0 usage:" && grep " .)\ #" $0
    echo
    echo "If KDC and ADMIN are the same server, you can give either of -k or -a and the same server will be used for both."
    exit 1
}
[ $# -eq 0 ] && usage

while getopts 'r:k:a:h' arg
do
    case "${arg}" in
    r) # Specify Realm (Active Directory domain)
        REALM=$OPTARG
        ;;
    k) # Specify KDC server (normally primary domain controller), e.g. dc01
        KDC_SERVER=$OPTARG
        ;;
    a) # Specify Admin server (normally primary domain controller), e.g. dc01
        ADMIN_SERVER=$OPTARG
        ;;
    h | *)
        usage
        ;;
    esac
done

[ -z "$REALM" ] && usage
[ -z "$ADMIN_SERVER" -a -z "$KDC_SERVER" ] && usage
[ -z "$ADMIN_SERVER" ] && ADMIN_SERVER=$KDC_SERVER
[ -z "$KDC_SERVER" ] && KDC_SERVER=$ADMIN_SERVER

_domain=$(echo $REALM | tr '[:upper:]' '[:lower:]')
_realm=$(echo $REALM | tr '[:lower:]' '[:upper:]')

cat <<EOF > sed.prog
s/EXAMPLE.COM/$_realm/
s/example.com/$_domain/
s/kdc = kdc/kdc = $KDC_SERVER/
s/admin_server = admin/admin_server = $ADMIN_SERVER/
EOF

sed -i -f sed.prog /etc/krb5.conf

rm -f sed.prog
