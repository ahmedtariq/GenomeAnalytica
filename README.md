# genome_architecture

## Package Description
This is a package that provide tools to extract different genome architecture features, build taxonomy lineage and test features against certain value in taxonomy rank in fully automated pipeline.
## Flow
<p align="center" >
<img src="https://user-images.githubusercontent.com/32236950/108633099-15c58e00-747b-11eb-8488-8cc80f0a9c8e.png" />
</p>

1.	Make data directory and under it make raw directory under it make directory for each species and create a txt file containing 2 ftp links 1 for species genome gtf file and another for species genome fasta file like the following tree: <br>
data <br>
├── raw <br>
   ├── Caenorhabditis_elegans <br>
   │   └── WgetMe.txt <br>
   ├── Choloepus_hoffmanni <br>
   │   └── WgetMe.txt <br>
   ├── Chrysolophus_pictus <br>
   │   └── WgetMe.txt <br>
   ├── Ciona_intestinalis <br>
   │   └── WgetMe.txt <br>
   ├── Ciona_savignyi <br>
   │   └── WgetMe.txt <br>
   ├── Drosophila_melanogaster <br>
   │   └── WgetMe.txt <br>
   ├── Homo_sapiens <br>
   │   └── WgetMe.txt <br>
   ├── Monopterus_albus <br>
   │   └── WgetMe.txt <br>
   ├── Mus_musculus <br>
   │   └── WgetMe.txt <br>
   └── Saccharomyces_cerevisiae <br>
       └── WgetMe.txt <br>
2.	Download and unzip the data at each corresponding directory using the following command.
```sh
$ ./get_data.sh data/raw WgetMe.txt
```
3.	Make features for all species under data/raw. Can be done either using a **Fast Method** mode or **Expert User** mode 
* Fast Method: <br>
e.g: creating statistics for (all, protein coding, non protein coding) for (gene, exon, transcript, three_prime_utr, five_prime_utr) <br>
```sh
$ ./make_arch_fet.sh data/raw/ g pg npg e pe npe t pt npt f pf npf h ph nph
```
* Expert User: <br>
e.g: creating statistics for protein coding exons <br>
```sh
for i in `ls data/raw/`; do echo $i; ./get_len_gc.sh data/raw/$i/ exon -i transcript_biotype=protein_coding ; done
```
4.	Make taxonomy lineage for all species under data/raw using the following command
```sh
$ ./make_tax.sh data/raw/ tax_mapping.csv
```
5.	Make test for calculated feature under data/output using the taxonomy lineage and specifying the 10th rank (supphilum) and (vertebrata) as the value to compare against using the following command:
```sh
$ ./make_arch_test.py --stats data/output/ --tax data/tax_mapping.csv --tax_value vertebrata
```
## User Manual
The package consists of three main commands to build standard features, build mapping and test them supplementary commands are available to batch download ftp links and build custom genome architecture features.
### Supplementary Commands
1.	[get_data](https://github.com/ahmedtariq/genome_architecture/blob/master/get_data.sh)
*	Description: <br>
This script loop throw the species directories under user specified species containing directory; reading the user specified text file containing the ftp links for gtf and fasta then unzip them
*	Positional Arguments <br>
There are 2 mandatory arguments <br>
arg1: the directory containing the species directories <br>
arg2: the name of the files that contains the ftp link to download <br>
*	Example: <br>
```sh
$ ./get_data.sh data/raw WgetMe.txt
```
2.	[get_len_gc](https://github.com/ahmedtariq/genome_architecture/blob/master/get_len_gc.sh)
*	Description <br>
This module gets stats (avg gc content, avg length and count ) for a custom user specified feature and filtration in a gtf file. Features extracted can differ from those served out of the box in make_arch_fet.
*	Positional Arguments <br>
There are 2 mandatory arguments : <br>
arg1: the path to directory containing the species gtf and fasta files (uncompressed) with the following hirarchy: raw/species/ e.g (data/raw/Homo_Sapiens) <br>
arg2: the feature that will be filtered for stats. this feature should exist in column 3 gtf file. e.g (exon, gene, transcript) <br>
There are 2 optional arguments to be used when you want to filter certain tag in column 9 gtf: <br>
arg3: a flag to include or exclude the following (tag=value) argument. to include use -i , to exclude use -e <br>
arg4: the name of the tag you want to filter tigetherr with the filtering value in the form of (tag=value). e.g (-i gene_biotype=protein_coding) <br>
*	Example: <br>
 + to calculate the stats of all genes of Homo Sapiens use the following
```sh
$ bash get_len_gc.sh dat/raw/Homo_Sapiens gene
```
 + to calculate the stats of exons coming from non-protein coding transcript of Homo Sapiens use the following
```sh
$ bash get_len_gc.sh dat/raw/Homo_Sapiens exon -e transcript_biotype=proteing_coding
```
### Main Commands
3.	[make_arch_fet](https://github.com/ahmedtariq/genome_architecture/blob/master/make_arch_fet.sh) <br>
*	Description <br>
This script generalize applying stats like (avg gc content, avg length, count ) for all species under user input containing dir given that each species dir contains gtf and fasta file for species genome
*	Positional Arguments <br>
There are minimum 2 mandatory arguments : <br>
arg1: the path to directory containing all the species directories containing gtf and fasta files (uncompressed). Dir must be named raw e.g (data/raw/) <br>
arg2,3,4,...: 1 to 3 characters representing the features that will be filtered for stats. with the following naming: <br>
      filtration criteria: can be: <br>
                              p for pretein coding or <br>
                              np for non proteing coding <br>
      feature type: can be: <br>
                           g for gene <br>
                           e for exon <br>
                           t for transcript <br>
                           f for five_prime_utr <br>
                           h for three_prime_utr <br>
     e.g pg for protein coding gene; npt for non protein coding three_prime_utr <br>
*	Example: <br>
to calculate the stats of (non protein coding genes, protein coding exons and all five_prime_utr) for all species under data/raw/ use the following
```sh
$ ./ make_arch_fet.sh data/raw/ npg pe f
```
To calculate all features
```sh
$ ./make_arch_fet.sh data/raw/ g pg npg e pe npe t pt npt f pf npf
```
4.	[make_tax](https://github.com/ahmedtariq/genome_architecture/blob/master/make_tax.sh)
*	Description <br>
This script loop throw the species directories under user specified species contining directory; using the species dir naming the taxonomy lineage record is retrieved from ncbi, appended in csv file and saved in user specified file
*	Positional Arguments <br>
There are 2 mandatory arguments <br>
arg1: the directory containing the species directories <br>
arg2: the name of the taxonomy mapping csv file to be saved <br>
*	Example: <br>
```sh
$ ./make_tax.sh data/raw/ tax_mapping.csv
```
5.	[make_arch_test](https://github.com/ahmedtariq/genome_architecture/blob/master/make_arch_test.py)
*	Description <br>
This script takes the path for data created by make_arch_fet, path for species lineage csv created by make_tax, rank value to test againist. 
Count the nulls (which is filled with 0 and returned as 0_count) in each feature, applies 2 sample 2 tailed ttest and Manwhetney, correct using benferroni and returns <br>
i.	parsed data architicture feature in 1 csv <br>
ii.	test results containing (feature,0_count,avg_[rank_value],avg_non_[rank_value],MannWhitney_p,ttest_p,MannWhitney_adj_p,ttest_adj_p,MannWhitney_adj_reject,ttest_adj_reject) <br>
iii.	filtered parsed data architicture features for only significant ones according to corrected p-value < 0.05 <br>
*	Named Arguments: <br>
-h, --help: show this help message and exit <br>
--stats [STATS]: Directory containning the nested csv stats for all species in form of (species, stats) <br>
--tax [TAX]: File csv contianing the full lineage of all species in stats <br>
--out_test [OUT_TEST]: File to write the test results <br>
--out_parsed [OUT_PARSED]: File to write parsed data <br>
--out_parsed_filtered [OUT_PARSED_FILTERED]: File to write parsed data with filtered significant features <br>
--out_fig [OUT_FIG]   png File to write boxplot figure <br>
--tax_value [RANK_VALUE]: value to test for in the tax rank e.g: Vertebrata to test Vert vs In-Vert in Subphylum <br>
*	Example: <br>
```sh
$ ./make_arch_test.py --stats data/output/ --tax data/tax_mapping.csv --tax_value vertebrata
```
## Output
* test results

| feature      | 0_count | avg_vertebrata     | avg_non_vertebrata     | MannWhitney_p     | ttest_p     | MannWhitney_adj_p     | ttest_adj_p     | MannWhitney_adj_reject     | ttest_adj_reject     |
| :---        |    :----:   |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |
| gene_-i_gene_biotype=protein_coding_count | 0 | 17616.4 | 12821.4 | 0.000145036 | 4.61E-08 | 0.005221295 | 1.66E-06 | TRUE | TRUE |
| exon_-e_transcript_biotype=protein_coding_avg_len | 0 | 247.5974 | 382.6778 | 0.000145036 | 3.91E-05 | 0.005221295 | 0.001405841 | TRUE | TRUE |

* siginificant features boxplot <br>
<p align="center" >
<img src="https://user-images.githubusercontent.com/32236950/108633175-85d41400-747b-11eb-86d4-376344d2741e.png" />
</p>


