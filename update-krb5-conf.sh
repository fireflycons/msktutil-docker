#!/bin/sh

if [ -z "$REALM" ]
then
    echo "REALM not set"
    exit 1
fi

if [ -z "$ADMIN_SERVER" ]
then
    echo "ADMIN_SERVER not set"
    exit 1
fi

if [ -z "$KDC_SERVER" ]
then
    echo "KDC_SERVER not set"
    exit 1
fi

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
