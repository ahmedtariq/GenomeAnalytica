#!/bin/bash

# This script gets some stats (avg gc content, avg length, count ) for a user specified feature in gtf file using relevant fasta
# There are 2 mandatory arguments :
# arg1: the path to directory containing the species gtf and fasta files (uncompressed) with the following hirarchy: raw/species/ e.g (data/raw/Homo_Sapiens)
# arg2: the feature that will be filtered for stats. this feature should exist in column 3 gtf file. e.g (exon, gene, transcript)
# example: to calculate the stats of all genes of Homo Sapiens use the following
# bash get_len_gc.sh dat/raw/Homo_Sapiens gene
# There are 2 optional arguments to be used when you want to filter certain tag in column 9 gtf:
# arg3: a flag to include or exclude the following (tag=value) argument. to include use -i , to exclude use -e
# arg4: the name of the tag you want to filter tigetherr with the filtering value in the form of (tag=value). e.g (-i gene_biotype=protein_coding)
# example:
# to calculate the stats of exons coming from non-protein coding transcript of Homo Sapiens use the following
# bash get_len_gc.sh dat/raw/Homo_Sapiens exon -e transcript_biotype=proteing_coding

# reading and parsing input args
dir=$1
fet=$2
tagieflag=$3
tagvalue=$4
tag="${tagvalue%%=*}"
val="${tagvalue##*=}"
# setting color vars
RED='\033[0;31m'
GREEN='\e[92m'
NC='\033[0m'
#  getting the fa and gtf files
sp_fa=`find $dir -name '*.fa' -type f`
sp_gtf=`find $dir -name '*.gtf' -type f`

if [  -z "${sp_fa}" ] || [ -z "${sp_gtf}" ]
then
	echo "${RED} no gtf or fa files in ${dir} ${NC}"
else
	## Initial Preparation
	# creating stage dir with species under it
	stg_dir=${dir/"raw"/"stage"}
	mkdir -p $stg_dir
	# creating output dir with species under it
	out_dir=${dir/"raw"/"output"}
	mkdir -p $out_dir

	# extracting species name
	sp="${sp_gtf##*/}"
	sp="${sp%%.*}"

	## filtering feature from gtf
	filt_gtf_name="${sp_gtf##*/}"
	filt_gtf_name=${filt_gtf_name/".gtf"/".${fet}${tagieflag}${tag}${val}.gtf"}
	filt_gtf_path="${stg_dir}${filt_gtf_name}"

	# removing all chromosomes starting with mM (Mitochondria) and filtering out feature
	# in case of choosing feature that has id, duplicated id records are removed
	# in case of user inputting tag flag (include: -i, exclude: -e) , another step of filtering in (with -i) or filtering out (with -e) these tags is made
	if [ -z "${tagieflag}" ]
	then
                cat $sp_gtf | \
                awk -v fet="${fet}" '$1 ~ /^[^Mm#]/ {if ($3==fet) {tagged=0; for(i=9; i<=NF; i++) { if($i==fet"_id") {value=$(i+1); tagged=1} \
		if($i==fet"_id" && seen[value]!=1) {seen[value]=1; print $0; break} if(i==NF && tagged!=1) {print $0}}}}'  > $filt_gtf_path
	elif [ -z "${tagieflag}" ] || [ -z "${tagvalue}" ]
	then
		echo "${RED} arg3 (tag -i -e flag) together with arg4 (tag=value) must be set ${NC}"
		exit 128
	elif [ "${tagieflag}" == "-i" ]
	then
        	cat $sp_gtf | \
		awk -v fet="${fet}" '$1 ~ /^[^Mm#]/ {if ($3==fet) {tagged=0; for(i=9; i<=NF; i++) { if($i==fet"_id") {value=$(i+1); tagged=1} \
                if($i==fet"_id" && seen[value]!=1) {seen[value]=1; print $0; break} if(i==NF && tagged!=1) {print $0}}}}' | \
		awk -v tag="${tag}" -v val="${val}" '{for(i=9; i<=NF; i++) {if($i==tag && index($(i+1),val) != 0) {print $0; break}}}' > $filt_gtf_path
	elif [ "${tagieflag}" == "-e" ]
	then
                cat $sp_gtf | \
                awk -v fet="${fet}" '$1 ~ /^[^Mm#]/ {if ($3==fet) {tagged=0; for(i=9; i<=NF; i++) { if($i==fet"_id") {value=$(i+1); tagged=1} \
                if($i==fet"_id" && seen[value]!=1) {seen[value]=1; print $0; break} if(i==NF && tagged!=1) {print $0}}}}' | \
                awk -v tag="${tag}" -v val="${val}" '{for(i=9; i<=NF; i++) {if($i==tag && index($(i+1),val) == 0) {print $0; break}}}' > $filt_gtf_path
	else
		echo "${RED} unknown arg3. arg3 is a flag to include -i or exclude -e the following tag=value pair ${NC}"
		exit 128

	fi


	lc=`cat $filt_gtf_path | wc -l`
	
        # checking if filter output contains 0 records and removing if so
	if [ $lc -eq 0 ]
        then
                echo -e "${RED} your input feature (${fet}${tagieflag}${tagvalue}) doesnot exist in ${sp} gtf file ${NC}"
		rm $filt_gtf_path
		exit 128
	else
		echo -e "${GREEN} filtered record for ${fet} ${tagvalue} in ${filt_gtf_name} is ${lc} ${NC}"
	fi

	## calculate the len and gc content per feature
	stats_gtf_name=${filt_gtf_name/".gtf"/".stats.gtf"}
	stats_gtf_path="${stg_dir}${stats_gtf_name}"

	bedtools nuc -fi $sp_fa -bed $filt_gtf_path > $stats_gtf_path
	lc=`cat $stats_gtf_path | wc -l`
	echo -e "${GREEN} filtered record for ${fet} in ${stats_gtf_name} is ${lc} ${NC}"
	
	# Aggregate the avg GC and len
	agg_csv_name=${stats_gtf_name/".gtf"/".csv"}
	agg_csv_path="${out_dir}${agg_csv_name}"

	awk -v sp="${sp}" -v fet="${fet}_${tagieflag}_${tagvalue}" -v total="${lc}" 'BEGIN{FS="\t"; OFS=","; print "species,"fet"_avg_gc,"fet"_avg_len,"fet"_count"} { total_gc += $11; count_gc++; total_len +=$18; count_len++ } \
	END { print sp,total_gc/count_gc,total_len/count_len,total}' $stats_gtf_path > $agg_csv_path

fi
