process VARIANTS_TO_TABLE {
    tag "$meta.id"
    label 'process_medium'

    container 'quay.io/biocontainers/gatk4:4.6.1.0--py310hdfd78af_0'

    input:
    tuple val(meta), path(vcf), path(idx)

    output:
    tuple val(meta), path("*.txt"), emit: txt

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix
    """
    gatk VariantsToTable -V ${vcf} ${args} -O ${prefix}.txt

    """
}

