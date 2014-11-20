echo -e "### My test sed and perl test! ###" > test.txt
echo -e "  include_once fobar1;\n  include_once biz-bang;\n" >> test.txt

cp test.txt test.sed.txt
cp test.txt test.perl.txt

sed -i -e 's/include_once/\/\/ Removed includes through build: include_once/g' test.sed.txt

perl -pi -e 's?include_once?// Removed includes through build: include_once?g' test.perl.txt
