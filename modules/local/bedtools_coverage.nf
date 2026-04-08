process BEDTOOLS_COVERAGE {
    tag "$meta.id"
    label 'process_medium'

    container "${ 'biocontainers/bedtools:2.27.1--h077b44d_9' }"

    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(ref)

    output:
    path("*.txt"), emit: txt

    script:
    """
    genomeCoverageBed -ibam ${bam} -g ${ref} > ${meta.id}_coverage.txt

    """
}



