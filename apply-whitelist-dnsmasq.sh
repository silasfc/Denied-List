CURRENT_DIR=$(pwd -P)

for url in $(cat whitelist.txt | grep -v '#'); do
    sed -ri "s/(^address=\/$url\/0.0.0.0)/\#\1/" $CURRENT_DIR/{dnsmasq.conf,dnsmasq-ipv6.conf}
done
