process GENERATE_POS_MASK_BED {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/fedora/python-312:312"

    input:
    tuple val(meta), path(txt)
    path(generate_phylo_mask_bed)

    output:
    tuple val(meta), path("*bed"), emit: bed

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python3 ${generate_phylo_mask_bed} -i ${txt} -o per_pos_mask.bed

    """
}
