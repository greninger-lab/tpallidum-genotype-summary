import csv
import math
import sys

# Function to process the file
def process_file(file_path, out_file_name):

    with open(file_path, 'r') as infile, open(out_file_name, 'w') as outfile:
        # Process the file line by line
        for line in infile:
            if line.startswith('#'):
                # Write metadata lines directly to the output file
                outfile.write(line)
            else:
                # Process data rows
                row = line.strip().split('\t')
                if len(row) == 10:
                    # Split the 9th field by ':'
                    split_string = row[9].split(':')
                    
                    # Check if the last field matches "0,0" - ploidy = 1
                    if split_string[-1] == "0,0" and row[4] == "<NON_REF>":
                        # Multiply split_string[2] by 5.5 and round to nearest integer
                        try:
                            value = int(split_string[2])
                            result = round(value * 5.5)
                            if result > 1800:
                                result = 1800
                            split_string[-1] = f"0,{result}"
                            row[9] = ':'.join(split_string)
                            #print(f"Row: {row}")
                            
                        except (IndexError, ValueError) as e:
                            print(f"Error processing row: {row}, Error: {e}")
                            exit(1)
                    #else:
                        #print(f"Row: {row}, Last field does not match '0,0'")
                    outfile.write('\t'.join(row) + '\n')
                else:
                    print(f"Row: {row}, does not have enough fields")
                        # Write the processed row to the output file
                    exit(1)
    print(f"Processed file saved as: out_file_name")

# Check if a file name is provided as a command-line argument
if len(sys.argv) != 2:
    print("Usage: python script.py <tsv_file>")
    sys.exit(1)

# Get the file name from the command-line argument
file_name = sys.argv[1] + "_remap.g.vcf"
out_file_name = file_name.replace("_remap.g.vcf", "_remap_reheadered.g.vcf")

# Process the file
process_file(file_name, out_file_name)