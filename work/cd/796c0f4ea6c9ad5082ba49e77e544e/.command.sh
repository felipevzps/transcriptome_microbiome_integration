#!/bin/bash -ue
python3 - <<EOF
import pandas as pd
from scipy.stats import pearsonr

# Load input tables
otu_df = pd.read_csv("merged_otu_table.tsv", sep="\t").set_index("OTU_ID")
expr_df = pd.read_csv("kremling_expression_v5_counts_filtered_cv_filtered.tsv", sep="\t").set_index("Name")

# Find common samples
common_samples = list(set(otu_df.columns).intersection(expr_df.columns))
otu_df = otu_df[common_samples].T
expr_df = expr_df[common_samples].T

# Compute Pearson correlation for each OTU vs Gene
correlation_df = pd.DataFrame(index=otu_df.columns, columns=expr_df.columns)

for otu in otu_df.columns:
    for gene in expr_df.columns:
        try:
            corr, _ = pearsonr(otu_df[otu], expr_df[gene])
            correlation_df.at[otu, gene] = corr
        except:
            correlation_df.at[otu, gene] = float('nan')

# Save output
correlation_df.to_csv("otu_gene_correlation.tsv", sep="\t")
EOF
