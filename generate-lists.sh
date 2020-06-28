# Limpando a tela
clear

CURRENT_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
echo -e "\n\e[32mCriando diretório de trabalho temporário ($TEMP_DIR)..."

echo -e '\nBaixando as listas de:'
rm -f $TEMP_DIR/blacklist
for f in $(cat adblock-sources.txt | grep -v '#'); do
    echo -e '\e[33m  - '$f
    wget $f -qO - >> $TEMP_DIR/blacklist
done

echo -e '\n\e[32mRemovendo:'
echo -e '\e[33m  - Linhas comentadas...'
sed -i 's/\#.*//g' $TEMP_DIR/blacklist
echo -e '  - Linhas com 127.0.0.1 ou 255.255.255.255 no início...'
sed -i '/^[127.0.0.1|255.255.255.255]\ /d' $TEMP_DIR/blacklist
echo -e '  - Linhas com endereço IPV6...'
sed -i '/.*\:\:.*/d' $TEMP_DIR/blacklist

echo -e '  - A coluna 0.0.0.0 de todas as linhas com 2 colunas...'
sed -i 's/0.0.0.0\ //g' $TEMP_DIR/blacklist
echo -e '  - Ocorrências de 0.0.0.0 na blacklist...'
sed -i '/^0.0.0.0$/d' $TEMP_DIR/blacklist

echo -e '  - Todos os espaços e/ou tabulações...'
sed -i 's/\s//g' $TEMP_DIR/blacklist
echo -e '  - Linhas em branco...'
sed -i '/^$/d' $TEMP_DIR/blacklist

echo -e '\n\e[32mGerando lista base (domínios) ordenada e sem duplicatas...'
sort $TEMP_DIR/blacklist | uniq > domains.txt

echo -e '\nCopiando lista base para os demais formatos...'
cat domains.txt | tee hosts.txt | tee dnsmasq.conf | tee dnsmasq-ipv6.conf > /dev/null

echo -e '\nGerando lista hosts.txt...'
sed -i 's/^/0.0.0.0\ /g' hosts.txt

echo -e '\nGerando listas dnsmasq (ipv4 e ipv6)...'
sed -i 's/^/address=\//g' $CURRENT_DIR/{dnsmasq.conf,dnsmasq-ipv6.conf}
sed -i 's/$/\/0.0.0.0/g' $CURRENT_DIR/dnsmasq.conf
sed -i 's/$/\/::1/g' $CURRENT_DIR/dnsmasq-ipv6.conf
sed -ri 's/(^address=\/.*-[-|.].*)/\#\1/g' $CURRENT_DIR/{dnsmasq.conf,dnsmasq-ipv6.conf}
sed -ri 's/(^address=\/.*\.-.*)/\#\1/g' $CURRENT_DIR/{dnsmasq.conf,dnsmasq-ipv6.conf}
./apply-whitelist.sh

echo -e '\nRemovendo diretório temporário...'
rm -rf $TEMP_DIR

echo -e '\nPRONTO!\e[0m'
