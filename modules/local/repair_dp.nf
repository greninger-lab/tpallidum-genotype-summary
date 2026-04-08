process REPAIR_DP {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/fedora/python-312:312"

    input:
    tuple val(meta), path(vcf)
    path(gvcf_map)
    path(repair_depth)

    output:
    tuple val(meta), path("*_updated.vcf.gz"), emit: vcf
    tuple val(meta), path("*.txt"), emit: txt

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python3 ${repair_depth} ${vcf} --sample-map ${gvcf_map} --batch-size 100
    gzip *_updated.vcf

    """
}
