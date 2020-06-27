CURRENT_DIR=$(pwd -P)

for url in $(cat whitelist | grep -v '#'); do
    sed -ri "s/(^address=\/$url.*)/\#\1/" $CURRENT_DIR/{dnsmasq.conf,dnsmasq-ipv6.conf}
done
