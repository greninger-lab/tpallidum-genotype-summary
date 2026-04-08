aws_bucket=`echo $1 | sed '/\/$/! s|$|/|'`
aws_folder=${2#/}
run_name=$3
r1_ext=$4
r2_ext=$5
echo "$aws_bucket$aws_folder"
aws s3 ls "$aws_bucket$aws_folder" --recursive | grep "fastq.gz" | rev | cut -d " " -f1 | rev > aws_file_list.txt
echo "sample,fastq_1,fastq_2" > ${run_name}_samplesheet.csv
IFS=$'\n\r'
for line in $(cat aws_file_list.txt | grep "${r1_ext}")
do
	base_untrimmed=`basename $line $r1_ext`
        base=${base_untrimmed%%$r1_ext*}
		echo $base_untrimmed
		echo $base
	echo "${base},${aws_bucket}${line},${aws_bucket}${line/$r1_ext/$r2_ext}" >> ${run_name}_samplesheet.csv 
done
