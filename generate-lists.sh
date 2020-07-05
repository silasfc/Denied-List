# Limpando a tela
#clear

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
echo -e "  - Ocorrências de 'address=/'' e '/*'"
sed -i 's/.*address=\///g' $TEMP_DIR/blacklist
sed -i 's/\/.*//g' $TEMP_DIR/blacklist

echo -e '  - A coluna 0.0.0.0 de entradas de formato hosts...'
sed -i 's/0.0.0.0\ //g' $TEMP_DIR/blacklist

echo -e '  - Todos os espaços, tabulações e outros caracteres inválidos...'
sed -i 's/[[:space:]/]//g' $TEMP_DIR/blacklist
echo -e '  - Ocorrências de 0.0.0.0 na blacklist...'
sed -i '/^0.0.0.0$/d' $TEMP_DIR/blacklist
echo -e '  - Linhas em branco...'
sed -i '/^$/d' $TEMP_DIR/blacklist

echo -e '\n\e[32mGerando lista base (domínios) ordenada e sem duplicatas...'
sort $TEMP_DIR/blacklist | uniq > domains.txt

echo -e '\nCopiando lista base para os demais formatos...'
cat domains.txt | tee hosts.txt | tee dnsmasq.conf > /dev/null

echo -e '\nAjustando lista hosts.txt...'
sed -i 's/^/0.0.0.0\ /g' hosts.txt

echo -e '\nAjustando lista dnsmasq...'
sed -i 's/^/server=\//g' $CURRENT_DIR/dnsmasq.conf
sed -i 's/$/\//g' $CURRENT_DIR/dnsmasq.conf
sed -ri 's/(^server=\/.*-[-|.].*)/\#\1/g' $CURRENT_DIR/dnsmasq.conf
sed -ri 's/(^server=\/.*\.-.*)/\#\1/g' $CURRENT_DIR/dnsmasq.conf
./apply-whitelist-dnsmasq.sh

echo -e '\nRemovendo diretório temporário...'
rm -rf $TEMP_DIR

echo -e "Entradas: $(cat domains.txt | wc -l)"

echo -e '\nPRONTO!\e[0m'
