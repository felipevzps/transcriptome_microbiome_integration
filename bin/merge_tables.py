#!/usr/bin/env python3

import sys
import pandas as pd

def main():
    # Check if correct number of arguments provided
    if len(sys.argv) != 3:
        print("Usage: python script.py <day_file> <night_file>")
        print("Example: python script.py file1.txt file2.txt")
        sys.exit(1)
    
    # Parse command line arguments
    day_file = sys.argv[1]
    night_file = sys.argv[2]
    
    try:
        # Read the CSV files
        day_df = pd.read_csv(day_file, sep='\t')
        night_df = pd.read_csv(night_file, sep='\t')
        
        # Rename columns (except OTU_ID)
        day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
        night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})
        
        # Merge dataframes
        merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')
        
        # Save merged data
        merged_df.to_csv("merged_otu_table.tsv", sep='\t', index=False)
        
        print(f"Successfully merged {day_file} and {night_file}")
        print("Output saved as: merged_otu_table.tsv")
        
    except FileNotFoundError as e:
        print(f"Error: File not found - {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error processing files: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
