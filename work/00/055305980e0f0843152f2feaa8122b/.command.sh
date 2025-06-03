#!/bin/bash -ue
python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load correlation matrix
df = pd.read_csv("otu_gene_correlation.tsv", sep="\t", index_col=0)

# Convert to numeric and drop all-NaN rows/columns
df = df.apply(pd.to_numeric, errors='coerce')
df = df.dropna(axis=0, how='all')
df = df.dropna(axis=1, how='all')

# Print matrix stats for debugging
print("Matrix shape:", df.shape)
print("Min:", df.min().min())
print("Max:", df.max().max())
print("Mean:", df.mean().mean())

# Skip plotting if matrix is empty
if df.empty:
    print("Filtered matrix is empty — no heatmap generated.")
else:
    plt.figure(figsize=(12, 10))
    sns.heatmap(df, cmap="coolwarm", center=0, linewidths=0.5, linecolor='gray', cbar_kws={'label': 'Pearson r'})
    plt.title("OTU vs Gene Expression Correlation Heatmap")
    plt.xlabel("Genes")
    plt.ylabel("OTUs")
    plt.tight_layout()
    plt.savefig("otu_gene_heatmap.png", dpi=300)
EOF
