CURRENT_DIR=$(pwd -P)

for url in $(cat allowedlist.txt | grep -v '#'); do
    sed -ri "s/(^server=\/$url\/)/\#\1/" $CURRENT_DIR/dnsmasq.conf
done
