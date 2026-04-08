import csv

def process_multisample_file(input_file, output_file):
    with open(input_file, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        sample_names = [col.replace('.GT', '') for col in reader.fieldnames if col != 'POS']
        
        # Initialize counts per sample
        sample_counts = {sample: {'total': 0, 'nocall': 0} for sample in sample_names}
        
        for row in reader:
            for col in reader.fieldnames:
                if col == 'POS':
                    continue
                sample = col.replace('.GT', '')
                gt = row[col].strip()
                sample_counts[sample]['total'] += 1
                if gt == '.':
                    sample_counts[sample]['nocall'] += 1
        
    # Write output
    with open(output_file, 'w', newline='') as out_f:
        writer = csv.writer(out_f, delimiter='\t')
        writer.writerow(["sample", "total_pos", "perc_nocall"])
        for sample, counts in sample_counts.items():
            total = counts['total']
            nocall = counts['nocall']
            percent = round((nocall / total) * 100, 2) if total > 0 else 0.0
            writer.writerow([sample, total, percent])

# Run the script
if __name__ == "__main__":
    input_file = "final_count_nocall.txt"
    output_file = "nocall_summary.tsv"
    process_multisample_file(input_file, output_file)
    print(f"Summary written to {output_file}")
