echo 'Criando um diretório de trabalho temporário'
TEMP_DIR=$(mktemp -p $(pwd) -d)

# Preparando terreno para jogar as blacklists no diretorio do serviço
dnsmasqd_path=/etc/dnsmasq.d/
sudo mkdir -p $dnsmasqd_path
sudo ln -sf dnsmasq.conf $dnsmasqd_path

clear
echo 'Baixando as listas de:'
rm -f $TEMP_DIR/blacklist
for f in $(cat url-sources.txt | grep -v '#'); do
    echo '    -> '$f
    wget $f -qO - >> $TEMP_DIR/blacklist
done

echo 'Removendo:'
echo '    -> linhas comentadas...'
sed -i 's/\#.*//g' $TEMP_DIR/blacklist
echo '    -> linhas com 127.0.0.1 no início...'
sed -i '/^127.0.0.1\ /d' $TEMP_DIR/blacklist
echo '    -> linhas com 255.255.255.255...'
sed -i '/^255.255.255.255\ /d' $TEMP_DIR/blacklist
echo '    -> linhas com endereço IPV6...'
sed -i '/.*\:\:.*/d' $TEMP_DIR/blacklist

echo '    -> a coluna 0.0.0.0 de todas as linhas com 2 colunas...'
sed -i 's/0.0.0.0\ //g' $TEMP_DIR/blacklist
echo '    -> 0.0.0.0 da blacklist...'
sed -i '/^0.0.0.0$/d' $TEMP_DIR/blacklist

echo '    -> todos os espaços...'
sed -i 's/\s//g' $TEMP_DIR/blacklist
echo '    -> linhas brancas...'
sed -i '/^$/d' $TEMP_DIR/blacklist

echo 'Gerando lista base (domínios) ordenada e sem duplicatas...'
sort $TEMP_DIR/blacklist | uniq > domains.txt

echo 'Copiando lista base para as dos demais formatos...'
cat domains.txt | tee hosts.txt | tee dnsmasq.conf | tee dnsmasq-ipv6.conf > /dev/null

echo 'Gerando lista hosts.txt ...'
sed -i 's/^/0.0.0.0\ /g' hosts.txt

echo 'Gerando lista dnsmas.conf e dnsmasq-ipv6.conf ...'
sed -i 's/^/address=\//g' {dnsmasq.conf,dnsmasq-ipv6.conf}
sed -i 's/$/\/0.0.0.0/g' dnsmasq.conf
sed -i 's/$/\/::1/g' dnsmasq-ipv6.conf
sed -ri 's/(.*--.*)/\#\1/g' {dnsmasq.conf,dnsmasq-ipv6.conf}

echo 'Removendo diretório temporário...'
rm -rf $TEMP_DIR

echo 'PRONTO!'
