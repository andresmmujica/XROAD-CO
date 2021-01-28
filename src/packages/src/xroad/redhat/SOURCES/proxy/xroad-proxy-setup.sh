#!/bin/bash
# X-Road proxy post-install configuration

#
# Create default internal certificate
#
HOST=$(hostname -f)
LIST=
for i in $(ip addr | grep 'scope global' | tr '/' ' ' | awk '{print $2}')
do
    LIST+="IP:$i,";
done

ALT="${LIST}DNS:$(hostname),DNS:$HOSTNAME"

if [[ ! -r /etc/xroad/ssl/internal.crt || ! -r /etc/xroad/ssl/internal.key  || ! -r /etc/xroad/ssl/internal.p12 ]]
then
    echo "Generating new internal.[crt|key|p12] files "
    rm -f /etc/xroad/ssl/internal.crt /etc/xroad/ssl/internal.key /etc/xroad/ssl/internal.p12
    /usr/share/xroad/scripts/generate_certificate.sh  -n internal -s "/CN=$HOST" -a "$ALT" -p 2> /tmp/cert.err || echo "generate_certificate failed, see /tmp/cert.err!"
fi

mkdir -p /var/spool/xroad; chown xroad:xroad /var/spool/xroad
mkdir -p /var/cache/xroad; chown xroad:xroad /var/cache/xroad
mkdir -p /etc/xroad/globalconf; chown xroad:xroad /etc/xroad/globalconf

/usr/share/xroad/scripts/setup_serverconf_db.sh
