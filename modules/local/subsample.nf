process SUBSAMPLE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ 'community.wave.seqera.io/library/htslib_samtools:1.21--6cb89bfd40cbaabf' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}_final.bam"),     emit: bam
    tuple val(meta), path("${meta.id}_final.bam.bai"),     emit: bai

    script:
    """
    samtools index ${bam}
    frac=\$(samtools idxstats ${bam} | cut -f3 | awk 'BEGIN {total=0} {total += \$1} END {frac=4000000/total; if (frac > 1) {print 1} else {print frac}}' )
    if [ \$frac = 1 ]; then  
        cp ${bam} ${meta.id}_final.bam; 
    else    
        samtools view -s \$frac -b ${bam} > ${meta.id}_final.bam
    fi
    samtools index ${meta.id}_final.bam

    """
}
