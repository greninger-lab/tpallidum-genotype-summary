import sys
import os
import gzip
import argparse
from collections import defaultdict

def open_vcf(path):
    if path.endswith('.gz'):
        return gzip.open(path, 'rt')
    return open(path, 'r')

def parse_args():
    parser = argparse.ArgumentParser(description='Update DP and AD values in multi-sample GVCF from per-sample GVCFs')
    parser.add_argument('gvcf', help='Multi-sample GVCF file')
    parser.add_argument('--sample-map', required=True, help='Tab-delimited file: sample<TAB>path_to_gvcf')
    parser.add_argument('--batch-size', type=int, default=50, help='Number of samples to process per batch')
    return parser.parse_args()

def load_sample_map(sample_map_file):
    sample_map = {}
    with open(sample_map_file) as f:
        for line in f:
            if not line.strip():
                continue
            parts = line.strip().split('\t')
            if len(parts) != 2:
                raise ValueError(f"Invalid line in sample map: {line.strip()}")
            sample, path = parts
            if not os.path.exists(path):
                raise FileNotFoundError(f"GVCF path not found for sample {sample}: {path}")
            sample_map[sample] = path
    return sample_map

def load_sample_gvcf(sample, sample_map):
    """Load per-sample GVCF into a dict of POS -> (AD, DP).
    Single-sample FORMAT is GT:AD:DP:GQ:PL — AD is index 1, DP is index 2.
    """
    vcf_path = sample_map[sample]
    pos_ad_dp = {}
    with open_vcf(vcf_path) as f:
        for line in f:
            if line.startswith('#'):
                continue
            tab1 = line.index('\t')
            tab2 = line.index('\t', tab1 + 1)
            pos = int(line[tab1+1:tab2])
            # Find the sample field (10th column, index 9)
            col = 0
            idx = 0
            while col < 9:
                idx = line.index('\t', idx) + 1
                col += 1
            sample_field = line[idx:].strip()
            parts = sample_field.split(':')
            # GT:AD:DP:GQ:PL  ->  AD=parts[1], DP=parts[2]
            ad = parts[1] if len(parts) >= 2 else None
            try:
                dp = int(parts[2]) if len(parts) >= 3 else None
            except ValueError:
                dp = None
            pos_ad_dp[pos] = (ad, dp)
    return pos_ad_dp

def get_ad_dp_from_multisample_field(field):
    """Extract AD (index 1) and DP (index 3) from combined GVCF field.
    Combined FORMAT is GT:AD:AF:DP:GQ:PL
    Returns (ad, dp) or (None, None) if missing/invalid.
    """
    if not field or field.startswith('.:.'):
        return None, None
    parts = field.split(':')
    ad = parts[1] if len(parts) >= 2 else None
    try:
        dp = int(parts[3]) if len(parts) >= 4 else None
    except ValueError:
        dp = None
    return ad, dp

def update_ad_dp_in_field(field, new_ad, new_dp):
    """Update AD (index 1) and DP (index 3) in a combined GVCF field.
    Combined FORMAT is GT:AD:AF:DP:GQ:PL
    """
    parts = field.split(':')
    if new_ad is not None and len(parts) >= 2:
        parts[1] = new_ad
    if new_dp is not None and len(parts) >= 4:
        parts[3] = str(new_dp)
    return ':'.join(parts)

def process_batch(batch_samples, sample_indices, gvcf_path, sample_map, update_files):
    """
    Process a batch of samples against the multi-sample GVCF.
    Streams the GVCF line by line - never holds it all in memory.
    Returns dict of (line_idx, col_idx) -> new_field for this batch.
    """
    print(f"  Loading {len(batch_samples)} per-sample GVCFs...")
    sample_dps = {}
    for sample in batch_samples:
        sample_dps[sample] = load_sample_gvcf(sample, sample_map)
        sys.stdout.write('.')
        sys.stdout.flush()
    print()

    updates_per_sample = defaultdict(list)
    line_updates = {}

    print(f"  Scanning multi-sample GVCF...")
    with open_vcf(gvcf_path) as f:
        line_idx = 0
        for line in f:
            if line.startswith('#'):
                continue
            fields = line.rstrip('\n').split('\t')
            pos = int(fields[1])

            for sample in batch_samples:
                col_idx = sample_indices[sample]
                field = fields[col_idx]
                gvcf_ad, gvcf_dp = get_ad_dp_from_multisample_field(field)

                if gvcf_dp is None:
                    continue

                if pos not in sample_dps[sample]:
                    raise KeyError(
                        f"POS {pos} found in multi-sample GVCF but missing "
                        f"from {sample_map[sample]}"
                    )

                ref_ad, ref_dp = sample_dps[sample][pos]

                if ref_dp is None:
                    continue

                if gvcf_dp != ref_dp: # or gvcf_ad != ref_ad:
                    updates_per_sample[sample].append((pos, gvcf_ad, gvcf_dp, ref_ad, ref_dp))
                    line_updates[(line_idx, col_idx)] = update_ad_dp_in_field(field, ref_ad, ref_dp)

            line_idx += 1

    # Write update files for this batch
    for sample, updates in updates_per_sample.items():
        if sample in update_files:
            mode = 'a'
        else:
            mode = 'w'
            update_files.add(sample)
        with open(f"{sample}_updates.txt", mode) as out:
            if mode == 'w':
                out.write("POS\tgvcf_ad\tgvcf_dp\tsample_ad\tsample_dp\n")
            for pos, gvcf_ad, gvcf_dp, sample_ad, sample_dp in sorted(updates, key=lambda x: x[0]):
                out.write(f"{pos}\t{gvcf_ad}\t{gvcf_dp}\t{sample_ad}\t{sample_dp}\n")

    # Free memory immediately
    del sample_dps
    del updates_per_sample

    return line_updates

def main():
    args = parse_args()

    sample_map = load_sample_map(args.sample_map)

    # --- Read header and sample list from multi-sample GVCF ---
    header_lines = []
    samples = []
    sample_indices = {}
    num_data_lines = 0

    print(f"Reading header from: {args.gvcf}")
    with open_vcf(args.gvcf) as f:
        for line in f:
            stripped = line.rstrip('\n')
            if stripped.startswith('##'):
                header_lines.append(stripped)
            elif stripped.startswith('#CHROM'):
                header_lines.append(stripped)
                cols = stripped.split('\t')
                samples = cols[9:]
                for i, s in enumerate(samples):
                    sample_indices[s] = 9 + i
            else:
                num_data_lines += 1

    print(f"Found {len(samples)} samples, {num_data_lines} variant positions")

    # Validate all samples exist in sample map
    missing = [s for s in samples if s not in sample_map]
    if missing:
        raise ValueError(f"Samples in GVCF missing from sample map: {missing[:5]}...")

    # --- Process samples in batches ---
    batch_size = args.batch_size
    batches = [samples[i:i+batch_size] for i in range(0, len(samples), batch_size)]
    print(f"Processing {len(samples)} samples in {len(batches)} batches of {batch_size}")

    all_line_updates = {}
    update_files = set()

    for batch_num, batch in enumerate(batches, 1):
        print(f"\nBatch {batch_num}/{len(batches)}: {batch[0]} ... {batch[-1]}")
        batch_updates = process_batch(
            batch, sample_indices, args.gvcf, sample_map, update_files
        )
        all_line_updates.update(batch_updates)
        print(f"  Cumulative updates so far: {len(all_line_updates)}")

    # --- Write final updated GVCF in a single streaming pass ---
    base = args.gvcf
    for ext in ('.gz', '.vcf'):
        if base.endswith(ext):
            base = base[:-len(ext)]
    output_gvcf = f"{base}_updated.vcf"

    print(f"\nWriting updated GVCF: {output_gvcf}")
    with open_vcf(args.gvcf) as f_in, open(output_gvcf, 'w') as f_out:
        for line in header_lines:
            f_out.write(line + '\n')

        line_idx = 0
        for line in f_in:
            if line.startswith('#'):
                continue
            fields = line.rstrip('\n').split('\t')

            for col_idx in range(9, len(fields)):
                key = (line_idx, col_idx)
                if key in all_line_updates:
                    fields[col_idx] = all_line_updates[key]

            f_out.write('\t'.join(fields) + '\n')
            line_idx += 1

    total_updates = sum(1 for k in all_line_updates)
    print(f"\nDone. Total field updates: {total_updates}")
    print(f"Output GVCF: {output_gvcf}")

if __name__ == '__main__':
    main()
