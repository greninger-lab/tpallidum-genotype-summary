/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowTpgenotype.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config           = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config    = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo             = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

ch_replace_pl_r             = Channel.fromPath("$projectDir/bin/replace_pl.py", checkIfExists: true)
ch_repair_depth             = Channel.fromPath("$projectDir/bin/repair_depth.py", checkIfExists: true)
ch_make_chunks              = Channel.fromPath("$projectDir/bin/make_chunks.sh", checkIfExists: true)
ch_calculate_percent_no_gt  = Channel.fromPath("$projectDir/bin/calculate_percent_no_gt.py", checkIfExists: true)
ch_generate_phylo_mask_bed  = Channel.fromPath("$projectDir/bin/generate_phylo_mask_bed.py", checkIfExists: true)
ch_calculate_no_call_stats  = Channel.fromPath("$projectDir/bin/calculate_no_call_stats.py", checkIfExists: true)
//ch_gvcf_list                = Channel.fromPath("$projectDir/assets/gvcfs.list", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    REFERENCE FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_all_SS14_rna             = Channel.fromPath( "$projectDir/assets/ref/all_SS14_rna.fasta" )
ch_rrna                     = Channel.fromPath( "$projectDir/assets/ref/rrna.fasta" )
ch_trna                     = Channel.fromPath( "$projectDir/assets/ref/trna.fasta" )

ch_fasta                    = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".fasta" )
ch_fasta_fai                = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".fasta.fai" )
ch_gff                      = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".gff" )
ch_dict                     = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".dict" )

ch_no_rRNA1_fasta           = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + "_no_rRNA1.fasta" )

ch_mask_v4                  = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + "_mask_v4.bed" )
ch_mask_v4_idx              = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + "_mask_v4.bed.idx" )
ch_exclude                  = Channel.fromPath( "$projectDir/assets/ref/exclude.txt" )

/*
* Derive whole-contig interval from Picard/GATK dict
*/
def dictFile = file("$projectDir/assets/ref/" + params.ref + ".dict")
def sqLine = dictFile.readLines()
                    .find { it.startsWith('@SQ') }
def fields = sqLine.split('\t')
def sn = fields.find { it.startsWith('SN:') }?.substring(3)
def ln = fields.find { it.startsWith('LN:') }?.substring(3)
def interval = "${sn}:1-${ln}"

log.info "Using interval: ${interval}"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK                                    } from '../subworkflows/local/input_check'
include { KRAKEN2_EXTRACT                                } from '../modules/local/kraken2_extract'
include { BBMAP_REPAIR                                   } from '../modules/local/bbmap_repair'
include { SUBSAMPLE                                      } from '../modules/local/subsample'
include { IVAR_VARIANT                                   } from '../modules/local/ivar_variant'
include { BEDTOOLS_COVERAGE                              } from '../modules/local/bedtools_coverage'
include { REPLACE_PL                                     } from '../modules/local/replace_pl'
include { REPAIR_DP                                      } from '../modules/local/repair_dp'
include { BCFTOOLS as BCFTOOLS_GT_UNFILTERED             } from '../modules/local/bcftools'
include { BCFTOOLS as BCFTOOLS_GT_FILTERED_DP            } from '../modules/local/bcftools'
include { BCFTOOLS as BCFTOOLS_VIEW_SNP                  } from '../modules/local/bcftools'
include { BCFTOOLS as BCFTOOLS_VIEW_FILTER_MASK          } from '../modules/local/bcftools'
include { VARIANTS_TO_TABLE as VARIANTS_TO_TABLE_NOCALL  } from '../modules/local/variants_to_table'
include { VARIANTS_TO_TABLE as VARIANTS_TO_N25_SNPS      } from '../modules/local/variants_to_table'
include { VARIANTS_TO_TABLE as VARIANTS_TABLE_FOR_PHYLO  } from '../modules/local/variants_to_table'
include { PERCENT_NO_GENOTYPE                            } from '../modules/local/percent_no_genotype'
include { SPLIT_VCF                                      } from '../modules/local/split_vcf'
include { GENERATE_POS_MASK_BED                          } from '../modules/local/generate_pos_mask_bed'
include { MAKE_CHUNKS                                    } from '../modules/local/make_chunks'
include { SUMMARY                                        } from '../modules/local/summary'
include { SUMMARY_FINAL                                  } from '../modules/local/summary_final'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { BOWTIE2_BUILD                                                      } from '../modules/nf-core/bowtie2/build/main'
include { BOWTIE2_BUILD as BOWTIE2_BUILD_NO_RRNA                             } from '../modules/nf-core/bowtie2/build/main'
include { TRIMMOMATIC                                                        } from '../modules/nf-core/trimmomatic/main'
include { KRAKEN2_KRAKEN2 as KRAKEN2_REMOVE_HUMAN                            } from '../modules/nf-core/kraken2/kraken2/main'
include { KRAKEN2_KRAKEN2                                                    } from '../modules/nf-core/kraken2/kraken2/main'
include { BBMAP_BBDUK as BBDUK_GENOMIC                                       } from '../modules/nf-core/bbmap/bbduk/main'
include { BBMAP_BBDUK as BBDUK_RRNA                                          } from '../modules/nf-core/bbmap/bbduk/main'
include { BBMAP_BBDUK as BBDUK_TRNA                                          } from '../modules/nf-core/bbmap/bbduk/main'
include { BOWTIE2_ALIGN as BOWTIE2_ALIGN_GENOMIC                             } from '../modules/nf-core/bowtie2/align/main'
include { BOWTIE2_ALIGN as BOWTIE2_ALIGN_RRNA                                } from '../modules/nf-core/bowtie2/align/main'
include { BOWTIE2_ALIGN as BOWTIE2_ALIGN_TRNA                                } from '../modules/nf-core/bowtie2/align/main'
include { SAMTOOLS_MERGE                                                     } from '../modules/nf-core/samtools/merge/main'
include { PICARD_MARKDUPLICATES                                              } from '../modules/nf-core/picard/markduplicates/main'
include { PICARD_ADDORREPLACEREADGROUPS                                      } from '../modules/nf-core/picard/addorreplacereadgroups/main'
include { GATK4_HAPLOTYPECALLER                                              } from '../modules/nf-core/gatk4/haplotypecaller/main'
include { GATK4_HAPLOTYPECALLER as GATK4_HAPLOTYPECALLER_REMAP               } from '../modules/nf-core/gatk4/haplotypecaller/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_DEPTH           } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_PHYLO           } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_HAPLOTYPECALLER as GATK4_HAPLOTYPECALLER_CONSENSUS           } from '../modules/nf-core/gatk4/haplotypecaller/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_PHYLO_CONSENSUS } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_INDEXFEATUREFILE                                             } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_INDEXFEATUREFILE as GATK4_INDEX_GT_FILTERED_DP               } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_INDEXFEATUREFILE as GATK4_INDEX_MASKED_SNPS                  } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_GT_AF08DP3      } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_COMBINEGVCFS                                                 } from '../modules/nf-core/gatk4/combinegvcfs/main'  
include { GATK4_GENOTYPEGVCFS                                                } from '../modules/nf-core/gatk4/genotypegvcfs/main'
include { GATK4_SELECTVARIANTS as GATK4_SELECTVARIANTS_MASKED_SNPS           } from '../modules/nf-core/gatk4/selectvariants/main'
include { GATK4_SELECTVARIANTS as GATK4_SELECTVARIANTS_PHYLOMARKED           } from '../modules/nf-core/gatk4/selectvariants/main'   
include { TABIX_BGZIP                                                        } from '../modules/nf-core/tabix/bgzip/main'
include { TABIX_TABIX                                                        } from '../modules/nf-core/tabix/tabix/main'
include { BCFTOOLS_CONSENSUS                                                 } from '../modules/nf-core/bcftools/consensus/main'
include { SEQKIT_STATS as SEQKIT_STATS_RAW                                   } from '../modules/nf-core/seqkit/stats/main'
include { SEQKIT_STATS as SEQKIT_STATS_TRIM                                  } from '../modules/nf-core/seqkit/stats/main'
include { GATK4_REBLOCKGVCF                                                  } from '../modules/nf-core/gatk4/reblockgvcf/main' 
include { GATK4_GENOMICSDBIMPORT                                             } from '../modules/nf-core/gatk4/genomicsdbimport/main'


// include { FASTQC                      } from '../modules/nf-core/fastqc/main'
// include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
// include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow TPGENOTYPE {
    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //

    INPUT_CHECK (
        file(params.input)
    )

    REPLACE_PL (
        INPUT_CHECK.out.gvcf,
        INPUT_CHECK.out.gvcf.combine(ch_replace_pl_r).map{ [it[2]] }
    )

    TABIX_BGZIP (
        REPLACE_PL.out.vcf
    )    

    GATK4_INDEXFEATUREFILE (
        TABIX_BGZIP.out.output
    )

    GATK4_REBLOCKGVCF (
        TABIX_BGZIP.out.output.join(GATK4_INDEXFEATUREFILE.out.index).map{ [it[0], [it[1]], [it[2]], []] },
        TABIX_BGZIP.out.output.combine(ch_fasta).map{ [it[2]] },
        TABIX_BGZIP.out.output.combine(ch_fasta_fai).map{ [it[2]] },
        TABIX_BGZIP.out.output.combine(ch_dict).map{ [it[2]] },
        [],
        []      
    )
    // Use this, it will append /mnt/s3 if batch config has a mountpoint
    // and --use_mountpoint = true
    // GATK4_REBLOCKGVCF.out.vcf
    //     .map { meta, vcf, tbi -> 
    //         def path = params.use_mountpoint ? "/mnt/s3${vcf}" : "${vcf}"
    //         "${meta.id}\t${path}"
    //     }
    //     .collectFile(
    //         name: 'sample_map.tsv',
    //         newLine: true,
    //         sort: false
    //     )
    //     .set { ch_sample_map }

    GATK4_REBLOCKGVCF.out.vcf
        .map { meta, vcf, tbi -> "${meta.id}\t/mnt/s3${vcf}" }
        .collectFile(
            name: 'sample_map.tsv',
            newLine: true,
            sort: false
        )
        .set { ch_sample_map }

    ch_meta    = Channel.of([id: 'final'])
    ch_interval = Channel.value(interval)

    // tuple val(meta), path(vcf), path(tbi), path(interval_file), val(interval_value), path(wspace)
    if (params.run_updatewspace && params.wspace) {
        ch_meta
            .combine(ch_sample_map)
            .map { meta, map -> [ meta, [map], [], [], interval, [params.wspace] ] }
            .set { ch_import }
    } else {
        ch_meta
            .combine(ch_sample_map)
            .map { meta, map -> [ meta, [map], [], [], interval, [] ] }
            .set { ch_import }
    }

    ch_import.view { "CH_INPUT: sample_map=${it[1]}" }

    GATK4_GENOMICSDBIMPORT (
        ch_import,
        false,
        params.run_updatewspace,
        true        // <-- input_map = true, triggers --sample-name-map
    )

    if (params.run_updatewspace && params.wspace) {
       GATK4_GENOMICSDBIMPORT.out.updatedb.map{ [it[0], it[1], [], [], []] }.set{ ch_db }
    } else {
        GATK4_GENOMICSDBIMPORT.out.genomicsdb.map{ [it[0], it[1], [], [], []] }.set{ ch_db }
    }
    
    GATK4_GENOTYPEGVCFS (
        ch_db,
        ch_fasta,
        ch_fasta_fai,
        ch_dict
    )

    REPLACE_PL.out.vcf
    .map { meta, vcf -> "${meta.id}\t/mnt/s3${vcf}" }
    .collectFile(
        name: 'gvcf_map.tsv',
        newLine: true,
        sort: false
    )
    .set { ch_gvcf_map }

    REPAIR_DP (
        GATK4_GENOTYPEGVCFS.out.vcf,
        ch_gvcf_map,
        ch_repair_depth
    )

    BCFTOOLS_GT_UNFILTERED (
        REPAIR_DP.out.vcf
    )

    // make DP and AF params
    BCFTOOLS_GT_FILTERED_DP (
        BCFTOOLS_GT_UNFILTERED.out.vcf
    )

    GATK4_INDEX_GT_FILTERED_DP (
        BCFTOOLS_GT_FILTERED_DP.out.vcf
    )
    
    GATK4_VARIANTFILTRATION_GT_AF08DP3 (
        BCFTOOLS_GT_FILTERED_DP.out.vcf.join(GATK4_INDEX_GT_FILTERED_DP.out.index).map{ [it[0], [it[1]], [it[2]]] },
        BCFTOOLS_GT_FILTERED_DP.out.vcf.combine(ch_fasta).map{ [it[0],[it[2]]]},
        BCFTOOLS_GT_FILTERED_DP.out.vcf.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        BCFTOOLS_GT_FILTERED_DP.out.vcf.combine(ch_dict).map{ [it[0],[it[2]]]},
        BCFTOOLS_GT_FILTERED_DP.out.vcf.combine(ch_mask_v4).map{ [it[0],[it[2]]]},
        BCFTOOLS_GT_FILTERED_DP.out.vcf.combine(ch_mask_v4_idx).map{ [it[0],[it[2]]]}        
    )

    BCFTOOLS_VIEW_SNP (
        GATK4_VARIANTFILTRATION_GT_AF08DP3.out.vcf
    )

    BCFTOOLS_VIEW_FILTER_MASK (
        BCFTOOLS_VIEW_SNP.out.vcf
    )

    GATK4_INDEX_MASKED_SNPS (
        BCFTOOLS_VIEW_FILTER_MASK.out.vcf
    )

    VARIANTS_TO_TABLE_NOCALL (
        BCFTOOLS_VIEW_FILTER_MASK.out.vcf.join(GATK4_INDEX_MASKED_SNPS.out.index).map{ [it[0], [it[1]], [it[2]]] }
    )

    PERCENT_NO_GENOTYPE (
        VARIANTS_TO_TABLE_NOCALL.out.txt,
        ch_exclude,
        ch_calculate_percent_no_gt
    )

/*
    GATK4_SELECTVARIANTS_MASKED_SNPS (
        BCFTOOLS_VIEW_FILTER_MASK.out.vcf.join(GATK4_INDEX_MASKED_SNPS.out.index).join(PERCENT_NO_GENOTYPE.out.n25)
    )

    GATK4_SELECTVARIANTS_PHYLOMARKED   (
        GATK4_VARIANTFILTRATION_GT_AF08DP3.out.vcf.join(GATK4_VARIANTFILTRATION_GT_AF08DP3.out.tbi).join(PERCENT_NO_GENOTYPE.out.n25)
    )

    VARIANTS_TO_N25_SNPS (
        GATK4_SELECTVARIANTS_MASKED_SNPS.out.vcf.join(GATK4_SELECTVARIANTS_MASKED_SNPS.out.tbi).map{ [it[0], [it[1]], [it[2]]] }
    )

    SPLIT_VCF (
        GATK4_SELECTVARIANTS_PHYLOMARKED.out.vcf
    )

    VARIANTS_TABLE_FOR_PHYLO (
       GATK4_VARIANTFILTRATION_GT_AF08DP3.out.vcf.join(GATK4_VARIANTFILTRATION_GT_AF08DP3.out.tbi)
    )

    GENERATE_POS_MASK_BED (
        VARIANTS_TABLE_FOR_PHYLO.out.txt,
        ch_generate_phylo_mask_bed
    )

    MAKE_CHUNKS (
        SPLIT_VCF.out.vcfs.join(GENERATE_POS_MASK_BED.out.bed),
        ch_fasta,
        ch_fasta_fai,
        ch_dict,
        ch_make_chunks
    )
*/
/*
    GATK4_HAPLOTYPECALLER (
        SUBSAMPLE.out.bam.join(SUBSAMPLE.out.bai).map{ [it[0], [it[1]], [it[2]], [], []] },
        SUBSAMPLE.out.bam.combine(ch_fasta).map{ [it[0],[it[2]]]},
        SUBSAMPLE.out.bam.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        SUBSAMPLE.out.bam.combine(ch_dict).map{ [it[0],[it[2]]]},
        [[],[]],
        [[],[]]      
    )
*/
/*
    GATK4_VARIANTFILTRATION_DEPTH (
        GATK4_HAPLOTYPECALLER.out.vcf.join(GATK4_HAPLOTYPECALLER.out.tbi).map{ [it[0], [it[1]], [it[2]]] },
        GATK4_HAPLOTYPECALLER.out.vcf.combine(ch_fasta).map{ [it[0],[it[2]]]},
        GATK4_HAPLOTYPECALLER.out.vcf.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        GATK4_HAPLOTYPECALLER.out.vcf.combine(ch_dict).map{ [it[0],[it[2]]]},
        [[],[]],
        [[],[]]  
    )

    GATK4_VARIANTFILTRATION_PHYLO (
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.join(GATK4_VARIANTFILTRATION_DEPTH.out.tbi).map{ [it[0], [it[1]], [it[2]]] },
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.combine(ch_fasta).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.combine(ch_dict).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.combine(ch_mask).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH.out.vcf.combine(ch_mask_idx).map{ [it[0],[it[2]]]}
    )    
*/

/*
    GATK4_HAPLOTYPECALLER_CONSENSUS (
        SUBSAMPLE.out.bam.join(SUBSAMPLE.out.bai).map{ [it[0],[it[1]], [it[2]], [], []] },
        SUBSAMPLE.out.bam.combine(ch_fasta).map{ [it[0],[it[2]]]},
        SUBSAMPLE.out.bam.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        SUBSAMPLE.out.bam.combine(ch_dict).map{ [it[0],[it[2]]]},
        [[],[]],
        [[],[]]      
    )


    SEQKIT_STATS_RAW.out.stats
        .join(SEQKIT_STATS_TRIM.out.stats)
        .join(KRAKEN2_REMOVE_HUMAN.out.report)
        .join(BOWTIE2_ALIGN_GENOMIC.out.bam)
        .join(SAMTOOLS_MERGE.out.bam)
        .join(PICARD_ADDORREPLACEREADGROUPS.out.bam)
        .join(SUBSAMPLE.out.bam)
        .map { meta, raw_stats, trim_stats, human_report, genomic_bam, merge_bam, dedup_bam, final_bam -> [ meta, raw_stats, trim_stats, human_report, genomic_bam, merge_bam, dedup_bam, final_bam ] }
        .set {ch_summary_passed}

    SUMMARY (
        ch_summary_passed
    )

*/
    SUMMARY_FINAL ( 
        //SUMMARY.out.summary_tsv.collect() 
        VARIANTS_TO_TABLE_NOCALL.out.txt,
        ch_calculate_no_call_stats
    )   

/*
    GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS (
        GATK4_HAPLOTYPECALLER_CONSENSUS.out.vcf.join(GATK4_HAPLOTYPECALLER_CONSENSUS.out.tbi).map{ [it[0], [it[1]], [it[2]]] },
        GATK4_HAPLOTYPECALLER_CONSENSUS.out.vcf.combine(ch_fasta).map{ [it[0],[it[2]]]},
        GATK4_HAPLOTYPECALLER_CONSENSUS.out.vcf.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        GATK4_HAPLOTYPECALLER_CONSENSUS.out.vcf.combine(ch_dict).map{ [it[0],[it[2]]]},
        [[],[]],
        [[],[]]  
    )

    GATK4_VARIANTFILTRATION_PHYLO_CONSENSUS (
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.join(GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.tbi).map{ [it[0], [it[1]], [it[2]]] },
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.combine(ch_fasta).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.combine(ch_fasta_fai).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.combine(ch_dict).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.combine(ch_mask).map{ [it[0],[it[2]]]},
        GATK4_VARIANTFILTRATION_DEPTH_CONSENSUS.out.vcf.combine(ch_mask_idx).map{ [it[0],[it[2]]]}
    )

    TABIX_BGZIP (
        GATK4_VARIANTFILTRATION_PHYLO_CONSENSUS.out.vcf
    )

    TABIX_TABIX (
        TABIX_BGZIP.out.output
    )

    BCFTOOLS_CONSENSUS (
        TABIX_BGZIP.out.output.join(TABIX_TABIX.out.tbi).combine(ch_fasta).map{ [it[0], [it[1]], [it[2]], [it[3]], []] }
    )
*/
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
