process IVAR_VARIANT {
    tag "$meta.id"
    label 'process_medium'

    container 'quay.io/jefffurlong/ivar:1.4.4'

    input:
    tuple val(meta), path(bam), path(fasta), path(gff)

    output:
    tuple val(meta), path("*.tsv"), emit: variants

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def args2 = task.ext.args2 ?: ""
    def prefix = task.ext.prefix
    """
    samtools mpileup -aa -A -d 600000 -B -Q 0 ${bam} | ivar variants -p ${meta.id}_variants -q 20 -t 0.03 -G -r ${fasta} -g ${gff}

    """    
}