process SPLIT_VCF {
    tag "$meta.id"
    label 'process_medium'

    container 'quay.io/biocontainers/bcftools:1.21--h3a4d415_1'

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*vcf.gz"), emit: vcfs

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def args2 = task.ext.args2 ?: ""
    def prefix = task.ext.prefix
    """
    SAMPLES=\$(bcftools query -l ${vcf})
    for i in \$SAMPLES
    do
        bcftools view -Oz -s \$i -o \${i}_split.vcf.gz ${vcf}
    done

    """
}
