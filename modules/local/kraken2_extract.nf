process KRAKEN2_EXTRACT {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/jefffurlong/krakentools"

    input:
    tuple val(meta), path(classified_reads)
    tuple val(meta1), path(reads_assignment)
    tuple val(meta2), path(report)
    val(taxid)
    
    output:
    tuple val(meta), path("*.fastq.gz"),     emit: extracted_fastqs


    script:
    def input_reads = ""
    def out_reads = ""
    if (meta.single_end) {
        input_reads = "-s ${classified_reads}"
        out_reads = "-o ${meta.id}_classified_${taxid}.fastq"
    } else {
        input_reads = "-s1 ${classified_reads[0]} -s2 ${classified_reads[1]}"
        out_reads = "-o ${meta.id}_classified_${taxid}_1.fastq -o2 ${meta.id}_classified_${taxid}_2.fastq"
    }
    """
    python3 /usr/share/KrakenTools/extract_kraken_reads.py -k ${reads_assignment} -r ${report} ${input_reads} ${out_reads} -t ${taxid} --include-children --include-parents --fastq-output
    gzip *.fastq
    """
}
