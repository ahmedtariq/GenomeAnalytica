#!/bin/bash
# This script loop throw the species directories under user specified species contining directory; using the species dir naming the taxonomy lineage record is retrieved from ncbi, 
# appended in csv file and saved in user specified file
# There are 2 mandatory arguments
# arg1: the directory containing the species directories
# arg2: the name of the taxonomy mapping csv file to be saved
# example:
# ./make_tax.sh data/raw/ tax_mapping.csv



sp_dir=$1
save_dir=$2

map_path="${save_dir}/tax_mapping.csv"
touch $map_path
for sp in `ls $sp_dir`
do
	esearch -db taxonomy -query $sp | efetch -format xml | xtract -pattern Lineage -element Lineage | awk -v sp="${sp}" 'BEGIN{FS="; "; OFS=","} {$1=$1; print sp,$0}' >> ${map_path}

done
