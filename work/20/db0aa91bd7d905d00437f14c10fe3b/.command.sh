#!/bin/bash -ue
python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load correlation matrix
df = pd.read_csv("otu_gene_correlation.tsv", sep="\t", index_col=0)

# Convert all values to numeric and drop rows/columns with all NaNs
df = df.apply(pd.to_numeric, errors='coerce')
df = df.dropna(axis=0, how='all')  # drop OTUs with all NaNs
df = df.dropna(axis=1, how='all')  # drop genes with all NaNs

# Debugging info
print("Correlation matrix shape after filtering:", df.shape)
print("Fraction of missing values:", df.isna().sum().sum() / (df.shape[0] * df.shape[1]))

# If matrix is empty after filtering, skip plot
if df.empty:
    print("Filtered matrix is empty — skipping heatmap generation.")
else:
    plt.figure(figsize=(12, 10))
    sns.heatmap(df, cmap="coolwarm", center=0, linewidths=0.5, linecolor='gray', cbar_kws={'label': 'Pearson r'})
    plt.title("OTU vs Gene Expression Correlation Heatmap")
    plt.xlabel("Genes")
    plt.ylabel("OTUs")
    plt.tight_layout()
    plt.savefig("otu_gene_heatmap.png", dpi=300)
EOF
