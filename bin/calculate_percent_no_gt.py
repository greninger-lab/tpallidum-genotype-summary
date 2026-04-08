import csv
import argparse

def calculate_percentage_dot(input_file, exclude_sample_file):
    # Initialize a dictionary to store the results
    results = {}

    # Read the list of .GT headers to exclude
    with open(exclude_sample_file, 'r') as exclude_file:
        exclude_headers = set(line.strip() for line in exclude_file)

    # Open the data file and read it as a CSV
    with open(input_file, 'r') as file, open("N25.args", 'w') as out_file:
        reader = csv.DictReader(file, delimiter='\t')
        
        # Get the headers that contain ".GT" and are not in the exclude list
        gt_headers = [header for header in reader.fieldnames if ".GT" in header]
        
        # Initialize counters for each .GT column
        dot_counts = {header: 0 for header in gt_headers}
        total_rows = 0

        # Iterate through each row in the file
        for row in reader:
            # Skip empty rows (rows where all values are empty or ".")
            if row["POS"] == '' or row["POS"] == ' ' or row["POS"] == None:
                continue

            total_rows += 1
            for header in gt_headers:
                if row[header] == ".":
                    dot_counts[header] += 1

        # Calculate the percentage of "." for each .GT column
        for header in gt_headers:
            percentage = (dot_counts[header] / total_rows) * 100
            if header not in exclude_headers and percentage <= 25:
                out_file.write(header.replace(".GT", "") + "\n")

# Set up command-line argument parsing
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate the percentage of '.' in .GT columns.")
    parser.add_argument("-i", "--input", required=True, help="Path to the input data file.")
    parser.add_argument("-e", "--exclude", required=True, help="Path to the file containing .GT headers to exclude.")
    args = parser.parse_args()

    # Run the function and print the results
    calculate_percentage_dot(args.input, args.exclude)
    
