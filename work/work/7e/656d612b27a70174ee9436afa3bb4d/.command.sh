#!/bin/bash -ue
python3 - <<EOF
import pandas as pd

day_df = pd.read_csv("filtered_otu_table_day_filtered_rel_abund_cv_filtered.tsv", sep='\t')
night_df = pd.read_csv("filtered_otu_table_night_filtered_rel_abund_cv_filtered.tsv", sep='\t')

# Rename columns except OTU_ID to prefix them with exp_day_ or exp_night_
day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

# Merge on the OTU_ID column which was not renamed
merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')

merged_df.to_csv("merged_otu_table.tsv", sep='\t', index=False)
EOF
