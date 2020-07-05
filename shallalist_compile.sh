echo -e '\n\e[32mBaixando o arquivo'
rm -rf temp BL
wget -q -O shallalist.tar.gz http://www.shallalist.de/Downloads/shallalist.tar.gz
echo -e 'Descompactando o pack'
tar xzf shallalist.tar.gz

echo -e 'Arquivos:'
files=$(find . -iname 'domains') # | grep -v porn
echo '' > shallalist.txt

for f in $files; do
    echo -e "\e[33m  $f"
    cat $f >> shallalist.txt
done

echo -e '\n\e[32mRemovendo o pack shallalist.tar.gz'
rm shallalist.tar.gz
echo -e 'Removendo o diretório de extração temporário'
rm -rf BL

echo -e '\nPRONTO!\e[0m'
