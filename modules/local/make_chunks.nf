process MAKE_CHUNKS {
    tag "$meta.id"
    label 'process_medium'

    container 'quay.io/jefffurlong/samtools_bcftools:latest'

    input:
    tuple val(meta), path(vcfs), path(per_pos_mask)
    path(ref)
    path(fai)
    path(dict)
    path(make_chunks)
    

    output:
    tuple val(meta), path("*unmasked*.fasta"), emit: unmasked
    tuple val(meta), path("*phylomasked*.fasta"), emit: phylomasked

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    touch t
    bash ${make_chunks} ${ref} ${per_pos_mask}

    """
}
