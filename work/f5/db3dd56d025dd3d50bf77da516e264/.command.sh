#!/bin/bash -ue
python3 - <<EOF
import os
import pandas as pd

day_df = pd.read_csv("filtered_otu_table_day_filtered_rel_abund_cv_filtered.tsv", sep='\t')
night_df = pd.read_csv("filtered_otu_table_night_filtered_rel_abund_cv_filtered.tsv", sep='\t')

day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')

output_dir = "./"
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "merged_otu_table.tsv")

merged_df.to_csv(output_path, sep='\t', index=False)
EOF
