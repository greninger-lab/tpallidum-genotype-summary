import argparse

def process_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        # Skip the header line
        next(infile)
        
        # Process each line
        for line in infile:
            columns = line.strip().split('\t')
            pos = columns[0]
            filter_value = columns[1]
            
            # Check if the filter value is "phylo_mask"
            if filter_value == "phylo_mask":
                # Calculate POS-1
                pos_minus_1 = int(pos) - 1
                # Write the output in the specified format
                outfile.write(f"NC_021508\t{pos_minus_1}\t{pos}\n")

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Process a file to extract POS values for rows containing 'phylo_mask'.")
    parser.add_argument('-i', '--input', required=True, help="Input file containing POS and FILTER columns.")
    parser.add_argument('-o', '--output', required=True, help="Output file to write the results.")
    
    # Parse arguments
    args = parser.parse_args()
    
    # Process the file
    process_file(args.input, args.output)
    print(f"Processed file saved to {args.output}")

if __name__ == "__main__":
    main()
    