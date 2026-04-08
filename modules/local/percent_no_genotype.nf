process PERCENT_NO_GENOTYPE {
    tag "$meta.id"
    label 'process_medium'

    container "quay.io/fedora/python-312:312"

    input:
    tuple val(meta), path(count_nocall)
    path(exclude)
    path(calculate_percent)

    output:
    tuple val(meta), path("N25.args"), emit: n25

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python3 calculate_percent_no_gt.py -i ${count_nocall} -e ${exclude}

    """
}
