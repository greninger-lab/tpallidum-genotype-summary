process BCFTOOLS {
    tag "$meta.id"
    label 'process_medium'

    container 'quay.io/biocontainers/bcftools:1.21--h3a4d415_1'

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*vcf.gz"), emit: vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def args2 = task.ext.args2 ?: ""
    def prefix = task.ext.prefix
    """
    bcftools ${args} ${vcf} -o ${prefix}.vcf.gz ${args2}

    """
}
