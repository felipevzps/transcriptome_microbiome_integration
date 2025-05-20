#!/bin/bash -ue
python3 - <<EOF
import pandas as pd

day_df = pd.read_csv("filtered_otu_table_day_filtered_rel_abund_cv_filtered.tsv", sep='\t')
night_df = pd.read_csv("filtered_otu_table_night_filtered_rel_abund_cv_filtered.tsv", sep='\t')

day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

merged_df = pd.merge(day_df, night_df, left_on="exp_day_OTU_ID", right_on="exp_night_OTU_ID", how='outer')
merged_df["OTU_ID"] = merged_df["exp_day_OTU_ID"].combine_first(merged_df["exp_night_OTU_ID"])
merged_df = merged_df.drop(columns=["exp_day_OTU_ID", "exp_night_OTU_ID"])
cols = ["OTU_ID"] + [col for col in merged_df.columns if col != "OTU_ID"]
merged_df = merged_df[cols]

merged_df.to_csv("merged_otu_table.tsv", sep='\t', index=False)
EOF
