/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo          = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation      = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowTpgenotype.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_replace_pl_r            = Channel.fromPath("$projectDir/bin/replace_pl.py",                checkIfExists: true)
ch_calculate_percent_no_gt = Channel.fromPath("$projectDir/bin/calculate_percent_no_gt.py",   checkIfExists: true)
ch_calculate_no_call_stats = Channel.fromPath("$projectDir/bin/calculate_no_call_stats.py",   checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    REFERENCE FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_fasta      = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".fasta"     )
ch_fasta_fai  = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".fasta.fai" )
ch_dict       = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + ".dict"      )
ch_mask_v4    = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + "_mask_v4.bed"     )
ch_mask_v4_idx = Channel.fromPath( "$projectDir/assets/ref/" + params.ref + "_mask_v4.bed.idx" )
ch_exclude    = Channel.fromPath( "$projectDir/assets/ref/exclude.txt" )

/*
* Derive whole-contig interval from Picard/GATK dict
*/
def dictFile = file("$projectDir/assets/ref/" + params.ref + ".dict")
def sqLine   = dictFile.readLines().find { it.startsWith('@SQ') }
def fields   = sqLine.split('\t')
def sn       = fields.find { it.startsWith('SN:') }?.substring(3)
def ln       = fields.find { it.startsWith('LN:') }?.substring(3)
def interval = "${sn}:1-${ln}"

log.info "Using interval: ${interval}"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INPUT_CHECK                                   } from '../subworkflows/local/input_check'
include { BCFTOOLS as BCFTOOLS_GT_UNFILTERED            } from '../modules/local/bcftools'
include { BCFTOOLS as BCFTOOLS_VIEW_SNP                 } from '../modules/local/bcftools'
include { BCFTOOLS as BCFTOOLS_VIEW_FILTER_MASK         } from '../modules/local/bcftools'
include { VARIANTS_TO_TABLE as VARIANTS_TO_TABLE_NOCALL } from '../modules/local/variants_to_table'
include { PERCENT_NO_GENOTYPE                           } from '../modules/local/percent_no_genotype'
include { SUMMARY_FINAL                                 } from '../modules/local/summary_final'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { GATK4_INDEXFEATUREFILE                                             } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_INDEXFEATUREFILE as GATK4_INDEX_GT_FILTERED_DP               } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_INDEXFEATUREFILE as GATK4_INDEX_MASKED_SNPS                  } from '../modules/nf-core/gatk4/indexfeaturefile/main'
include { GATK4_VARIANTFILTRATION as GATK4_VARIANTFILTRATION_GT_AF08DP3      } from '../modules/nf-core/gatk4/variantfiltration/main'
include { GATK4_GENOMICSDBIMPORT                                             } from '../modules/nf-core/gatk4/genomicsdbimport/main'
include { GATK4_GENOTYPEGVCFS                                                } from '../modules/nf-core/gatk4/genotypegvcfs/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TPGENOTYPE {

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        file(params.input)
    )

    GATK4_INDEXFEATUREFILE (
        INPUT_CHECK.out.gvcf
    )

    // Define meta and interval channels
    ch_meta     = Channel.of([id: 'final'])
    ch_interval = Channel.value(params.interval ?: interval)

    // Join gvcf and tbi
    ch_gvcf_tbi = INPUT_CHECK.out.gvcf
        .join(GATK4_INDEXFEATUREFILE.out.index)

    // Build sample map using just filenames (staged locally)
    ch_gvcf_tbi
        .map { meta, gvcf, tbi ->
            def gvcf_path = (gvcf instanceof List) ? gvcf[0] : gvcf
            "${meta.id}\t${gvcf_path.name}"
        }
        .collectFile(
            name: 'sample_map.tsv',
            newLine: true,
            sort: false
        )
        .set { ch_sample_map }

    // Collect all gvcf + tbi files into a single list
    ch_gvcf_tbi
        .map { meta, gvcf, tbi ->
            def gvcf_file = (gvcf instanceof List) ? gvcf[0] : gvcf
            def tbi_file  = (tbi  instanceof List) ? tbi[0]  : tbi
            [gvcf_file, tbi_file]
        }
        .collect()
        .map { files ->
            def gvcfs = files.collate(2).collect { it[0] }
            def tbis  = files.collate(2).collect { it[1] }
            [gvcfs, tbis]
        }
        .set { ch_all_files }

    // Build ch_import
    if (params.run_updatewspace && params.wspace) {
        ch_meta
            .combine(ch_sample_map)
            .combine(ch_all_files)
            .map { meta, map, gvcfs, tbis ->
                [ meta, map, gvcfs, tbis, interval, [params.wspace] ]
            }
            .set { ch_import }
    } else {
        ch_meta
            .combine(ch_sample_map)
            .combine(ch_all_files)
            .map { meta, map, gvcfs, tbis ->
                [ meta, map, gvcfs, tbis, interval, [] ]
            }
            .set { ch_import }
    }

    ch_import.view { "CH_INPUT: sample_map=${it[1]}, n_gvcfs=${it[2].size()}, n_tbis=${it[3].size()}" }

    GATK4_GENOMICSDBIMPORT (
        ch_import,
        false,
        params.run_updatewspace,
        true
    )

    if (params.run_updatewspace && params.wspace) {
        GATK4_GENOMICSDBIMPORT.out.updatedb
            .map { meta, db -> [meta, db, [], [], []] }
            .set { ch_db }
    } else {
        GATK4_GENOMICSDBIMPORT.out.genomicsdb
            .map { meta, db -> [meta, db, [], [], []] }
            .set { ch_db }
    }

    GATK4_GENOTYPEGVCFS (
        ch_db,
        ch_fasta,
        ch_fasta_fai,
        ch_dict
    )

    BCFTOOLS_GT_AFDP_FILTER (
        GATK4_GENOTYPEGVCFS.out.vcf
    )

    GATK4_INDEX_GT_FILTERED_DP (
        BCFTOOLS_GT_AFDP_FILTER.out.vcf
    )

    GATK4_VARIANTFILTRATION_GT_AF09DP5 (
        BCFTOOLS_GT_AFDP_FILTER.out.vcf
            .join(GATK4_INDEX_GT_FILTERED_DP.out.index)
            .map { meta, vcf, tbi -> [meta, [vcf], [tbi]] },
        BCFTOOLS_GT_AFDP_FILTER.out.vcf.combine(ch_fasta).map       { meta, vcf, fa  -> [meta, [fa]]  },
        BCFTOOLS_GT_AFDP_FILTER.out.vcf.combine(ch_fasta_fai).map   { meta, vcf, fai -> [meta, [fai]] },
        BCFTOOLS_GT_AFDP_FILTER.out.vcf.combine(ch_dict).map        { meta, vcf, d   -> [meta, [d]]   },
        BCFTOOLS_GT_AFDP_FILTER.out.vcf.combine(ch_mask_v4).map     { meta, vcf, m   -> [meta, [m]]   },
        BCFTOOLS_GT_AFDP_FILTER.out.vcf.combine(ch_mask_v4_idx).map { meta, vcf, mi  -> [meta, [mi]]  }
    )

    BCFTOOLS_VIEW_SNP (
        GATK4_VARIANTFILTRATION_GT_AF09DP5.out.vcf
    )

    BCFTOOLS_VIEW_FILTER_MASK (
        BCFTOOLS_VIEW_SNP.out.vcf
    )

    GATK4_INDEX_MASKED_SNPS (
        BCFTOOLS_VIEW_FILTER_MASK.out.vcf
    )

    VARIANTS_TO_TABLE_NOCALL (
        BCFTOOLS_VIEW_FILTER_MASK.out.vcf
            .join(GATK4_INDEX_MASKED_SNPS.out.index)
            .map { meta, vcf, tbi -> [meta, [vcf], [tbi]] }
    )

    PERCENT_NO_GENOTYPE (
        VARIANTS_TO_TABLE_NOCALL.out.txt,
        ch_exclude,
        ch_calculate_percent_no_gt
    )

    SUMMARY_FINAL (
        VARIANTS_TO_TABLE_NOCALL.out.txt,
        ch_calculate_no_call_stats
    )
}
