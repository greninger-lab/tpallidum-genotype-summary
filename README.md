# tpallidum-variant-calling

Syphilis is surging worldwide, with more than 8 million incident cases per year and causing more than 220,000 fetal and infant deaths from congenital syphilis, underscoring the urgent need to develop a vaccine. Recently, hybrid capture whole genome sequencing (WGS) of the causative organism, _Treponema pallidum_ subspecies _pallidum_, has enabled cataloging of antigen sequences directly from clinical samples.  

 _Treponema pallidum_ is a fastidious Gram negative spirochete with a single 1.14 Mb syntenic chromosome. It has no known plasmids, phage, transposons or other mobile genetic elements. _T. pallidum_ includes subspecies _pallidum_, _pertenue_, and _endemicum_, which are morphologically indistinguishable and cause venereal syphilis, yaws, and endemicum, respectively. With 99.8% pairwise identity between the subspecies, genomics approaches are broadly applicable across _T. pallidum_.  

**The purpose of this pipeline is to perform standardized Treponema pallidum genome assembly and variant calling using raw Illumina paired-end sequencing reads as input.** It incorporates best practices learned since hybrid capture techniques have enabled whole genome sequencing directly from clinical samples. These include masking of known recombinant loci and regions with poor assembly expected such as in homopolymers, and extensive filtering of contaminating 23S rRNA reads from other bacteria present in the sample. Using default pipeline settings, the _T. pallidum_ subsp. _pallidum_ SS14 reference sequence (NC_021508) will be used for assembly, or users can specify use of the SamoaD _T. pallidum_ subspecies _pertenue_ reference sequence (NC_016842). (Options for additional reference sequences, including the _T. pallidum_ subsp. _pallidum_ Nichols strain (NC_021490), are coming soon.)  

Pre-processing of reads is first performed to remove human reads and contaminating rRNA and tRNA loci from other bacteria using Kraken2 followed by adapter and quality trimming with trimmomatic. Reads are then mapped using bowtie2 to the selected reference sequence (SS14 by default), deduplicated, downsampled to a maximum of 2 million read pairs, and variants called using GATK HaplotypeCaller. Using a threshold requiring a minimum of three reads and allele frequency exceeding 0.8, joint genotyping and variant filtration is performed using a combination of GATK and bcftools.  

In addition to bams, output files include:  
* filtered multi-sample vcf including all passing variants, with masked regions marked in the vcf FILTER field  
* filtered multi-sample vcf including only core genome SNPs, appropriate for phylogenetic analyses 
* flat file containing per-sample summary statistics  

##### Input sample_fastqs.csv example format:
---------
    sample,fastq_1,fastq_2
    SAMPLE1,/PATH/TO/SAMPLE1_R1.fastq.gz,/PATH/TO/SAMPLE1_R2.fastq.gz
    SAMPLE2,/PATH/TO/SAMPLE2_R1.fastq.gz,/PATH/TO/SAMPLE2_R2.fastq.gz
---------

# Running tpallidum-variant-calling

    nextflow run greninger-lab/tpallidum-variant-calling -r main -latest --input <sample_fastqs.csv> --outdir ./out --ref NC_021508 --kraken_host_db 'path/to/Kraken2_human/k2_human/' --kraken_standard_db 'path/to/Kraken2_standard_16GB/k2_standard_16gb_20240904/' --ivar -profile docker
## Command line options
| option | description | 
|--------|-------------|
| `--input  /path/to/your/sample_fastqs.csv` | (required) path to a csv sample,fastq_1,fastq_2 input file |
| `--outdir /path/to/output`                | (required) output directory |
| `--ref <string>`        | (required) Currently supported references are either NC_021508 or NC_016842 | 
| `--kraken_host_db <path>`        | (required) path to Kraken2 human host DB |
| `--kraken_standard_db <path>`        | (required) path to Kraken2_standard_16GB DB |
| `--ivar`        | (optional) run iVar variant calling |
| `-profile docker`                         | (required) |
| `-c /path/to/your/custom.config`          | (optional) used specify a custom configuration file (see [Nextflow docs](https://www.nextflow.io/docs/latest/config.html)) |

# tpallidum-genotype-summary
