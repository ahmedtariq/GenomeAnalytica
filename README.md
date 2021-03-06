# genomeAnalytics

<p align="center" >
<img src="https://user-images.githubusercontent.com/32236950/110198038-42ed4580-7e58-11eb-9d37-f44c2f330f94.png" width="100" height="100" />
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#package-description">Package Description</a></li>
    <li><a href="#flow">Flow</a></li>
    <li><a href="#end-to-end-demo">End to End Demo</a></li>
    <li>
      <a href="#user-manual">User Manual</a>
      <ul>
        <li><a href="#supplementary-commands">Supplementary Commands</a></li>
        <li><a href="#main-commands">Main Commands</a></li>
      </ul>
    </li>
    <li><a href="#output">Output</a></li>
    <li><a href="#contributors">Contributors</a></li>
  </ol>
</details>

## Package Description
This is a package that provide tools to extract different genome architecture features, build taxonomy lineage and test features against certain value in taxonomy rank in fully automated pipeline. <br>
<br>
The package is very user friendly allowing users to ask question like:
- Does Vertebrates have a significant GC content than other species ?
- What are the genome architecture features that significant in Eukaryotes ?
- What are the features that signifies Betacoronavirus from other Riboviria ?

[Output](#output) of the genomeAnalytica package is a csv similar to common deferential expression experiments (features with adjusted p-values and averages) and a boxplot figures for significant features. <br>

The package is providing an end to end dedicative pipeline for investigating genomic architecture features which is unique to this package as far as we know.

## Flow

<p align="center" >
<img src="https://user-images.githubusercontent.com/32236950/108965788-05353380-7686-11eb-8a5c-7a8f8564968a.png" />
</p>


## Prerequisites
1. Option 1 - Manual <br>
Download and install the latest version of the following. <br>
* BASH <br>
[bedtools](https://anaconda.org/bioconda/bedtools) <br>
[entrez-direct](https://anaconda.org/bioconda/entrez-direct) <br>
* Python <br>
[pandas](https://anaconda.org/anaconda/pandas) <br>
[scipy](https://anaconda.org/anaconda/scipy) <br>
[statsmodels](https://anaconda.org/anaconda/statsmodels) <br>
[matplotlib](https://anaconda.org/conda-forge/matplotlib) <br>
[seaborn](https://anaconda.org/anaconda/seaborn) <br>

2. Option 2 - Automated <br>
Make conda environment and use the requirements.txt to install needed libraries
```sh
$ conda create --name <env_name> --file requirements.txt
```
```sh
$ conda activate <env_name>
```


## End to End Demo
1.	Make data directory and under it make raw directory under it make directory for each species and create a txt file containing 2 ftp links 1 for species genome gtf file and another for species genome fasta file like the following tree: <br>
```sh
data
├── raw
   ├── Caenorhabditis_elegans
   │   └── WgetMe.txt
   ├── Choloepus_hoffmanni
   │   └── WgetMe.txt
   ├── Chrysolophus_pictus
   │   └── WgetMe.txt
   ├── Ciona_intestinalis
   │   └── WgetMe.txt
   ├── Ciona_savignyi
   │   └── WgetMe.txt
   ├── Drosophila_melanogaster
   │   └── WgetMe.txt
   ├── Homo_sapiens
   │   └── WgetMe.txt
   ├── Monopterus_albus
   │   └── WgetMe.txt
   ├── Mus_musculus
   │   └── WgetMe.txt
   └── Saccharomyces_cerevisiae
       └── WgetMe.txt
```
For using the same species as above just download from [data](https://github.com/ahmedtariq/genome_architecture/tree/master/data)

2.	Download and unzip the data at each corresponding directory using the following command.
```sh
$ ./get_data.sh data/raw WgetMe.txt
```

3.	Make features for all species under data/raw. Can be done either using a **Fast Mode** mode or **Expert Mode** mode 
* Option 1 - Fast Mode: <br>
e.g: creating statistics for (all, protein coding, non protein coding) for (gene, exon, transcript, three_prime_utr, five_prime_utr) <br>
```sh
$ ./make_arch_fet.sh data/raw/ g pg npg e pe npe t pt npt f pf npf h ph nph
```
* Option 2 - Expert Mode: <br>
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

<p align="left" >
<img src="https://user-images.githubusercontent.com/32236950/108965803-09615100-7686-11eb-9f99-5592a339d11f.png" />
</p>

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

<p align="left" >
<img src="https://user-images.githubusercontent.com/32236950/108965815-0cf4d800-7686-11eb-871d-e14fbbebc172.png" />
</p>

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

<p align="left" >
<img src="https://user-images.githubusercontent.com/32236950/108965838-14b47c80-7686-11eb-923f-364bd3d43c79.png" />
</p>

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

<p align="left" >
<img src="https://user-images.githubusercontent.com/32236950/108965891-23029880-7686-11eb-8f8e-d0eda7d2357c.png" />
</p>

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


##  <a name="output">Output</a>
* test results

| feature      | 0_count | avg_vertebrata     | avg_non_vertebrata     | MannWhitney_p     | ttest_p     | MannWhitney_adj_p     | ttest_adj_p     | MannWhitney_adj_reject     | ttest_adj_reject     |
| :---        |    :----:   |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |          ---: |
| gene_-i_gene_biotype=protein_coding_count | 0 | 17616.4 | 12821.4 | 0.000145036 | 4.61E-08 | 0.005221295 | 1.66E-06 | TRUE | TRUE |
| exon_-e_transcript_biotype=protein_coding_avg_len | 0 | 247.5974 | 382.6778 | 0.000145036 | 3.91E-05 | 0.005221295 | 0.001405841 | TRUE | TRUE |

* siginificant features boxplot <br>
<p align="center" >
<img src="https://user-images.githubusercontent.com/32236950/108633175-85d41400-747b-11eb-86d4-376344d2741e.png" />
</p>


## Contributors
[Ahmed Tarek](https://github.com/ahmedtariq) <br>
[Abdullah Alkhawaja](https://github.com/Alkhawaja95) <br>
[Ali El-Nisr](https://github.com/El-Nisr) <br>
[Montaser Bellah Yasser](https://github.com/montaserbellahyasser) <br>
