#!/usr/bin/env python3

import argparse
import pandas as pd
import sys

parser = argparse.ArgumentParser(description='Merge day and night expression matrix')
parser.add_argument('--day', type=str, dest='day_file', help='day expression matrix', metavar='otu_table_day.tsv', required=True)
parser.add_argument('--night', type=str, dest='night_file', help='night expression matrix', metavar='otu_table_night.tsv', required=True)
parser.add_argument('--output', type=str, dest='merged_otu_table', help='merged otu table ', metavar='merged_otu_table.tsv', required=True)
args = parser.parse_args()

day_file = args.day_file
night_file = args.night_file
output = args.merged_otu_table

# Read the CSV files
day_df = pd.read_csv(day_file, sep='\t')
night_df = pd.read_csv(night_file, sep='\t')

# Rename columns (except OTU_ID)
day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

# Merge dataframes
merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')

# Save merged data
merged_df.to_csv(output, sep='\t', index=False)

print(f"Successfully merged {day_file} and {night_file}")
print("Output saved as:", output)
