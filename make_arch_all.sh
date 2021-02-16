#!/bin/bash


echo "Make gene arch 1/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ gene; done

sleep 0.5

echo "Make protein coding gene arch 2/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ gene -i gene_biotype=protein_coding ; done

sleep 0.5

echo "Make non-protein coding gene arch 3/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ gene -e gene_biotype=protein_coding ; done

sleep 0.5

echo "Make exon arch 4/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ exon ; done

sleep 0.5

echo "Make protein coding exon arch 5/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ exon -i transcript_biotype=protein_coding ; done

sleep 0.5

echo "Make non-protein coding exon arch 6/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ exon -e transcript_biotype=protein_coding ; done

sleep 0.5

echo "Make five_prime_utr arch 7/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ five_prime_utr ; done

sleep 0.5

echo "Make protein coding five_prime_utr arch 8/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ five_prime_utr -i transcript_biotype=protein_coding ; done

sleep 0.5

echo "Make non-protein coding five_prime_utr arch 9/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ five_prime_utr -e transcript_biotype=protein_coding ; done

sleep 0.5

echo "Make three_prime_utr arch 10/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ three_prime_utr ; done

sleep 0.5

echo "Make protein coding three_prime_utr arch 11/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ three_prime_utr -i transcript_biotype=protein_coding ; done

sleep 0.5

echo "Make non-protein coding three_prime_utr arch 12/12"
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ three_prime_utr -e transcript_biotype=protein_coding ; done

