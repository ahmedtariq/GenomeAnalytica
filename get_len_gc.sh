#!/bin/bash

dir=$1
fet=$2
tagvalue=$3
tag="${tagvalue%%=*}"
val="${tagvalue##*=}"
#  getting the fa and gtf files
sp_fa=`find $dir -name '*.fa' -type f`
sp_gtf=`find $dir -name '*.gtf' -type f`

if [  -z "${sp_fa}" ] || [ -z "${sp_gtf}" ]
then
	echo "no gtf or fa files in ${dir}"
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
	sp="${sp%%_*}"

	## filtering feature from gtf
	filt_gtf_name="${sp_gtf##*/}"
	filt_gtf_name=${filt_gtf_name/".gtf"/".${fet}${tag}${val}.gtf"}
	filt_gtf_path="${stg_dir}${filt_gtf_name}"

	# removing all chromosomes starting with mM (Mitochondria) and filtering out feature
	# in case of choosing exon as feature, duplicate exon records are removed
	if [ -z "${tagvalue}" ]
	then
		awk -v fet="${fet}" '$1 ~ /^[^Mm#]/ {if ($3 == fet) print}' $sp_gtf | \
		awk -v fet="${fet}" '{tagged=0; for(i=9; i<=NF; i++) { if($i==fet"_id") {value=$(i+1); tagged=1} if($i==fet"_id" && seen[value]!=1) {seen[value]=1; print $0 ;break} \
		if(i==NF && tagged!=1) {print $0}}}'  > $filt_gtf_path
	else
        	awk -v fet="${fet}" '$1 ~ /^[^Mm#]/ {if ($3 == fet) print}' $sp_gtf | \
		awk -v tag="${tag}" -v val="${val}" '{for(i=9; i<=NF; i++) {if($i==tag) {tag_found=1} else if(tag_found==1 && index($i,val) != 0) {tag_found=0; print $0} else {tag_found=0}}}' | \
		awk -v fet="${fet}" '{tagged=0; for(i=9; i<=NF; i++) { if($i==fet"_id") {value=$(i+1); tagged=1} if($i==fet"_id" && seen[value]!=1) {seen[value]=1; print $0 ;break} \
		if(i==NF && tagged!=1) {print $0}}}'> $filt_gtf_path
	fi


	lc=`cat $filt_gtf_path | wc -l`
	RED='\033[0;31m'
	GREEN='\e[92m'
	NC='\033[0m'
	
        # checking if filter output contains 0 records and removing if so
	if [ $lc -eq 0 ]
        then
                echo -e "${RED} your input feature (${fet} ${tagvalue}) doesnot exist in ${sp} gtf file ${NC}"
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

	awk -v sp="${sp}" -v fet="${fet}_${tagvalue}" 'BEGIN{FS="\t"; OFS=","; print "species,"fet"_avg_gc,"fet"_avg_len"} { total_gc += $11; count_gc++; total_len +=$18; count_len++ } \
	END { print sp,total_gc/count_gc,total_len/count_len }' $stats_gtf_path > $agg_csv_path

fi
