process BBMAP_REPAIR {
    tag "$meta.id"
    label 'process_medium'

    container "${ 'quay.io/biocontainers/bbmap:39.06--h92535d8_1' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*repair*.fastq.gz"), emit: fastqs

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    repair.sh in1=${fastq[0]} in2=${fastq[1]} out1=${meta.id}_repair_1.fastq.gz out2=${meta.id}_repair_2.fastq.gz tossbrokenreads=t outs=singletons.fq repair

    """
}
