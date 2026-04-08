//
// Check input samplesheet and get read channels
//

include { GVCF_SAMPLESHEET_CHECK } from '../../modules/local/gvcf_samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    GVCF_SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_gvcf_channel(it) }
        .set { gvcf }

    emit:
    gvcf                                     // channel: [ val(meta), [ gvcf ] ]
}

// Function to get list of [ meta, [ fasta ] ]
def create_gvcf_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample

    // add path(s) of the fastq file(s) to the meta map
    def gvcf_meta = []
    if (!file(row.gvcf).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> gvcf file does not exist!\n${row.gvcf}"
    }

    gvcf_meta = [ meta, [ file(row.gvcf) ] ]

    return gvcf_meta
}
