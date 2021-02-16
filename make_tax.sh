#!/bin/bash

sp_dir=$1
save_dir=$2

map_path="${save_dir}/tax_mapping.csv"
touch $map_path
for sp in `ls $sp_dir`
do
	esearch -db taxonomy -query $sp | efetch -format xml | xtract -pattern Lineage -element Lineage | awk -v sp="${sp}" 'BEGIN{FS="; "; OFS=","} {$1=$1; print sp,$0}' >> ${map_path}

done
