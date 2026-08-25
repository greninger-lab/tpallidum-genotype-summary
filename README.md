# tpallidum-genotype-summary

Syphilis is surging worldwide, with more than 8 million incident cases per year and causing more than 220,000 fetal and infant deaths from congenital syphilis, underscoring the urgent need to develop a vaccine. Recently, hybrid capture whole genome sequencing (WGS) of the causative organism, _Treponema pallidum_ subspecies _pallidum_, has enabled cataloging of antigen sequences directly from clinical samples.  

 _Treponema pallidum_ is a fastidious Gram negative spirochete with a single 1.14 Mb syntenic chromosome. It has no known plasmids, phage, transposons or other mobile genetic elements. _T. pallidum_ includes subspecies _pallidum_, _pertenue_, and _endemicum_, which are morphologically indistinguishable and cause venereal syphilis, yaws, and endemicum, respectively. With 99.8% pairwise identity between the subspecies, genomics approaches are broadly applicable across _T. pallidum_.  

**The purpose of this pipeline is to perform standardized Treponema pallidum variant calling by creating or updating a GenomicsDB workspace using GVCF files as input, and then genotyping followed by filtering. **  

##### Input sample_gvcfs.csv example format:
---------
    sample,gvcf
    CP001752,variants_replace_pl_20260610/CP001752_remap_reheadered.g.vcf.gz
    CP002374,variants_replace_pl_20260610/CP002374_remap_reheadered.g.vcf.gz
---------

# tpallidum-genotype-summary

    nextflow run greninger-lab/tpallidum-variant-calling -r main -latest --input <sample_gvcfs.csv> --outdir ./out --ref NC_021508 --kraken_host_db 'path/to/Kraken2_human/k2_human/' --kraken_standard_db 'path/to/Kraken2_standard_16GB/k2_standard_16gb_20240904/' --ivar -profile docker
## Command line options
| option | description | 
|--------|-------------|
| `--input  /path/to/your/sample_gvcfs.csv` | (required) path to a csv sample,gvcf input file |
| `--outdir /path/to/output`                | (required) output directory |
| `--ref <string>`        | (required) Currently supported references are either NC_021508 or NC_016842 | 
| `--run_updatewspace`        | (optional) flag to tell GenomicsDB module to update workspace |
| `--wspace <path>`        | (optional) path to GenomicsDB workspace to update |
| `-profile docker`                         | (required) |
| `-c /path/to/your/custom.config`          | (optional) used to specify a custom configuration file (see [Nextflow docs](https://www.nextflow.io/docs/latest/config.html)) |


