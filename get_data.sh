#!/bin/bash
# This script loop throw the species directories under user specified species contining directory; reading the user specified text file containing the ftp links for gtf and fasta then unzip them
# There are 2 mandatory arguments
# arg1: the directory containing the species directories
# arg2: the name of the faile that contains the ftp link to download
# example:
# ./get_data.sh data/raw WgetMe.txt

sp_dir=$1
ftp_file=$2

for i in `ls $sp_dir`; do 
	cat $sp_dir/$i/$ftp_file  | grep -v ^"#" | while read l; do wget $l -P $sp_dir/$i/ ; done; 
done

gunzip -r $sp_dir
