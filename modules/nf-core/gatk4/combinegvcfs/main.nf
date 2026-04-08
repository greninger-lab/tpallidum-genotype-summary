process GATK4_COMBINEGVCFS {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/gatk4_gcnvkernel:e48d414933d188cd'

    input:
    tuple val(meta), path(vcf), path(vcf_idx)
    path  fasta
    path  fai
    path  dict
    path gvcf_list

    output:
    tuple val(meta), path("01_combined.g.vcf.gz"), emit: combined_gvcf
    tuple val(meta), path("01_combined.g.vcf.gz.tbi"), emit: index
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    //def input_list = vcf.collect{"--variant $it"}.join(' ')
    // check to see if gvcf_list is provided to filter the vcfs
    def input_list_provided = (gvcf_list ? "true" : "false")

    def avail_mem = 3072
    if (!task.memory) {
        log.info '[GATK COMBINEGVCFS] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }
    // gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
    //     CombineGVCFs \\
    //     $input_list \\
    //     --output ${prefix}.combined.g.vcf.gz \\
    //     --reference ${fasta} \\
    //     --tmp-dir . \\
    //     $args
    """
    if ${input_list_provided}; then
        cp ${gvcf_list} vcf.list
    else
        ls *.vcf.gz > vcf.list
    fi

    gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
        CombineGVCFs \\
        --variant vcf.list \\
        --output ${prefix}.g.vcf.gz \\
        --reference ${fasta} \\
        --tmp-dir . \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "" | gzip > ${prefix}.combined.g.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
