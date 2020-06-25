# Definindo o diretorio temporario onde será feito o trabalho
temp_dir=/dados/ProgramFiles/dnsmasq

# Preparando terreno para jogar as blacklists no diretorio do serviço
dnsmasqd_path=/etc/dnsmasq.d/
sudo mkdir -p $dnsmasqd_path
sudo ln -sf $temp_dir/blacklist.conf $dnsmasqd_path

# URLs das blacklists
stevenblack_url='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
energized_url='https://block.energized.pro/unified/formats/domains.txt'
oisd_url='https://dbl.oisd.nl'

clear
echo 'Baixando as listas...'
wget $stevenblack_url -qO $temp_dir/stevenblack-fakenews-gambling-porn.conf
wget $energized_url -qO $temp_dir/energized-unified-dbl.conf
wget $oisd_url -qO $temp_dir/oisd-dbl.conf

echo 'Gerando a lista temporária...'
cat $temp_dir/{stevenblack-fakenews-gambling-porn.conf,energized-unified-dbl.conf,oisd-dbl.conf} > $temp_dir/temp.conf

echo 'Removendo linhas comentadas...'
sed -i 's/\#.*//g' $temp_dir/temp.conf
echo 'Removendo linhas com 127.0.0.1 no início...'
sed -i '/^127.0.0.1\ /d' $temp_dir/temp.conf
echo 'Removendo linhas com 255.255.255.255...'
sed -i '/^255.255.255.255\ /d' $temp_dir/temp.conf
echo 'Removendo linhas com endereço IPV6...'
sed -i '/.*\:\:.*/d' $temp_dir/temp.conf

echo 'Removendo a coluna 0.0.0.0 de todas as linhas com 2 colunas...'
sed -i 's/0.0.0.0\ //g' $temp_dir/temp.conf
echo 'Removendo 0.0.0.0 da blacklist...'
sed -i '/^0.0.0.0$/d' $temp_dir/temp.conf

echo 'Removendo todos os espaços...'
sed -i 's/\s//g' $temp_dir/temp.conf
echo 'Removendo linhas brancas...'
sed -i '/^$/d' $temp_dir/temp.conf

echo 'Ordenando e excluindo duplicatas para formato domínios...'
sort temp.conf | uniq > domains.txt

echo 'Incluindo no início de cada linha address=/ ...'
sed -i 's/^/address=\//g' $temp_dir/temp.conf
echo 'Incluindo no final de cada linha o 0.0.0.0 ...'
sed -i 's/$/\/0.0.0.0/g' $temp_dir/temp.conf

echo 'Comentando linhas de domínios com -- (inválido)'
sed -ri 's/(.*--.*)/\#\1/g' $temp_dir/temp.conf

echo 'Ordenando e excluindo duplicatas para formato dnsmasq...'
sort temp.conf | uniq > dnsmasq.conf

echo 'PRONTO!'
