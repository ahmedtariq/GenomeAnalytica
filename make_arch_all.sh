#!/bin/bash

# This script generalize applying stats like (avg gc content, avg length, count ) for all species under user input containing dir given that each species dir contains gtf and fasta file for species genome
# There are minimum 2 mandatory arguments :
# arg1: the path to directory containing all the species directories containing gtf and fasta files (uncompressed). Dir must be named raw e.g (data/raw/)
# arg2,3,4,...: 1 to 3 characters representing the features that will be filtered for stats. with the following naming:
#	filteration criteria: can be:
#				p for pretein coding or
#				np for non proteing coding
#	feature type: can be:
#			     g for gene
#			     e for exon
#			     f for five_prime_utr
#			     t for three_prime_utr
#	e.g pg for protein coding gene; npt for non protein coding three_prime_utr
# example: to calculate the stats of (non protein coding genes, protein coding exons and all five_prime_utr) for all species under data/raw/ use the following
# ./make_arch_all.sh data/raw/ npg pe f



# setting input vars
sp_dir=$1
shift
fets=("$@")


# setting counter vars
x=1

# setting color vars
RED='\033[0;31m'
GREEN='\e[92m'
NC='\033[0m'

# drop duplicte
fets=$(echo "${fets[@]}" | tr ' ' '\n' | sort -u)
fets=($fets)
num_fets=${#fets[@]}
# check at least 1 feture arg
if [ $num_fets -eq 0 ]; then
	echo -e "${RED} at least 1 feature arg must be provided ${NC}"
	exit 128
fi
# check input feature args
for fet in "${fets[@]}"; do
	if [[ "${fet: -1}" != *g* && "${fet: -1}" != *e* && "${fet: -1}"  != *t* && $fet != *f* ]]; then
		echo -e "${RED} last character in all args must be g (gene), e (exon), t (three_prime_utr) or f (five_prime_utr) ${NC}"
		exit 128
	fi
	if [[ "${fet::-1}" != *np* && "${fet::-1}" != *p* && "${fet::-1}" != "" ]]; then
		echo -e "${RED} second last 2 characters in all args must be p (protein coding), np (non-protein coding) or empty ${NC}"
		exit 128
	fi
done


for fet in "${fets[@]}"; do

	fet=${fet,,}

	if [[ "${fet}" =~ "g" ]]; then
		fet_arg="gene"
		filt="gene_biotype=protein_coding"
	elif [[ "${fet}" =~ "e" ]]; then
		fet_arg="exon"
		filt="transcript_biotype=protein_coding"
	elif [[ "${fet}" =~ "f" ]]; then
		fet_arg="five_prime_utr"
		filt="transcript_biotype=protein_coding"
	elif [[ "${fet}" =~ "t" ]]; then
		fet_arg="three_prime_utr"
		filt="transcript_biotype=protein_coding"
	fi

	if [[ "${fet}" =~ "p" ]] && [[ "${fet}" != *"n"*  ]]; then
		ude="-i"
	elif [[ "${fet}" =~ "p" ]] && [[ "${fet}" =~ "n"  ]]; then
		ude="-e"
	else
		ude=""
		filt=""
	fi

	echo "Make ${fet_arg} ${ude} ${filt} arch ${x}/${num_fets}"

	for i in `ls $sp_dir`; do echo $i; ./get_len_gc.sh $sp_dir/$i/ $fet_arg $ude $filt ; done

	((x++))
done
