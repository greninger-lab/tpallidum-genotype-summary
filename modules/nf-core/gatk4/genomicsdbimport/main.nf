process GATK4_GENOMICSDBIMPORT {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/ce/ced519873646379e287bc28738bdf88e975edd39a92e7bc6a34bccd37153d9d0/data'
        : 'community.wave.seqera.io/library/gatk4_gcnvkernel:edb12e4f0bf02cd3'}"

    input:
    tuple val(meta), path(sample_map), path(gvcfs), path(tbis), val(interval_value), path(wspace)
    val run_intlist
    val run_updatewspace
    val input_map

    output:
    tuple val(meta), path("${prefix}"),       emit: genomicsdb,   optional: true
    tuple val(meta), path("${updated_db}"),   emit: updatedb,     optional: true
    tuple val(meta), path("*.interval_list"), emit: intervallist, optional: true
    path "versions.yml",                      emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    // When using sample_map, point to the staged sample_map file
    // gvcfs and tbis are staged in the same work dir automatically
    input_command = input_map ? "--sample-name-map ${sample_map}" : gvcfs.collect { gvcf_ -> "--variant ${gvcf_}" }.join(' ')

    genomicsdb_command = "--genomicsdb-workspace-path ${prefix}"
    interval_command   = "--intervals ${interval_value}"
    updated_db         = ""

    // settings changed for running get intervals list mode
    if (run_intlist) {
        genomicsdb_command = "--genomicsdb-update-workspace-path ${wspace}"
        interval_command   = "--output-interval-list-to-file ${prefix}.interval_list"
    }

    // settings changed for running update gendb mode
    if (run_updatewspace) {
        genomicsdb_command = "--genomicsdb-update-workspace-path ${wspace}"
        interval_command   = ''
        updated_db         = "${wspace}"
    }

    def avail_mem = 3072
    if (!task.memory) {
        log.info('[GATK GenomicsDBImport] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.')
    } else {
        avail_mem = (task.memory.mega * 0.8).intValue()
    }

    threads = (task.cpus * 0.8).intValue()

    """
    gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
        GenomicsDBImport \\
        ${input_command} \\
        ${genomicsdb_command} \\
        ${interval_command} \\
        --tmp-dir . \\
        --reader-threads ${threads} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    prefix     = task.ext.prefix ?: "${meta.id}"
    updated_db = ""

    genomicsdb_command = "--genomicsdb-workspace-path ${prefix}"
    interval_command   = "--intervals ${interval_value}"

    if (run_intlist) {
        genomicsdb_command = "--genomicsdb-update-workspace-path ${wspace}"
        interval_command   = "--output-interval-list-to-file ${prefix}.interval_list"
    }

    if (run_updatewspace) {
        genomicsdb_command = "--genomicsdb-update-workspace-path ${wspace}"
        interval_command   = ''
        updated_db         = "${wspace}"
    }

    def stub_genomicsdb = genomicsdb_command == "--genomicsdb-workspace-path ${prefix}"                            ? "mkdir ${prefix}" : ""
    def stub_interval   = interval_command   == "--output-interval-list-to-file ${prefix}.interval_list"           ? "touch ${prefix}.interval_list" : ""
    def stub_update     = updated_db         != ""                                                                 ? "mkdir ${wspace}" : ""

    """
    ${stub_genomicsdb}
    ${stub_interval}
    ${stub_update}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}