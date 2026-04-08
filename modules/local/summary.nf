process SUMMARY {
    tag "$meta.id"
    label 'process_medium'

    container "${ 'staphb/samtools:1.17' }"

    input:
    tuple val(meta), path(raw_stats), path(trim_stats), path(human_report), path(genomic_bam), path(merge_bam), path(dedup_bam), path(final_bam)

    output:
    path("*.tsv"), emit: summary_tsv

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    raw_reads_r1=`sed -n '2p' ${raw_stats} | awk '{print \$4}'`
    raw_reads_r1_avg_len=`sed -n '2p' ${raw_stats} | awk '{print \$7}'`
    raw_reads_r2=`sed -n '3p' ${raw_stats} | awk '{print \$4}'`
    raw_reads_r2_avg_len=`sed -n '3p' ${raw_stats} | awk '{print \$7}'`

    human_removed=`grep 'unclassified' ${human_report} | awk '{print \$3}'`

    trim_reads_r1=`sed -n '2p' ${trim_stats} | awk '{print \$4}'`
    trim_reads_r1_avg_len=`sed -n '2p' ${trim_stats} | awk '{print \$7}'`
    trim_reads_r2=`sed -n '3p' ${trim_stats} | awk '{print \$4}'`
    trim_reads_r2_avg_len=`sed -n '3p' ${trim_stats} | awk '{print \$7}'`

    quality_trimmed="x"

    mapped_genomic_reads=`samtools view -F 4 -c ${genomic_bam}`
    mapped_merged_reads=`samtools view -F 4 -c ${merge_bam}`
    mapped_deduped_reads=`samtools view -F 4 -c ${dedup_bam}`
    mapped_final_reads=`samtools view -F 4 -c ${final_bam}`

    mean_insert_final=`samtools stats ${final_bam} | grep "^IS" | awk -v max_size=2000 '{if (\$2 <= max_size) {sum += \$2 * \$4; count += \$4}} END {if (count > 0) print sum / count; else print "n/a"}'`
    mean_coverage=`samtools coverage ${final_bam} | awk 'NR>1' | cut -f7`
    percent_cov_gte5=`samtools depth ${final_bam} | awk '{ if (\$3 >= 5) { count++; } } END { print (count / NR) * 100 }'`


    echo "sample\traw_reads_r1\traw_reads_r1_avg_len\traw_reads_r2\traw_reads_r2_avg_len\thuman_removed\ttrim_reads_r1\ttrim_reads_r1_avg_len\ttrim_reads_r2\ttrim_reads_r2_avg_len\tquality_trimmed\tmapped_genomic_reads\tmapped_merged_reads\tmapped_deduped_reads\tmapped_final_reads\tmean_insert_final\tmean_coverage\tpercent_cov_gte5" > ${prefix}.summary.tsv
    echo "${prefix}\t\${raw_reads_r1}\t\${raw_reads_r1_avg_len}\t\${raw_reads_r2}\t\${raw_reads_r2_avg_len}\t\${human_removed}\t\${trim_reads_r1}\t\${trim_reads_r1_avg_len}\t\${trim_reads_r2}\t\${trim_reads_r2_avg_len}\t\${quality_trimmed}\t\${mapped_genomic_reads}\t\${mapped_merged_reads}\t\${mapped_deduped_reads}\t\${mapped_final_reads}\t\${mean_insert_final}\t\${mean_coverage}\t\${percent_cov_gte5}" >> ${prefix}.summary.tsv
    
    """
}
