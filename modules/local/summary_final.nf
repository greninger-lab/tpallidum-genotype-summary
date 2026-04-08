process SUMMARY_FINAL {

    label 'process_single'
    container 'quay.io/fedora/python-312:312'

    input:
    //path(summary_tsv_files)
    tuple val(meta), path(nocall_file)
    path(calculate_no_call_stats)


    output:
    //path "summary*.tsv", emit: summary
    path "nocall_summary.tsv", emit: nocall_summary

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    //def summary_file_name = is_failed_summary ? "summary_failed.tsv" : "summary.tsv"
    //def summary_file_name = "summary_final.tsv"

    """
    python3 ${calculate_no_call_stats}

    """
}